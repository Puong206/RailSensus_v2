'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Vote extends Model {
    static associate(models) {
      Vote.belongsTo(models.Sensus, { foreignKey: 'sensus_id' });
      Vote.belongsTo(models.User, { foreignKey: 'user_id' });
    }
  }
  Vote.init({
    vote_id: {
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
    tipe_vote: {
      type: DataTypes.ENUM('Valid', 'Invalid'),
      allowNull: false
    },
    waktu_vote: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    }
  }, {
    sequelize,
    modelName: 'Vote',
    tableName: 'votes',
    timestamps: false,
    indexes: [
      {
        unique: true,
        fields: ['sensus_id', 'user_id']
      }
    ]
  });
  return Vote;
};
