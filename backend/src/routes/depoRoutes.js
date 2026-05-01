const express = require('express');
const router = express.Router();
const depoController = require('../controllers/depoController');
const auth = require('../middlewares/auth');

router.get('/', auth, depoController.getAll);

module.exports = router;
