'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Depo extends Model {
    static associate(models) {
      Depo.hasMany(models.Lokomotif, { foreignKey: 'depo_id' });
    }
  }
  Depo.init({
    depo_id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true
    },
    kode_depo: {
      type: DataTypes.STRING(10),
      allowNull: false
    },
    nama_depo: {
      type: DataTypes.STRING(100),
      allowNull: false
    }
  }, {
    sequelize,
    modelName: 'Depo',
    tableName: 'depo',
    timestamps: false
  });
  return Depo;
};
