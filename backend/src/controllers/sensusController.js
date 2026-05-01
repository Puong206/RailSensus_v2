const { Sensus, Lokomotif, Kereta, User, Vote, sequelize } = require('../models');
const { Op } = require('sequelize');
const { successResponse, errorResponse } = require('../utils/responseFormatter');
const { deleteFileSafe } = require('../utils/fileHelper');
const osmService = require('../services/osmService');

exports.getAll = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;
    const search = req.query.search || '';

    const twelveHoursAgo = new Date(Date.now() - 12 * 60 * 60 * 1000);

    const where = {
      waktu_sensus: {
        [Op.gte]: twelveHoursAgo
      }
    };

    if (search) {
      where[Op.or] = [
        { '$Lokomotif.tipe_model$': { [Op.like]: `%${search}%` } },
        { '$Lokomotif.seri_model$': { [Op.like]: `%${search}%` } },
        { '$Kereta.nama_ka$': { [Op.like]: `%${search}%` } },
        { '$Kereta.nomor_ka$': { [Op.like]: `%${search}%` } },
        { lokasi: { [Op.like]: `%${search}%` } }
      ];
    }

    const { count, rows } = await Sensus.findAndCountAll({
      where,
      include: [
        { model: Lokomotif, attributes: ['tipe_model', 'seri_model'] },
        { model: Kereta, attributes: ['nama_ka', 'nomor_ka'] },
        { model: User, attributes: ['username', 'foto_profil'] }
      ],
      limit,
      offset,
      order: [['waktu_sensus', 'DESC']]
    });

    return successResponse(res, {
      totalItems: count,
      data: rows,
      totalPages: Math.ceil(count / limit),
      currentPage: page
    }, 'Sensus feed retrieved successfully');
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};

exports.getById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const twelveHoursAgo = new Date(Date.now() - 12 * 60 * 60 * 1000);

    const sensus = await Sensus.findOne({
      where: {
        sensus_id: id,
        waktu_sensus: {
          [Op.gte]: twelveHoursAgo
        }
      },
      include: [
        { model: Lokomotif, attributes: ['tipe_model', 'seri_model'] },
        { model: Kereta, attributes: ['nama_ka', 'nomor_ka'] },
        { model: User, attributes: ['username', 'role', 'foto_profil'] },
        { 
          model: sequelize.models.GaleriSensus, 
          include: [{ model: User, as: 'uploader', attributes: ['username', 'foto_profil'] }] 
        }
      ]
    });

    if (!sensus) {
      return errorResponse(res, 'Sensus not found', 404);
    }

    // Get vote counts
    const validCount = await Vote.count({
      where: { sensus_id: id, tipe_vote: 'Valid' }
    });
    
    const invalidCount = await Vote.count({
      where: { sensus_id: id, tipe_vote: 'Invalid' }
    });

    const userVote = await Vote.findOne({
      where: { sensus_id: id, user_id: req.user.user_id }
    });

    const sensusData = sensus.toJSON();
    sensusData.total_valid = validCount;
    sensusData.total_invalid = invalidCount;
    sensusData.user_vote = userVote ? userVote.tipe_vote : null;

    return successResponse(res, sensusData, 'Sensus detail retrieved successfully');
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};

