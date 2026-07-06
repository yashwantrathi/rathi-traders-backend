const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { pool } = require('../config/db');

const generateToken = (id, isAdmin = false) => jwt.sign({ id, isAdmin }, 'RathiTraders@2026SuperSecret', { expiresIn: process.env.JWT_EXPIRES_IN || '7d' });

// Customer Registration
exports.register = async (req, res) => {
  try {
    const { name, email, phone, password } = req.body;
    if (!name || !email || !password) return res.status(400).json({ success: false, message: 'Name, email and password are required' });
    const [exists] = await pool.query('SELECT id FROM customers WHERE email = ?', [email]);
    if (exists.length) return res.status(400).json({ success: false, message: 'Email already registered' });
    const hashedPassword = await bcrypt.hash(password, 10);
    const [result] = await pool.query('INSERT INTO customers (name, email, phone, password) VALUES (?, ?, ?, ?)', [name, email, phone || null, hashedPassword]);
    const token = generateToken(result.insertId);
    res.status(201).json({ success: true, message: 'Account created successfully', token, customer: { id: result.insertId, name, email, phone } });
  } catch (err) {
    console.error('Register error:', err);
    res.status(500).json({ success: false, message: 'Registration failed' });
  }
};

// Customer Login
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) return res.status(400).json({ success: false, message: 'Email and password required' });
    const [rows] = await pool.query('SELECT * FROM customers WHERE email = ?', [email]);
    if (!rows.length) return res.status(401).json({ success: false, message: 'Invalid credentials' });
    const customer = rows[0];
    if (!customer.is_active) return res.status(403).json({ success: false, message: 'Account is disabled' });
    const valid = await bcrypt.compare(password, customer.password);
    if (!valid) return res.status(401).json({ success: false, message: 'Invalid credentials' });
    await pool.query('UPDATE customers SET last_login = NOW() WHERE id = ?', [customer.id]);
    const token = generateToken(customer.id);
    res.json({ success: true, message: 'Login successful', token, customer: { id: customer.id, name: customer.name, email: customer.email, phone: customer.phone, profile_image: customer.profile_image } });
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ success: false, message: 'Login failed' });
  }
};

// Admin Login
exports.adminLogin = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) return res.status(400).json({ success: false, message: 'Email and password required' });
    const [rows] = await pool.query('SELECT * FROM admins WHERE email = ?', [email]);
    if (!rows.length) return res.status(401).json({ success: false, message: 'Invalid admin credentials' });
    const admin = rows[0];
    if (!admin.is_active) return res.status(403).json({ success: false, message: 'Admin account disabled' });
    const valid = await bcrypt.compare(password, admin.password);
    if (!valid) return res.status(401).json({ success: false, message: 'Invalid admin credentials' });
    await pool.query('UPDATE admins SET last_login = NOW() WHERE id = ?', [admin.id]);
    const token = generateToken(admin.id, true);
    res.json({ success: true, message: 'Admin login successful', token, admin: { id: admin.id, name: admin.name, email: admin.email, role: admin.role } });
  } catch (err) {
    console.error('Admin login error:', err);
    res.status(500).json({ success: false, message: 'Admin login failed' });
  }
};

// Get Profile
exports.getProfile = async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT id, name, email, phone, profile_image, created_at FROM customers WHERE id = ?', [req.customer.id]);
    res.json({ success: true, customer: rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to fetch profile' });
  }
};

// Update Profile
exports.updateProfile = async (req, res) => {
  try {
    const { name, phone } = req.body;
    const image = req.file ? req.file.filename : undefined;
    let query = 'UPDATE customers SET name = ?, phone = ?';
    let params = [name || req.customer.name, phone || null];
    if (image) { query += ', profile_image = ?'; params.push(image); }
    query += ' WHERE id = ?'; params.push(req.customer.id);
    await pool.query(query, params);
    res.json({ success: true, message: 'Profile updated successfully' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Update failed' });
  }
};

// Change Password
exports.changePassword = async (req, res) => {
  try {
    const { old_password, new_password } = req.body;
    const [rows] = await pool.query('SELECT password FROM customers WHERE id = ?', [req.customer.id]);
    const valid = await bcrypt.compare(old_password, rows[0].password);
    if (!valid) return res.status(400).json({ success: false, message: 'Old password incorrect' });
    const hashed = await bcrypt.hash(new_password, 10);
    await pool.query('UPDATE customers SET password = ? WHERE id = ?', [hashed, req.customer.id]);
    res.json({ success: true, message: 'Password changed successfully' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to change password' });
  }
};
