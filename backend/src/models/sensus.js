'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Sensus extends Model {
    static associate(models) {
      Sensus.belongsTo(models.User, { foreignKey: 'user_id' });
      Sensus.belongsTo(models.Lokomotif, { foreignKey: 'loko_id' });
      Sensus.belongsTo(models.Kereta, { foreignKey: 'ka_id' });
      Sensus.hasMany(models.Vote, { foreignKey: 'sensus_id' });
      Sensus.hasMany(models.GaleriSensus, { foreignKey: 'sensus_id' });
      Sensus.hasMany(models.LaporanHapusSensus, { foreignKey: 'sensus_id' });
    }
  }
  Sensus.init({
    sensus_id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true
    },
    user_id: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    loko_id: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    ka_id: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    trust_score: {
      type: DataTypes.FLOAT,
      defaultValue: 0.0
    },
    lokasi: {
      type: DataTypes.STRING
    },
    foto_bukti: {
      type: DataTypes.STRING
    },
    waktu_sensus: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    }
  }, {
    sequelize,
    modelName: 'Sensus',
    tableName: 'sensus',
    timestamps: false
  });
  return Sensus;
};
