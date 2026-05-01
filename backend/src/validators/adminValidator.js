const Joi = require('joi');

const keretaSchema = Joi.object({
  nama_ka: Joi.string().required(),
  nomor_ka: Joi.string().required()
});

const depoSchema = Joi.object({
  kode_depo: Joi.string().required(),
  nama_depo: Joi.string().required()
});

const userUpdateSchema = Joi.object({
  username: Joi.string().required(),
  email: Joi.string().email().required(),
  role: Joi.string().valid('Admin', 'User').required(),
  password: Joi.string().min(6).allow('', null)
});

module.exports = {
  keretaSchema,
  depoSchema,
  userUpdateSchema
};
