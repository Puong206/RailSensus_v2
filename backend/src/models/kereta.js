'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Kereta extends Model {
    static associate(models) {
      Kereta.hasMany(models.Sensus, { foreignKey: 'ka_id' });
    }
  }
  Kereta.init({
    ka_id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true
    },
    nama_ka: {
      type: DataTypes.STRING,
      allowNull: false
    },
    nomor_ka: {
      type: DataTypes.STRING,
      allowNull: false
    }
  }, {
    sequelize,
    modelName: 'Kereta',
    tableName: 'kereta',
    timestamps: false
  });
  return Kereta;
};
