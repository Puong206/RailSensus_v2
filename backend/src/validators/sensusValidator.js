const Joi = require('joi');

const sensusSchema = Joi.object({
  loko_id: Joi.number().integer().required(),
  ka_id: Joi.number().integer().required(),
  latitude: Joi.number().min(-90).max(90).required(),
  longitude: Joi.number().min(-180).max(180).required(),
  foto_bukti: Joi.string().allow('', null)
});

const sensusUpdateSchema = Joi.object({
  loko_id: Joi.number().integer().optional(),
  ka_id: Joi.number().integer().optional(),
  lokasi: Joi.string().allow('', null).optional()
});

const voteSchema = Joi.object({
  tipe_vote: Joi.string().valid('Valid', 'Invalid').required()
});

module.exports = {
  sensusSchema,
  sensusUpdateSchema,
  voteSchema
};
