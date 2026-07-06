const express = require('express');
const router = express.Router();
const { pool } = require('../config/db');

// Get active coupons
router.get('/', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT code, description, discount_type, discount_value, min_order_amount, max_discount, valid_till FROM coupons WHERE is_active = 1 AND valid_till >= CURDATE() ORDER BY discount_value DESC');
    res.json({ success: true, coupons: rows });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to fetch coupons' });
  }
});

// Validate coupon
router.post('/validate', async (req, res) => {
  try {
    const { code, order_amount } = req.body;
    const [rows] = await pool.query('SELECT * FROM coupons WHERE code = ? AND is_active = 1 AND valid_till >= CURDATE() AND used_count < usage_limit', [code]);
    if (!rows.length) return res.status(404).json({ success: false, message: 'Invalid or expired coupon' });
    const c = rows[0];
    if (parseFloat(order_amount) < parseFloat(c.min_order_amount)) return res.status(400).json({ success: false, message: `Minimum order amount is ₹${c.min_order_amount}` });
    const discount = c.discount_type === 'percent' ? Math.min(order_amount * c.discount_value / 100, c.max_discount || Infinity) : c.discount_value;
    res.json({ success: true, coupon: c, discount: discount.toFixed(2) });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Coupon validation failed' });
  }
});

// Admin CRUD
const adminAuth = require('../middleware/adminAuth');
router.get('/admin/all', adminAuth, async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM coupons ORDER BY created_at DESC');
    res.json({ success: true, coupons: rows });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed' });
  }
});
router.post('/admin', adminAuth, async (req, res) => {
  try {
    const { code, description, discount_type, discount_value, min_order_amount, max_discount, usage_limit, valid_from, valid_till } = req.body;
    await pool.query('INSERT INTO coupons (code, description, discount_type, discount_value, min_order_amount, max_discount, usage_limit, valid_from, valid_till) VALUES (?,?,?,?,?,?,?,?,?)', [code, description, discount_type, discount_value, min_order_amount || 0, max_discount || null, usage_limit || 100, valid_from, valid_till]);
    res.status(201).json({ success: true, message: 'Coupon created' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to create coupon' });
  }
});

module.exports = router;
