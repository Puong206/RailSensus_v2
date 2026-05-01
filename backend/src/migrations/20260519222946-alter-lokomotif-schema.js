'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    // We add tipe_model and seri_model
    await queryInterface.addColumn('lokomotif', 'tipe_model', {
      type: Sequelize.STRING,
      allowNull: false,
      defaultValue: '' // or whatever to allow migrating existing rows
    });
    await queryInterface.addColumn('lokomotif', 'seri_model', {
      type: Sequelize.STRING,
      allowNull: false,
      defaultValue: ''
    });

    // We can try to populate them if we wanted, but dropping nomor_seri is fine if we don't care about old data or it's just testing
    await queryInterface.removeColumn('lokomotif', 'nomor_seri');
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.addColumn('lokomotif', 'nomor_seri', {
      type: Sequelize.STRING,
      allowNull: false,
      defaultValue: ''
    });
    await queryInterface.removeColumn('lokomotif', 'tipe_model');
    await queryInterface.removeColumn('lokomotif', 'seri_model');
  }
};
