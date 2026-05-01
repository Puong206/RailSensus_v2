const { Depo } = require('../models');
const { successResponse, errorResponse } = require('../utils/responseFormatter');

exports.getAll = async (req, res) => {
  try {
    const depos = await Depo.findAll();
    return successResponse(res, depos, 'Depo retrieved successfully');
  } catch (error) {
    return errorResponse(res, 'Internal Server Error', 500, error.message);
  }
};
