const express = require('express');
const router = express.Router();
const { register, login, adminLogin, getProfile, updateProfile, changePassword } = require('../controllers/authController');
const auth = require('../middleware/auth');
const upload = require('../middleware/upload');

router.post('/register', register);
router.post('/login', login);
router.post('/admin/login', adminLogin);
router.get('/profile', auth, getProfile);
router.put('/profile', auth, upload.single('profile_image'), updateProfile);
router.post('/change-password', auth, changePassword);

module.exports = router;
