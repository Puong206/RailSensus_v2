'use strict';
/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('Sensus', {
      sensus_id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      user_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'Users',
          key: 'user_id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      loko_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'Lokomotifs',
          key: 'loko_id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      ka_id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'Keretas',
          key: 'ka_id'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      trust_score: {
        type: Sequelize.FLOAT,
        defaultValue: 0.0
      },
      lokasi: {
        type: Sequelize.STRING
      },
      foto_bukti: {
        type: Sequelize.STRING
      },
      waktu_sensus: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      }
    });
  },
  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('Sensus');
  }
};
