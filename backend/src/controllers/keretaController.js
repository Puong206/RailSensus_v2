const { Kereta } = require('../models');
const { successResponse, errorResponse } = require('../utils/responseFormatter');

exports.getAll = async (req, res) => {
  try {
    const keretas = await Kereta.findAll({
      attributes: ['ka_id', 'nama_ka', 'nomor_ka'],
      order: [['nama_ka', 'ASC']]
    });

    return successResponse(res, keretas, 'Kereta feed retrieved successfully');
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};
