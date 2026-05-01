const Joi = require('joi');

const lokomotifSchema = Joi.object({
  tipe_model: Joi.string().required(),
  seri_model: Joi.string().required(),
  depo_id: Joi.number().required(),
  livery: Joi.string().required(),
  keterangan: Joi.string().allow('', null).default(''),
  status: Joi.string().valid('Siap Operasi', 'Tidak Siap Operasi').default('Siap Operasi'),
  sumber_tenaga: Joi.string().valid('Diesel Elektrik', 'Diesel Hidrolik', 'Listrik', 'Uap').required()
});

module.exports = {
  lokomotifSchema
};
