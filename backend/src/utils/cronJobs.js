const cron = require('node-cron');
const { Op } = require('sequelize');
const { Sensus, GaleriSensus, Vote, LaporanHapusSensus, sequelize } = require('../models');

// Schedule tasks to be run on the server.
const initCronJobs = () => {
  // Run every 10 minutes: "*/10 * * * *"
  cron.schedule('*/10 * * * *', async () => {
    const transaction = await sequelize.transaction();
    try {
      console.log('[CronJob] Running cleanup for old sensus records...');
      
      const twelveHoursAgo = new Date(Date.now() - 12 * 60 * 60 * 1000);
      
      // Find old sensus records first
      const oldSensusRecords = await Sensus.findAll({
        attributes: ['sensus_id'],
        where: {
          waktu_sensus: {
            [Op.lt]: twelveHoursAgo
          }
        },
        transaction
      });

      if (oldSensusRecords.length === 0) {
        console.log('[CronJob] No old sensus records found to delete.');
        await transaction.commit();
        return;
      }

      const sensusIds = oldSensusRecords.map(s => s.sensus_id);
      console.log(`[CronJob] Found ${sensusIds.length} old sensus record(s) to delete.`);

      // Delete child records first to avoid foreign key constraint errors
      await GaleriSensus.destroy({
        where: { sensus_id: { [Op.in]: sensusIds } },
        transaction
      });

      await Vote.destroy({
        where: { sensus_id: { [Op.in]: sensusIds } },
        transaction
      });

      await LaporanHapusSensus.destroy({
        where: { sensus_id: { [Op.in]: sensusIds } },
        transaction
      });

      // Now delete the parent sensus records
      const deletedCount = await Sensus.destroy({
        where: { sensus_id: { [Op.in]: sensusIds } },
        transaction
      });

      await transaction.commit();
      console.log(`[CronJob] Successfully deleted ${deletedCount} sensus record(s) older than 12 hours.`);
    } catch (error) {
      await transaction.rollback();
      console.error('[CronJob] Error during sensus cleanup:', error);
    }
  });

  console.log('[CronJob] Cron jobs initialized successfully.');
};

module.exports = initCronJobs;
