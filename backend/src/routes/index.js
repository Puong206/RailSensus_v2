const express = require('express');
const router = express.Router();

const authRoutes = require('./authRoutes');
const lokomotifRoutes = require('./lokomotifRoutes');
const keretaRoutes = require('./keretaRoutes');
const sensusRoutes = require('./sensusRoutes');
const adminRoutes = require('./adminRoutes');
const depoRoutes = require('./depoRoutes');
const laporanHapusRoutes = require('./laporanHapusRoutes');
const laporanHapusSensusRoutes = require('./laporanHapusSensusRoutes');

router.use('/auth', authRoutes);
router.use('/lokomotif', lokomotifRoutes);
router.use('/kereta', keretaRoutes);
router.use('/sensus', sensusRoutes);
router.use('/admin', adminRoutes);
router.use('/depo', depoRoutes);
router.use('/laporan-hapus', laporanHapusRoutes);
router.use('/laporan-hapus-sensus', laporanHapusSensusRoutes);

module.exports = router;
