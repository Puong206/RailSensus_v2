const express = require('express');
const router = express.Router();
const sensusController = require('../controllers/sensusController');
const auth = require('../middlewares/auth');
const validate = require('../middlewares/validate');
const { sensusSchema, sensusUpdateSchema, voteSchema } = require('../validators/sensusValidator');
const upload = require('../middlewares/upload');

// All sensus routes are protected
router.use(auth);

router.get('/', sensusController.getAll);
router.get('/:id', sensusController.getById);
router.post('/', upload.single('foto_bukti'), validate(sensusSchema), sensusController.create);
router.post('/:id/vote', validate(voteSchema), sensusController.vote);
router.post('/:id/galeri', upload.single('foto_galeri'), sensusController.addGalleryPhoto);
router.put('/:id', validate(sensusUpdateSchema), sensusController.update);
router.delete('/:id', sensusController.delete);
router.delete('/galeri/:galeri_id', sensusController.deleteGaleri);

module.exports = router;
