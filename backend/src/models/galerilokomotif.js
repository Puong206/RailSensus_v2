'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class GaleriLokomotif extends Model {
    static associate(models) {
      GaleriLokomotif.belongsTo(models.Lokomotif, { foreignKey: 'loko_id', as: 'lokomotif' });
      GaleriLokomotif.belongsTo(models.User, { foreignKey: 'user_id', as: 'uploader' });
    }
  }
  GaleriLokomotif.init({
    galeri_id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true
    },
    loko_id: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    user_id: {
      type: DataTypes.INTEGER,
      allowNull: true // Allow null for existing records
    },
    foto_url: {
      type: DataTypes.STRING,
      allowNull: false
    },
    ditambahkan_pada: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    }
  }, {
    sequelize,
    modelName: 'GaleriLokomotif',
    tableName: 'galeri_lokomotif',
    timestamps: false
  });
  return GaleriLokomotif;
};
