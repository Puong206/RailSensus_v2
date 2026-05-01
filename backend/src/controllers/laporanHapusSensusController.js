const { LaporanHapusSensus, Sensus, User, Lokomotif, Kereta } = require('../models');
const { successResponse, errorResponse } = require('../utils/responseFormatter');

// POST /laporan-hapus-sensus/:sensusId — User membuat laporan permintaan hapus sensus
exports.createLaporan = async (req, res) => {
  try {
    const { sensusId } = req.params;
    const { alasan_hapus } = req.body;

    if (!alasan_hapus || alasan_hapus.trim() === '') {
      return errorResponse(res, 'Alasan penghapusan wajib diisi', 400);
    }

    const sensus = await Sensus.findByPk(sensusId);
    if (!sensus) {
      return errorResponse(res, 'Sensus tidak ditemukan', 404);
    }

    // Cek apakah laporan dengan status Menunggu sudah ada
    const existing = await LaporanHapusSensus.findOne({
      where: { sensus_id: sensusId, status_laporan: 'Menunggu' }
    });

    if (existing) {
      return errorResponse(res, 'Laporan penghapusan untuk sensus ini sudah ada dan sedang menunggu persetujuan', 409);
    }

    const laporan = await LaporanHapusSensus.create({
      sensus_id: sensusId,
      user_id: req.user.user_id,
      alasan_hapus: alasan_hapus.trim()
    });

    return successResponse(res, laporan, 'Laporan penghapusan sensus berhasil dikirim', 201);
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};

// GET /laporan-hapus-sensus — Admin melihat semua laporan (bisa filter by status)
exports.getAllLaporan = async (req, res) => {
  try {
    const { status, page = 1, limit = 10 } = req.query;
    const where = status ? { status_laporan: status } : {};

    const offset = (page - 1) * limit;

    const { count, rows } = await LaporanHapusSensus.findAndCountAll({
      where,
      limit: parseInt(limit),
      offset: parseInt(offset),
      order: [['dilaporkan_pada', 'DESC']],
      include: [
        {
          model: Sensus,
          as: 'sensus',
          include: [
            { model: Lokomotif },
            { model: Kereta }
          ]
        },
        {
          model: User,
          as: 'pelapor',
          attributes: ['user_id', 'username', 'email', 'role']
        }
      ]
    });

    return successResponse(res, {
      totalItems: count,
      data: rows,
      totalPages: Math.ceil(count / limit),
      currentPage: parseInt(page)
    }, 'Laporan retrieved successfully');
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};

// PUT /laporan-hapus-sensus/:laporanId/setujui — Admin menyetujui & langsung hapus sensus
exports.setujuiLaporan = async (req, res) => {
  try {
    const { laporanId } = req.params;

    const laporan = await LaporanHapusSensus.findByPk(laporanId, {
      include: [{ model: Sensus, as: 'sensus' }]
    });

    if (!laporan) {
      return errorResponse(res, 'Laporan tidak ditemukan', 404);
    }
    if (laporan.status_laporan !== 'Menunggu') {
      return errorResponse(res, 'Laporan ini sudah diproses sebelumnya', 400);
    }

    // Hapus sensus jika masih ada
    if (laporan.sensus) {
      await laporan.sensus.destroy();
    }

    // Update status laporan
    await laporan.update({ status_laporan: 'Disetujui' });

    return successResponse(res, laporan, 'Laporan disetujui, sensus berhasil dihapus');
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};

// PUT /laporan-hapus-sensus/:laporanId/tolak — Admin menolak laporan
exports.tolakLaporan = async (req, res) => {
  try {
    const { laporanId } = req.params;

    const laporan = await LaporanHapusSensus.findByPk(laporanId);
    if (!laporan) {
      return errorResponse(res, 'Laporan tidak ditemukan', 404);
    }
    if (laporan.status_laporan !== 'Menunggu') {
      return errorResponse(res, 'Laporan ini sudah diproses sebelumnya', 400);
    }

    await laporan.update({ status_laporan: 'Ditolak' });

    return successResponse(res, laporan, 'Laporan berhasil ditolak');
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};

// DELETE /laporan-hapus-sensus/history — Admin membersihkan riwayat laporan
exports.clearHistory = async (req, res) => {
  try {
    const { status } = req.query;
    if (!status || !['Disetujui', 'Ditolak'].includes(status)) {
      return errorResponse(res, 'Status tidak valid atau tidak diberikan', 400);
    }
    await LaporanHapusSensus.destroy({
      where: {
        status_laporan: status
      }
    });

    return successResponse(res, null, `Riwayat laporan ${status} berhasil dibersihkan`);
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};
