const jwt = require('jsonwebtoken');
const { pool } = require('../config/db');

const auth = async (req, res, next) => {
  try {
    const header = req.headers.authorization;
    if (!header || !header.startsWith('Bearer ')) {
      return res.status(401).json({ success: false, message: 'Access denied. No token provided.' });
    }
    const token = header.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const [rows] = await pool.query('SELECT id, name, email, phone, is_active FROM customers WHERE id = ?', [decoded.id]);
    if (!rows.length || !rows[0].is_active) {
      return res.status(401).json({ success: false, message: 'Invalid or inactive account.' });
    }
    req.customer = rows[0];
    next();
  } catch (err) {
    return res.status(401).json({ success: false, message: 'Invalid token.' });
  }
};

module.exports = auth;
