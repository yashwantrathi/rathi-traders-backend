const { pool } = require('../config/db');

exports.getAddresses = async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM addresses WHERE customer_id = ? ORDER BY is_default DESC', [req.customer.id]);
    res.json({ success: true, addresses: rows });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to fetch addresses' });
  }
};

exports.addAddress = async (req, res) => {
  try {
    const { label, name, phone, address_line1, address_line2, city, state, pincode, landmark, is_default } = req.body;
    if (is_default) await pool.query('UPDATE addresses SET is_default = 0 WHERE customer_id = ?', [req.customer.id]);
    const [result] = await pool.query('INSERT INTO addresses (customer_id, label, name, phone, address_line1, address_line2, city, state, pincode, landmark, is_default) VALUES (?,?,?,?,?,?,?,?,?,?,?)', [req.customer.id, label || 'Home', name, phone, address_line1, address_line2 || null, city, state, pincode, landmark || null, is_default ? 1 : 0]);
    res.status(201).json({ success: true, message: 'Address added', id: result.insertId });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to add address' });
  }
};

exports.updateAddress = async (req, res) => {
  try {
    const { id } = req.params;
    const { label, name, phone, address_line1, address_line2, city, state, pincode, landmark, is_default } = req.body;
    if (is_default) await pool.query('UPDATE addresses SET is_default = 0 WHERE customer_id = ?', [req.customer.id]);
    await pool.query('UPDATE addresses SET label=?, name=?, phone=?, address_line1=?, address_line2=?, city=?, state=?, pincode=?, landmark=?, is_default=? WHERE id=? AND customer_id=?', [label, name, phone, address_line1, address_line2 || null, city, state, pincode, landmark || null, is_default ? 1 : 0, id, req.customer.id]);
    res.json({ success: true, message: 'Address updated' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to update address' });
  }
};

exports.deleteAddress = async (req, res) => {
  try {
    await pool.query('DELETE FROM addresses WHERE id = ? AND customer_id = ?', [req.params.id, req.customer.id]);
    res.json({ success: true, message: 'Address deleted' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to delete address' });
  }
};
