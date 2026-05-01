const { errorResponse } = require('../utils/responseFormatter');

module.exports = (req, res, next) => {
  if (req.user && req.user.role === 'Admin') {
    next();
  } else {
    return errorResponse(res, 'Access denied. Admin privileges required.', 403);
  }
};
