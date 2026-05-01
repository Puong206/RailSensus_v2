const { errorResponse } = require('../utils/responseFormatter');

module.exports = (schema) => {
  return (req, res, next) => {
    // stripUnknown removes fields not in schema (e.g. file fields from multer)
    const { error, value } = schema.validate(req.body, { abortEarly: false, stripUnknown: true });
    if (error) {
      const errors = {};
      error.details.forEach((detail) => {
        errors[detail.context.key] = detail.message;
      });
      return errorResponse(res, 'Validation Error', 400, errors);
    }
    // Replace req.body with validated & cleaned value (applies defaults like status)
    req.body = value;
    next();
  };
};
