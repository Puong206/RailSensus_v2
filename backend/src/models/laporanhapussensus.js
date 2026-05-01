'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class LaporanHapusSensus extends Model {
    static associate(models) {
      LaporanHapusSensus.belongsTo(models.Sensus, { foreignKey: 'sensus_id', as: 'sensus' });
      LaporanHapusSensus.belongsTo(models.User, { foreignKey: 'user_id', as: 'pelapor' });
    }
  }
  LaporanHapusSensus.init({
    laporan_id: {
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
    alasan_hapus: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    status_laporan: {
      type: DataTypes.ENUM('Menunggu', 'Disetujui', 'Ditolak'),
      defaultValue: 'Menunggu'
    },
    dilaporkan_pada: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    }
  }, {
    sequelize,
    modelName: 'LaporanHapusSensus',
    tableName: 'laporan_hapus_sensus',
    timestamps: false
  });
  return LaporanHapusSensus;
};
