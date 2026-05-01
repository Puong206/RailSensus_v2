const express = require('express');
const router = express.Router();
const lokomotifController = require('../controllers/lokomotifController');
const auth = require('../middlewares/auth');
const validate = require('../middlewares/validate');
const { lokomotifSchema } = require('../validators/lokomotifValidator');
const upload = require('../middlewares/upload');

// All lokomotif routes are protected
router.use(auth);

router.get('/', lokomotifController.getAll);
router.get('/:id', lokomotifController.getById);
router.post('/', upload.single('foto'), validate(lokomotifSchema), lokomotifController.create);
router.put('/:id', upload.single('foto'), validate(lokomotifSchema), lokomotifController.update);
router.delete('/:id', lokomotifController.delete);

// Galeri routes
router.post('/:id/galeri', upload.single('foto'), lokomotifController.uploadGaleri);
router.delete('/galeri/:galeri_id', lokomotifController.deleteGaleri);

module.exports = router;
