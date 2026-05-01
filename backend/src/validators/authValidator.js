const Joi = require('joi');

const authRegisterSchema = Joi.object({
  username: Joi.string().min(3).max(30).required(),
  email: Joi.string().email().required(),
  password: Joi.string().min(6).required()
});

const authLoginSchema = Joi.object({
  username: Joi.string().required(),
  password: Joi.string().required()
});

const updateProfileSchema = Joi.object({
  username: Joi.string().min(3).max(30).required(),
  email: Joi.string().email().required()
});

const changePasswordSchema = Joi.object({
  old_password: Joi.string().required(),
  new_password: Joi.string().min(6).required()
});

module.exports = {
  authRegisterSchema,
  authLoginSchema,
  updateProfileSchema,
  changePasswordSchema
};
