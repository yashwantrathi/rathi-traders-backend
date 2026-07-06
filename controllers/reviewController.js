const { pool } = require('../config/db');

exports.getReviews = async (req, res) => {
  try {
    const { product_id } = req.params;
    const [rows] = await pool.query(`SELECT r.*, c.name as customer_name FROM reviews r JOIN customers c ON r.customer_id = c.id WHERE r.product_id = ? AND r.is_approved = 1 ORDER BY r.created_at DESC`, [product_id]);
    res.json({ success: true, reviews: rows });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to fetch reviews' });
  }
};

exports.addReview = async (req, res) => {
  try {
    const { product_id, rating, title, comment, order_id } = req.body;
    if (!product_id || !rating) return res.status(400).json({ success: false, message: 'Product and rating required' });
    const [existing] = await pool.query('SELECT id FROM reviews WHERE product_id = ? AND customer_id = ?', [product_id, req.customer.id]);
    if (existing.length) return res.status(400).json({ success: false, message: 'You have already reviewed this product' });
    await pool.query('INSERT INTO reviews (product_id, customer_id, order_id, rating, title, comment) VALUES (?,?,?,?,?,?)', [product_id, req.customer.id, order_id || null, rating, title || null, comment || null]);
    const [[{ avg_rating, count }]] = await pool.query('SELECT AVG(rating) as avg_rating, COUNT(*) as count FROM reviews WHERE product_id = ? AND is_approved = 1', [product_id]);
    await pool.query('UPDATE products SET rating = ?, review_count = ? WHERE id = ?', [parseFloat(avg_rating).toFixed(2), count, product_id]);
    res.status(201).json({ success: true, message: 'Review added successfully' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to add review' });
  }
};

exports.adminGetReviews = async (req, res) => {
  try {
    const [rows] = await pool.query(`SELECT r.*, c.name as customer_name, p.name as product_name FROM reviews r JOIN customers c ON r.customer_id = c.id JOIN products p ON r.product_id = p.id ORDER BY r.created_at DESC`);
    res.json({ success: true, reviews: rows });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to fetch reviews' });
  }
};

exports.toggleReview = async (req, res) => {
  try {
    await pool.query('UPDATE reviews SET is_approved = NOT is_approved WHERE id = ?', [req.params.id]);
    res.json({ success: true, message: 'Review status updated' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to update review' });
  }
};
