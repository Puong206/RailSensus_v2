'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Lokomotif extends Model {
    static associate(models) {
      Lokomotif.hasMany(models.Sensus, { foreignKey: 'loko_id' });
      Lokomotif.belongsTo(models.Depo, { foreignKey: 'depo_id', as: 'depo' });
      Lokomotif.hasMany(models.GaleriLokomotif, { foreignKey: 'loko_id', as: 'galeri' });
      Lokomotif.belongsTo(models.User, { foreignKey: 'created_by', as: 'creator' });
    }
  }
  Lokomotif.init({
    loko_id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true
    },
    tipe_model: {
      type: DataTypes.STRING,
      allowNull: false
    },
    seri_model: {
      type: DataTypes.STRING,
      allowNull: false
    },
    depo_id: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    livery: {
      type: DataTypes.STRING,
      allowNull: true
    },
    keterangan: {
      type: DataTypes.TEXT
    },
    foto_url: {
      type: DataTypes.STRING
    },
    status: {
      type: DataTypes.STRING,
      defaultValue: 'Siap Operasi'
    },
    sumber_tenaga: {
      type: DataTypes.ENUM('Diesel Elektrik', 'Diesel Hidrolik', 'Listrik', 'Uap'),
      allowNull: true
    },
    created_by: {
      type: DataTypes.INTEGER,
      allowNull: true
    }
  }, {
    sequelize,
    modelName: 'Lokomotif',
    tableName: 'lokomotif',
    timestamps: false
  });
  return Lokomotif;
};
