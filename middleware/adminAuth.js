const jwt = require('jsonwebtoken');
const { pool } = require('../config/db');

const adminAuth = async (req, res, next) => {
  try {
    const header = req.headers.authorization;
    if (!header || !header.startsWith('Bearer ')) {
      return res.status(401).json({ success: false, message: 'Admin access denied. No token.' });
    }
    const token = header.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    if (!decoded.isAdmin) {
      return res.status(403).json({ success: false, message: 'Forbidden. Admin only.' });
    }
    const [rows] = await pool.query('SELECT id, name, email, role, is_active FROM admins WHERE id = ?', [decoded.id]);
    if (!rows.length || !rows[0].is_active) {
      return res.status(401).json({ success: false, message: 'Invalid or inactive admin.' });
    }
    req.admin = rows[0];
    next();
  } catch (err) {
    return res.status(401).json({ success: false, message: 'Invalid admin token.' });
  }
};

module.exports = adminAuth;
