'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class GaleriSensus extends Model {
    static associate(models) {
      GaleriSensus.belongsTo(models.Sensus, { foreignKey: 'sensus_id' });
      GaleriSensus.belongsTo(models.User, { foreignKey: 'user_id', as: 'uploader' });
    }
  }
  GaleriSensus.init({
    galeri_id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true
    },
    sensus_id: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    user_id: {
      type: DataTypes.INTEGER,
      allowNull: false
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
    modelName: 'GaleriSensus',
    tableName: 'galeri_sensus',
    timestamps: false
  });
  return GaleriSensus;
};
