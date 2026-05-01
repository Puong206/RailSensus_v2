const express = require('express');
const router = express.Router();
const laporanHapusSensusController = require('../controllers/laporanHapusSensusController');
const auth = require('../middlewares/auth');

// Semua route dilindungi
router.use(auth);

// User: kirim laporan hapus untuk sensus tertentu
router.post('/:sensusId', laporanHapusSensusController.createLaporan);

// Admin: lihat semua laporan (bisa filter: ?status=Menunggu)
router.get('/', laporanHapusSensusController.getAllLaporan);
router.delete('/history', laporanHapusSensusController.clearHistory);

// Admin: setujui laporan (dan hapus sensus)
router.put('/:laporanId/setujui', laporanHapusSensusController.setujuiLaporan);

// Admin: tolak laporan
router.put('/:laporanId/tolak', laporanHapusSensusController.tolakLaporan);

module.exports = router;
