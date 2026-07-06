const express = require('express');
const router = express.Router();
const { getDashboard, getCustomers, toggleCustomer, getInventory, getMessages } = require('../controllers/adminController');
const adminAuth = require('../middleware/adminAuth');

router.get('/dashboard', adminAuth, getDashboard);
router.get('/customers', adminAuth, getCustomers);
router.put('/customers/:id/toggle', adminAuth, toggleCustomer);
router.get('/inventory', adminAuth, getInventory);
router.get('/messages', adminAuth, getMessages);

module.exports = router;
