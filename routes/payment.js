const express = require('express');
const router = express.Router();
const { generateUPIQR, uploadScreenshot, verifyPayment, getPendingPayments } = require('../controllers/paymentController');
const auth = require('../middleware/auth');
const adminAuth = require('../middleware/adminAuth');
const upload = require('../middleware/upload');

router.get('/qr/:order_id', auth, generateUPIQR);
router.post('/screenshot/:order_id', auth, upload.single('screenshot'), uploadScreenshot);
router.post('/verify/:order_id', adminAuth, verifyPayment);
router.get('/pending', adminAuth, getPendingPayments);

module.exports = router;
