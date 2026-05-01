const { Lokomotif, Depo, GaleriLokomotif } = require('../models');
const { successResponse, errorResponse } = require('../utils/responseFormatter');
const { Op } = require('sequelize');
const { deleteFileSafe } = require('../utils/fileHelper');

exports.getAll = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;
    const search = req.query.search || '';

    const where = search ? {
      [Op.or]: [
        { tipe_model: { [Op.like]: `%${search}%` } },
        { seri_model: { [Op.like]: `%${search}%` } }
      ]
    } : {};

    const { count, rows } = await Lokomotif.findAndCountAll({
      where,
      limit,
      offset,
      distinct: true,
      order: [['loko_id', 'DESC']],
      include: [
        { model: Depo, as: 'depo' },
        { model: GaleriLokomotif, as: 'galeri' },
        { model: require('../models').User, as: 'creator', attributes: ['username', 'foto_profil'] }
      ]
    });

    return successResponse(res, {
      totalItems: count,
      data: rows,
      totalPages: Math.ceil(count / limit),
      currentPage: page
    }, 'Lokomotif retrieved successfully');
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};

exports.getById = async (req, res) => {
  try {
    const { id } = req.params;
    const lokomotif = await Lokomotif.findByPk(id, {
      include: [
        { model: Depo, as: 'depo' },
        { model: GaleriLokomotif, as: 'galeri' },
        { model: require('../models').User, as: 'creator', attributes: ['username', 'foto_profil'] }
      ]
    });
    
    if (!lokomotif) {
      return errorResponse(res, 'Lokomotif not found', 404);
    }
    
    return successResponse(res, lokomotif, 'Lokomotif retrieved successfully');
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};

exports.create = async (req, res) => {
  try {
    const data = { ...req.body };
    data.created_by = req.user.user_id;
    if (req.file) {
      data.foto_url = `/uploads/${req.file.filename}`;
    }
    const lokomotif = await Lokomotif.create(data);
    return successResponse(res, lokomotif, 'Lokomotif created successfully', 201);
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};

exports.update = async (req, res) => {
  try {
    const { id } = req.params;
    const lokomotif = await Lokomotif.findByPk(id);
    
    if (!lokomotif) {
      return errorResponse(res, 'Lokomotif not found', 404);
    }

    if (req.user.role !== 'Admin' && lokomotif.created_by !== req.user.user_id) {
      return errorResponse(res, 'Forbidden: You do not have permission to edit this data', 403);
    }

    const data = { ...req.body };
    if (req.file) {
      if (lokomotif.foto_url) {
        deleteFileSafe(lokomotif.foto_url);
      }
      data.foto_url = `/uploads/${req.file.filename}`;
    }

    await lokomotif.update(data);
    return successResponse(res, lokomotif, 'Lokomotif updated successfully');
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};

exports.delete = async (req, res) => {
  try {
    const { id } = req.params;
    const lokomotif = await Lokomotif.findByPk(id);
    
    if (!lokomotif) {
      return errorResponse(res, 'Lokomotif not found', 404);
    }

    const user_id = req.user.user_id;
    const user_role = req.user.role;

    if (lokomotif.created_by !== user_id && user_role !== 'Admin') {
      return errorResponse(res, 'You are not authorized to delete this lokomotif', 403);
    }

    if (lokomotif.foto_url) {
      deleteFileSafe(lokomotif.foto_url);
    }

    await lokomotif.destroy();
    return successResponse(res, null, 'Lokomotif deleted successfully');
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};

exports.uploadGaleri = async (req, res) => {
  try {
    const { id } = req.params;
    const lokomotif = await Lokomotif.findByPk(id);
    
    if (!lokomotif) {
      return errorResponse(res, 'Lokomotif not found', 404);
    }

    if (!req.file) {
      return errorResponse(res, 'No image provided', 400);
    }

    const galeri = await GaleriLokomotif.create({
      loko_id: id,
      user_id: req.user.user_id,
      foto_url: `/uploads/${req.file.filename}`
    });

    return successResponse(res, galeri, 'Gallery photo added successfully', 201);
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};

exports.deleteGaleri = async (req, res) => {
  try {
    const { galeri_id } = req.params;
    const galeri = await GaleriLokomotif.findByPk(galeri_id);
    
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
