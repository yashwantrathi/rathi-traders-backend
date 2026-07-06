const express = require('express');
const router = express.Router();
const { pool } = require('../config/db');

router.post('/', async (req, res) => {
  try {
    const { name, email, phone, subject, message } = req.body;
    if (!name || !email || !message) return res.status(400).json({ success: false, message: 'Name, email and message required' });
    await pool.query('INSERT INTO contact_messages (name, email, phone, subject, message) VALUES (?,?,?,?,?)', [name, email, phone || null, subject || null, message]);
    res.status(201).json({ success: true, message: 'Message sent successfully. We will get back to you soon!' });
  } catch (err) { res.status(500).json({ success: false, message: 'Failed to send message' }); }
});

module.exports = router;
