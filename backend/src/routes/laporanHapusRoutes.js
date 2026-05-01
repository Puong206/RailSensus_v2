const express = require('express');
const router = express.Router();
const laporanHapusController = require('../controllers/laporanHapusController');
const auth = require('../middlewares/auth');

// Semua route dilindungi
router.use(auth);

// User: kirim laporan hapus untuk lokomotif tertentu
router.post('/:lokoId', laporanHapusController.createLaporan);

// Admin: lihat semua laporan (bisa filter: ?status=Menunggu)
router.get('/', laporanHapusController.getAllLaporan);

router.delete('/history', laporanHapusController.clearHistory);

// Admin: setujui laporan (dan hapus lokomotif)
router.put('/:laporanId/setujui', laporanHapusController.setujuiLaporan);

// Admin: tolak laporan
router.put('/:laporanId/tolak', laporanHapusController.tolakLaporan);

module.exports = router;
