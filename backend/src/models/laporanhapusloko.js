'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class LaporanHapusLoko extends Model {
    static associate(models) {
      LaporanHapusLoko.belongsTo(models.Lokomotif, { foreignKey: 'loko_id', as: 'lokomotif' });
      LaporanHapusLoko.belongsTo(models.User, { foreignKey: 'user_id', as: 'pelapor' });
    }
  }
  LaporanHapusLoko.init({
    laporan_id: {
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
    modelName: 'LaporanHapusLoko',
    tableName: 'laporan_hapus_loko',
    timestamps: false
  });
  return LaporanHapusLoko;
};
