const { Kereta, User, Depo, Lokomotif, Sensus, LaporanHapusLoko, LaporanHapusSensus } = require('../models');
const { successResponse, errorResponse } = require('../utils/responseFormatter');
const { Op } = require('sequelize');
const bcrypt = require('bcrypt');

// =======================
// DASHBOARD STATS
// =======================

exports.getAdminStats = async (req, res) => {
  try {
    const totalUsers = await User.count();
    const totalSensus = await Sensus.count();
    
    const totalLaporanLoko = await LaporanHapusLoko.count({ where: { status_laporan: 'Menunggu' } });
    const totalLaporanSensus = await LaporanHapusSensus.count({ where: { status_laporan: 'Menunggu' } });
    const totalLaporan = totalLaporanLoko + totalLaporanSensus;

    return successResponse(res, {
      totalUsers,
      totalSensus,
      totalLaporan
    }, 'Admin stats retrieved successfully');
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};

// =======================
// KERETA CRUDS
// =======================

exports.getAllKereta = async (req, res) => {
  try {
    const { search } = req.query;
    let whereClause = {};

    if (search) {
      whereClause = {
        [Op.or]: [
          { nama_ka: { [Op.like]: `%${search}%` } },
          { nomor_ka: { [Op.like]: `%${search}%` } }
        ]
      };
    }

    const keretas = await Kereta.findAll({
      where: whereClause,
      order: [['nama_ka', 'ASC']]
    });
    return successResponse(res, keretas, 'Kereta retrieved successfully');
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};

exports.createKereta = async (req, res) => {
  try {
    const { nama_ka, nomor_ka } = req.body;

    let numbersToCheck = [];
    if (nomor_ka.includes(',')) {
      numbersToCheck = nomor_ka.split(',').map(n => n.trim()).filter(n => n);
      if (numbersToCheck.length === 0) {
        return errorResponse(res, 'Nomor kereta tidak boleh kosong', 400);
      }
    } else {
      numbersToCheck = [nomor_ka.trim()];
    }

    // Check if any of these numbers already exist
    const existing = await Kereta.findAll({
      where: { nomor_ka: { [Op.in]: numbersToCheck } }
    });

    if (existing.length > 0) {
      const existingNumbers = existing.map(k => k.nomor_ka).join(', ');
      return errorResponse(res, `Nomor kereta sudah terdaftar: ${existingNumbers}`, 400);
    }

    if (nomor_ka.includes(',')) {
      const records = numbersToCheck.map(num => ({ nama_ka, nomor_ka: num }));
      const keretas = await Kereta.bulkCreate(records);
      return successResponse(res, keretas, 'Kereta created successfully', 201);
    }

    const kereta = await Kereta.create(req.body);
    return successResponse(res, kereta, 'Kereta created successfully', 201);
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};

exports.updateKereta = async (req, res) => {
  try {
    const { id } = req.params;
    const { nomor_ka } = req.body;
    const kereta = await Kereta.findByPk(id);
    
    if (!kereta) {
      return errorResponse(res, 'Kereta not found', 404);
    }

    if (nomor_ka && nomor_ka.trim() !== kereta.nomor_ka) {
      const existing = await Kereta.findOne({ where: { nomor_ka: nomor_ka.trim() } });
      if (existing) {
        return errorResponse(res, `Nomor kereta ${nomor_ka} sudah terdaftar pada KA ${existing.nama_ka}`, 400);
      }
    }

    await kereta.update(req.body);
    return successResponse(res, kereta, 'Kereta updated successfully');
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};

exports.deleteKereta = async (req, res) => {
  try {
    const { id } = req.params;
    const kereta = await Kereta.findByPk(id);
    
    if (!kereta) {
      return errorResponse(res, 'Kereta not found', 404);
    }

    await kereta.destroy();
    return successResponse(res, null, 'Kereta deleted successfully');
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};

// =======================
// DEPO CRUDS
// =======================

exports.getAllDepo = async (req, res) => {
  try {
    const { search } = req.query;
    let whereClause = {};

    if (search) {
      whereClause = {
        [Op.or]: [
          { kode_depo: { [Op.like]: `%${search}%` } },
          { nama_depo: { [Op.like]: `%${search}%` } }
        ]
      };
    }

    const depos = await Depo.findAll({
      where: whereClause,
      order: [['nama_depo', 'ASC']]
    });
    return successResponse(res, depos, 'Depo retrieved successfully');
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};

exports.createDepo = async (req, res) => {
  try {
    const { kode_depo, nama_depo } = req.body;

    const existing = await Depo.findOne({
      where: {
        [Op.or]: [
          { kode_depo: kode_depo.trim() },
          { nama_depo: nama_depo.trim() }
        ]
      }
    });

    if (existing) {
      if (existing.kode_depo.toLowerCase() === kode_depo.trim().toLowerCase()) {
        return errorResponse(res, `Kode depo ${kode_depo} sudah terdaftar`, 400);
      } else {
        return errorResponse(res, `Nama depo ${nama_depo} sudah terdaftar`, 400);
      }
    }

    const depo = await Depo.create(req.body);
    return successResponse(res, depo, 'Depo created successfully', 201);
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};

exports.updateDepo = async (req, res) => {
  try {
    const { id } = req.params;
    const { kode_depo, nama_depo } = req.body;
    const depo = await Depo.findByPk(id);
    
    if (!depo) {
      return errorResponse(res, 'Depo not found', 404);
    }

    const existing = await Depo.findOne({
      where: {
        depo_id: { [Op.ne]: id },
        [Op.or]: [
          { kode_depo: kode_depo ? kode_depo.trim() : '' },
          { nama_depo: nama_depo ? nama_depo.trim() : '' }
        ]
      }
    });

    if (existing) {
      if (kode_depo && existing.kode_depo.toLowerCase() === kode_depo.trim().toLowerCase()) {
        return errorResponse(res, `Kode depo ${kode_depo} sudah terdaftar`, 400);
      } else if (nama_depo && existing.nama_depo.toLowerCase() === nama_depo.trim().toLowerCase()) {
        return errorResponse(res, `Nama depo ${nama_depo} sudah terdaftar`, 400);
      }
    }

    await depo.update(req.body);
    return successResponse(res, depo, 'Depo updated successfully');
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};

exports.deleteDepo = async (req, res) => {
  try {
    const { id } = req.params;
    const depo = await Depo.findByPk(id);
    
    if (!depo) {
      return errorResponse(res, 'Depo not found', 404);
    }

    await depo.destroy();
    return successResponse(res, null, 'Depo deleted successfully');
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};

// =======================
// USERS RUDS
// =======================

exports.getAllUsers = async (req, res) => {
  try {
    const { search } = req.query;
    let whereClause = {};

    if (search) {
      whereClause = {
        [Op.or]: [
          { username: { [Op.like]: `%${search}%` } },
          { email: { [Op.like]: `%${search}%` } }
        ]
      };
    }

    const users = await User.findAll({
      where: whereClause,
      attributes: { exclude: ['password'] },
      order: [['created_at', 'DESC']]
    });
    return successResponse(res, users, 'Users retrieved successfully');
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};

exports.updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const { username, email, role, password } = req.body;

    const user = await User.findByPk(id);
    if (!user) {
      return errorResponse(res, 'User not found', 404);
    }

    const updateData = { username, email, role };
    
    // Hash new password if provided
    if (password && password.trim() !== '') {
      updateData.password = await bcrypt.hash(password, 10);
    }

    await user.update(updateData);

    const userData = user.toJSON();
    delete userData.password;

    return successResponse(res, userData, 'User updated successfully');
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};

exports.deleteUser = async (req, res) => {
  try {
    const { id } = req.params;
    const user = await User.findByPk(id);
    
    if (!user) {
      return errorResponse(res, 'User not found', 404);
    }
    
    if (user.role === 'Admin' && user.user_id === req.user.user_id) {
      return errorResponse(res, 'You cannot delete your own admin account', 400);
    }

    await user.destroy();
    return successResponse(res, null, 'User deleted successfully');
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};
