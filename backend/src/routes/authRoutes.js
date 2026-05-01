const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const validate = require('../middlewares/validate');
const { authRegisterSchema, authLoginSchema, updateProfileSchema, changePasswordSchema } = require('../validators/authValidator');
const auth = require('../middlewares/auth');
const rateLimit = require('express-rate-limit');
const upload = require('../middlewares/upload');

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10, // Limit each IP to 10 login/register requests per windowMs
  message: {
    success: false,
    message: 'Too many authentication attempts, please try again after 15 minutes'
  }
});

router.post('/register', authLimiter, validate(authRegisterSchema), authController.register);
router.post('/login', authLimiter, validate(authLoginSchema), authController.login);

router.put('/profile', auth, validate(updateProfileSchema), authController.updateProfile);
router.get('/me', auth, authController.getMe);
router.post('/profile-photo', auth, upload.single('foto_profil'), authController.uploadProfilePhoto);
router.delete('/profile-photo', auth, authController.deleteProfilePhoto);
router.put('/change-password', auth, validate(changePasswordSchema), authController.changePassword);

router.get('/gallery', auth, authController.getUserGallery);

module.exports = router;
