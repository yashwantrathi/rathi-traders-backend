const express = require('express');
const router = express.Router();
const { placeOrder, getOrders, getOrder, cancelOrder, adminGetOrders, adminUpdateOrder } = require('../controllers/orderController');
const auth = require('../middleware/auth');
const adminAuth = require('../middleware/adminAuth');

router.post('/', auth, placeOrder);
router.get('/', auth, getOrders);
router.get('/admin/all', adminAuth, adminGetOrders);
router.get('/:id', auth, getOrder);
router.post('/:id/cancel', auth, cancelOrder);
router.put('/admin/:id', adminAuth, adminUpdateOrder);

module.exports = router;
