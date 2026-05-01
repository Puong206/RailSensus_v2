const { User } = require('../models');
const { Op } = require('sequelize');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { successResponse, errorResponse } = require('../utils/responseFormatter');
const { deleteFileSafe } = require('../utils/fileHelper');

exports.register = async (req, res) => {
  try {
    const { username, email, password } = req.body;
    
    const existingUsername = await User.findOne({ where: { username } });
    if (existingUsername) {
      return errorResponse(res, 'Username sudah digunakan', 400);
    }

    const existingEmail = await User.findOne({ where: { email } });
    if (existingEmail) {
      return errorResponse(res, 'Email sudah terdaftar', 400);
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const user = await User.create({
      username,
      email,
      password: hashedPassword,
      role: 'User'
    });

    const userData = user.toJSON();
    delete userData.password;

    return successResponse(res, userData, 'Registrasi berhasil', 201);
  } catch (error) {
    return errorResponse(res, 'Terjadi kesalahan server', 500, error.message);
  }
};

exports.login = async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return errorResponse(res, 'Username dan password wajib diisi', 400);
    }

    const user = await User.findOne({ where: { username } });
    if (!user) {
      return errorResponse(res, 'Username tidak ditemukan', 401);
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return errorResponse(res, 'Password salah', 401);
    }

    const payload = {
      user_id: user.user_id,
      role: user.role
    };

    const token = jwt.sign(payload, process.env.JWT_SECRET, {
      expiresIn: process.env.JWT_EXPIRES_IN || '24h'
    });

    const userData = user.toJSON();
    delete userData.password;

    return successResponse(res, { token, user: userData }, 'Login berhasil');
  } catch (error) {
    return errorResponse(res, 'Terjadi kesalahan server', 500, error.message);
  }
};

exports.updateProfile = async (req, res) => {
  try {
    const { username, email } = req.body;
    const userId = req.user.user_id;

    // Check username duplication
    const existingUsername = await User.findOne({
      where: { username, user_id: { [Op.ne]: userId } }
    });
    if (existingUsername) {
      return errorResponse(res, 'Username sudah digunakan oleh pengguna lain', 400);
    }

    // Check email duplication
    const existingEmail = await User.findOne({
      where: { email, user_id: { [Op.ne]: userId } }
    });
    if (existingEmail) {
      return errorResponse(res, 'Email sudah digunakan oleh pengguna lain', 400);
    }

    const user = await User.findByPk(userId);
    if (!user) return errorResponse(res, 'User tidak ditemukan', 404);

    await user.update({ username, email });

    const userData = user.toJSON();
    delete userData.password;

    return successResponse(res, userData, 'Profil berhasil diperbarui');
  } catch (error) {
    return errorResponse(res, 'Terjadi kesalahan server', 500, error.message);
  }
};

exports.changePassword = async (req, res) => {
  try {
    const { old_password, new_password } = req.body;
    const userId = req.user.user_id;

    const user = await User.findByPk(userId);
    if (!user) return errorResponse(res, 'User tidak ditemukan', 404);

    const isMatch = await bcrypt.compare(old_password, user.password);
    if (!isMatch) {
      return errorResponse(res, 'Password lama tidak sesuai', 400);
    }

    const hashedPassword = await bcrypt.hash(new_password, 10);
    await user.update({ password: hashedPassword });

    return successResponse(res, null, 'Password berhasil diubah');
  } catch (error) {
    return errorResponse(res, 'Terjadi kesalahan server', 500, error.message);
  }
};

exports.getMe = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const user = await User.findByPk(userId);
    if (!user) return errorResponse(res, 'User tidak ditemukan', 404);

    const userData = user.toJSON();
    delete userData.password;
    
    return successResponse(res, userData, 'Profil berhasil diambil');
  } catch (error) {
    return errorResponse(res, 'Terjadi kesalahan server', 500, error.message);
  }
};

exports.uploadProfilePhoto = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const user = await User.findByPk(userId);
    
    if (!user) return errorResponse(res, 'User tidak ditemukan', 404);

    if (!req.file) {
      return errorResponse(res, 'Foto tidak ditemukan', 400);
    }

    if (user.foto_profil) {
      deleteFileSafe(user.foto_profil);
    }

    const fotoUrl = `/uploads/${req.file.filename}`;
    await user.update({ foto_profil: fotoUrl });

    const userData = user.toJSON();
    delete userData.password;

    return successResponse(res, userData, 'Foto profil berhasil diunggah');
  } catch (error) {
    return errorResponse(res, 'Terjadi kesalahan server', 500, error.message);
  }
};

exports.deleteProfilePhoto = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const user = await User.findByPk(userId);
    
    if (!user) return errorResponse(res, 'User tidak ditemukan', 404);

    if (user.foto_profil) {
      deleteFileSafe(user.foto_profil);
    }

    await user.update({ foto_profil: null });

    const userData = user.toJSON();
    delete userData.password;

    return successResponse(res, userData, 'Foto profil berhasil dihapus');
  } catch (error) {
    return errorResponse(res, 'Terjadi kesalahan server', 500, error.message);
  }
};

exports.getUserGallery = async (req, res) => {
  try {
    const userId = req.user.user_id;
    const { GaleriLokomotif } = require('../models');

    // Fetch photos uploaded by the user from GaleriLokomotif
    const gallery = await GaleriLokomotif.findAll({
      where: { user_id: userId },
      order: [['ditambahkan_pada', 'DESC']]
    });

    return successResponse(res, gallery, 'Galeri pengguna berhasil diambil');
  } catch (error) {
    return errorResponse(res, 'Terjadi kesalahan server', 500, error.message);
  }
};
