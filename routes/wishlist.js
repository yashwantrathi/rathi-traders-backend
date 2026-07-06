const express = require('express');
const router = express.Router();
const { pool } = require('../config/db');
const auth = require('../middleware/auth');

router.get('/', auth, async (req, res) => {
  try {
    const [rows] = await pool.query(`SELECT w.id, p.id as product_id, p.name, p.brand, p.selling_price, p.mrp, p.image, p.stock FROM wishlist w JOIN products p ON w.product_id = p.id WHERE w.customer_id = ?`, [req.customer.id]);
    res.json({ success: true, wishlist: rows });
  } catch (err) { res.status(500).json({ success: false, message: 'Failed' }); }
});

router.post('/toggle', auth, async (req, res) => {
  try {
    const { product_id } = req.body;
    const [existing] = await pool.query('SELECT id FROM wishlist WHERE customer_id = ? AND product_id = ?', [req.customer.id, product_id]);
    if (existing.length) {
      await pool.query('DELETE FROM wishlist WHERE id = ?', [existing[0].id]);
      res.json({ success: true, added: false, message: 'Removed from wishlist' });
    } else {
      await pool.query('INSERT INTO wishlist (customer_id, product_id) VALUES (?,?)', [req.customer.id, product_id]);
      res.json({ success: true, added: true, message: 'Added to wishlist' });
    }
  } catch (err) { res.status(500).json({ success: false, message: 'Failed' }); }
});

router.delete('/:id', auth, async (req, res) => {
  try {
    await pool.query('DELETE FROM wishlist WHERE id = ? AND customer_id = ?', [req.params.id, req.customer.id]);
    res.json({ success: true, message: 'Removed from wishlist' });
  } catch (err) { res.status(500).json({ success: false, message: 'Failed' }); }
});

module.exports = router;
