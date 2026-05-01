'use strict';
/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('Lokomotifs', {
      loko_id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      nomor_seri: {
        type: Sequelize.STRING,
        allowNull: false
      },
      dipo_induk: {
        type: Sequelize.STRING,
        allowNull: false
      },
      livery: {
        type: Sequelize.STRING,
        allowNull: false
      },
      keterangan: {
        type: Sequelize.TEXT
      },
      foto_url: {
        type: Sequelize.STRING
      },
      status: {
        type: Sequelize.STRING,
        defaultValue: 'Siap Operasi'
      }
    });
  },
  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('Lokomotifs');
  }
};
