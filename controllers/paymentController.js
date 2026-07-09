const QRCode = require('qrcode');
const { pool } = require('../config/db');

// Generate UPI QR code
exports.generateUPIQR = async (req, res) => {
  try {
    const { order_id } = req.params;
    const [orders] = await pool.query('SELECT * FROM orders WHERE id = ? AND customer_id = ?', [order_id, req.customer.id]);
    if (!orders.length) return res.status(404).json({ success: false, message: 'Order not found' });
    const order = orders[0];
    const upiId = process.env.UPI_ID || '8123975900@ybl';
    const businessName = process.env.UPI_BUSINESS_NAME || 'Rathi Traders';
    const amount = parseFloat(order.total_amount).toFixed(2);
    const note = `RathiTraders-Order-${order.order_number}`;
    const upiString = `upi://pay?pa=${encodeURIComponent(upiId)}&pn=${encodeURIComponent(businessName)}&am=${amount}&tn=${encodeURIComponent(note)}&cu=INR`;
    const qrDataUrl = await QRCode.toDataURL(upiString, { width: 300, margin: 2, color: { dark: '#1a1a2e', light: '#ffffff' } });
    res.json({ success: true, qr_code: qrDataUrl, upi_id: upiId, amount, order_number: order.order_number, business_name: businessName });
  } catch (err) {
    console.error('QR generation error:', err);
    res.status(500).json({ success: false, message: 'Failed to generate QR code' });
  }
};

// Upload payment screenshot
exports.uploadScreenshot = async (req, res) => {
  try {
    const { order_id } = req.params;
    const { transaction_ref } = req.body;
    if (!req.file) return res.status(400).json({ success: false, message: 'No screenshot uploaded' });
    const screenshot = req.file.filename;
    await pool.query('UPDATE orders SET screenshot_url = ?, upi_transaction_ref = ?, payment_status = ? WHERE id = ? AND customer_id = ?', [screenshot, transaction_ref || null, 'pending', order_id, req.customer.id]);
    await pool.query('UPDATE payments SET screenshot_url = ?, transaction_ref = ? WHERE order_id = ?', [screenshot, transaction_ref || null, order_id]);
    res.json({ success: true, message: 'Payment screenshot uploaded. Awaiting admin verification.' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to upload screenshot' });
  }
};

// ADMIN: Verify payment
exports.verifyPayment = async (req, res) => {
  try {
    const { order_id } = req.params;
    const { status = 'verified', note } = req.body;
    const paymentStatus = status === 'verified' ? 'paid' : 'failed';
    const orderPaymentStatus = status === 'verified' ? 'paid' : 'failed';
    const orderStatus = status === 'verified' ? 'confirmed' : 'pending';
    await pool.query('UPDATE orders SET payment_status = ?, order_status = ?, admin_verified = ?, admin_note = ? WHERE id = ?', [orderPaymentStatus, orderStatus, status === 'verified' ? 1 : 0, note || null, order_id]);
    await pool.query('UPDATE payments SET status = ?, verified_by = ?, verified_at = NOW() WHERE order_id = ?', [paymentStatus, req.admin.id, order_id]);
    res.json({ success: true, message: `Payment ${status} successfully` });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to verify payment' });
  }
};

// ADMIN: Get pending payments
exports.getPendingPayments = async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT o.id as order_id, o.order_number, o.total_amount, o.screenshot_url, o.upi_transaction_ref, o.payment_method, o.created_at, c.name as customer_name, c.phone as customer_phone FROM orders o JOIN customers c ON o.customer_id = c.id WHERE o.payment_method = 'upi' AND o.payment_status = 'pending' AND o.screenshot_url IS NOT NULL ORDER BY o.created_at DESC`
    );
    res.json({ success: true, payments: rows });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to fetch pending payments' });
  }
};
