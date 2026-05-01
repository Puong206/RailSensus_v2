const express = require('express');
const router = express.Router();
const keretaController = require('../controllers/keretaController');
const auth = require('../middlewares/auth');

// All kereta routes are protected
router.use(auth);

router.get('/', keretaController.getAll);

module.exports = router;