exports.create = async (req, res) => {
  try {
    const { loko_id, ka_id, latitude, longitude } = req.body;
    let foto_bukti = req.body.foto_bukti || null;
    const user_id = req.user.user_id;

    if (req.file) {
      foto_bukti = `/uploads/${req.file.filename}`;
    }

    const lokasi = await osmService.getLocationFromCoordinates(latitude, longitude);

    const lokomotif = await Lokomotif.findByPk(loko_id);
    if (!lokomotif) {
      return errorResponse(res, 'Lokomotif not found', 404);
    }
    if (lokomotif.status !== 'Siap Operasi') {
      return errorResponse(res, 'Lokomotif tidak dalam kondisi Siap Operasi dan tidak dapat disensus', 400);
    }

    const t = await sequelize.transaction();

    try {
      // Delete existing sensus for this lokomotif to ensure only the latest one exists
      const existingSensus = await Sensus.findAll({ where: { loko_id: loko_id }, transaction: t });
      for (const oldSensus of existingSensus) {
        if (oldSensus.foto_bukti) deleteFileSafe(oldSensus.foto_bukti);
        await oldSensus.destroy({ transaction: t });
      }

      const sensus = await Sensus.create({
        user_id,
        loko_id,
        ka_id,
        lokasi,
        foto_bukti,
        trust_score: 0.0
      }, { transaction: t });

      await t.commit();
      return successResponse(res, sensus, 'Sensus logged successfully', 201);
    } catch (err) {
      await t.rollback();
      throw err;
    }
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};

exports.vote = async (req, res) => {
  const t = await sequelize.transaction();
  try {
    const { id } = req.params;
    const { tipe_vote } = req.body;
    const user_id = req.user.user_id;

    const sensus = await Sensus.findByPk(id, { transaction: t });
    if (!sensus) {
      await t.rollback();
      return errorResponse(res, 'Sensus not found', 404);
    }

    const existingVote = await Vote.findOne({
      where: { sensus_id: id, user_id },
      transaction: t
    });

    if (existingVote) {
      if (existingVote.tipe_vote === tipe_vote) {
        await t.rollback();
        return errorResponse(res, 'You have already voted on this census', 400);
      }
      existingVote.tipe_vote = tipe_vote;
      await existingVote.save({ transaction: t });
    } else {
      await Vote.create({
        sensus_id: id,
        user_id,
        tipe_vote
      }, { transaction: t });
    }

    const allVotes = await Vote.findAll({
      where: { sensus_id: id },
      transaction: t
    });

    let score = 0;
    allVotes.forEach(v => {
      if (v.tipe_vote === 'Valid') score += 1;
      else if (v.tipe_vote === 'Invalid') score -= 1;
    });

    sensus.trust_score = score;
    await sensus.save({ transaction: t });

    await t.commit();
    return successResponse(res, { sensus, trust_score: score }, 'Vote recorded successfully');
  } catch (error) {
    await t.rollback();
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};

exports.addGalleryPhoto = async (req, res) => {
  try {
    const { id } = req.params;
    const user_id = req.user.user_id;

    if (!req.file) {
      return errorResponse(res, 'No photo provided', 400);
    }

    const sensus = await Sensus.findByPk(id);
    if (!sensus) {
      return errorResponse(res, 'Sensus not found', 404);
    }

    const foto_url = `/uploads/${req.file.filename}`;
    
    const galeri = await sequelize.models.GaleriSensus.create({
      sensus_id: id,
      user_id,
      foto_url
    });

    return successResponse(res, galeri, 'Photo added to gallery successfully', 201);
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};

exports.deleteGaleri = async (req, res) => {
  try {
    const { galeri_id } = req.params;
    // We use sequelize.models since GaleriSensus is imported inside associations
    const GaleriSensus = require('../models').GaleriSensus;
    const galeri = await GaleriSensus.findByPk(galeri_id);
    
    if (!galeri) {
      return errorResponse(res, 'Gallery photo not found', 404);
    }

    const user_id = req.user.user_id;
    const user_role = req.user.role;

    if (galeri.user_id !== user_id && user_role !== 'Admin') {
      return errorResponse(res, 'You are not authorized to delete this gallery photo', 403);
    }

    if (galeri.foto_url) {
      deleteFileSafe(galeri.foto_url);
    }

    await galeri.destroy();
    return successResponse(res, null, 'Gallery photo deleted successfully');
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};

exports.update = async (req, res) => {
  try {
    const { id } = req.params;
    const { loko_id, ka_id, lokasi } = req.body;
    const user_id = req.user.user_id;
    const user_role = req.user.role;

    const sensus = await Sensus.findByPk(id);
    if (!sensus) {
      return errorResponse(res, 'Sensus not found', 404);
    }

    if (sensus.user_id !== user_id && user_role !== 'Admin') {
      return errorResponse(res, 'You are not authorized to edit this census', 403);
    }

    await sensus.update({
      loko_id: loko_id || sensus.loko_id,
      ka_id: ka_id || sensus.ka_id,
      lokasi: lokasi || sensus.lokasi
    });

    return successResponse(res, sensus, 'Sensus updated successfully');
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};

exports.delete = async (req, res) => {
  try {
    const { id } = req.params;
    const user_id = req.user.user_id;
    const user_role = req.user.role;

    const sensus = await Sensus.findByPk(id);
    if (!sensus) {
      return errorResponse(res, 'Sensus not found', 404);
    }

    if (sensus.user_id !== user_id && user_role !== 'Admin') {
      return errorResponse(res, 'You are not authorized to delete this census', 403);
    }

    if (sensus.foto_bukti) {
      deleteFileSafe(sensus.foto_bukti);
    }

    await sensus.destroy();
    return successResponse(res, null, 'Sensus deleted successfully');
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};
