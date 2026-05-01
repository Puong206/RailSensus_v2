const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const auth = require('../middlewares/auth');
const admin = require('../middlewares/admin');
const validate = require('../middlewares/validate');
const { keretaSchema, depoSchema, userUpdateSchema } = require('../validators/adminValidator');

// All admin routes require authentication AND admin role
router.use(auth, admin);

router.get('/stats', adminController.getAdminStats);

router.get('/kereta', adminController.getAllKereta);
router.post('/kereta', validate(keretaSchema), adminController.createKereta);
router.put('/kereta/:id', validate(keretaSchema), adminController.updateKereta);
router.delete('/kereta/:id', adminController.deleteKereta);

router.get('/users', adminController.getAllUsers);
router.put('/users/:id', validate(userUpdateSchema), adminController.updateUser);
router.delete('/users/:id', adminController.deleteUser);

router.get('/depo', adminController.getAllDepo);
router.post('/depo', validate(depoSchema), adminController.createDepo);
router.put('/depo/:id', validate(depoSchema), adminController.updateDepo);
router.delete('/depo/:id', adminController.deleteDepo);

module.exports = router;
