const { pool } = require('../config/db');

// Dashboard stats
exports.getDashboard = async (req, res) => {
  try {
    const [[{ total_orders }]] = await pool.query('SELECT COUNT(*) as total_orders FROM orders');
    const [[{ total_customers }]] = await pool.query('SELECT COUNT(*) as total_customers FROM customers');
    const [[{ total_products }]] = await pool.query('SELECT COUNT(*) as total_products FROM products WHERE is_available = 1');
    const [[{ total_revenue }]] = await pool.query("SELECT COALESCE(SUM(total_amount),0) as total_revenue FROM orders WHERE payment_status = 'paid'");
    const [[{ pending_orders }]] = await pool.query("SELECT COUNT(*) as pending_orders FROM orders WHERE order_status = 'pending'");
    const [[{ pending_payments }]] = await pool.query("SELECT COUNT(*) as pending_payments FROM orders WHERE payment_method = 'upi' AND payment_status = 'pending' AND screenshot_url IS NOT NULL");
    const [[{ low_stock }]] = await pool.query("SELECT COUNT(*) as low_stock FROM products WHERE stock < 10 AND is_available = 1");

    const [recent_orders] = await pool.query(
      `SELECT o.id, o.order_number, o.total_amount, o.order_status, o.payment_status, o.created_at, c.name as customer_name FROM orders o JOIN customers c ON o.customer_id = c.id ORDER BY o.created_at DESC LIMIT 10`
    );
    const [monthly_revenue] = await pool.query(
      `SELECT DATE_FORMAT(created_at, '%Y-%m') as month, SUM(total_amount) as revenue, COUNT(*) as orders FROM orders WHERE payment_status = 'paid' AND created_at >= DATE_SUB(NOW(), INTERVAL 6 MONTH) GROUP BY month ORDER BY month`
    );
    const [category_sales] = await pool.query(
      `SELECT c.name, SUM(oi.total_price) as total FROM order_items oi JOIN products p ON oi.product_id = p.id JOIN categories c ON p.category_id = c.id GROUP BY c.id ORDER BY total DESC LIMIT 5`
    );

    res.json({ success: true, stats: { total_orders, total_customers, total_products, total_revenue: parseFloat(total_revenue).toFixed(2), pending_orders, pending_payments, low_stock }, recent_orders, monthly_revenue, category_sales });
  } catch (err) {
    console.error('Dashboard error:', err);
    res.status(500).json({ success: false, message: 'Failed to fetch dashboard data' });
  }
};

// Get all customers
exports.getCustomers = async (req, res) => {
  try {
    const { page = 1, limit = 20, search } = req.query;
    const offset = (parseInt(page) - 1) * parseInt(limit);
    let where = '';
    let params = [];
    if (search) { where = 'WHERE name LIKE ? OR email LIKE ? OR phone LIKE ?'; params = [`%${search}%`, `%${search}%`, `%${search}%`]; }
    const [customers] = await pool.query(`SELECT id, name, email, phone, is_active, created_at, last_login FROM customers ${where} ORDER BY created_at DESC LIMIT ${parseInt(limit)} OFFSET ${offset}`, params);
    const [[{ total }]] = await pool.query(`SELECT COUNT(*) as total FROM customers ${where}`, params);
    res.json({ success: true, customers, total, page: parseInt(page), pages: Math.ceil(total / parseInt(limit)) });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to fetch customers' });
  }
};

// Toggle customer status
exports.toggleCustomer = async (req, res) => {
  try {
    const { id } = req.params;
    await pool.query('UPDATE customers SET is_active = NOT is_active WHERE id = ?', [id]);
    res.json({ success: true, message: 'Customer status updated' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to update customer' });
  }
};

// Get inventory (low stock)
exports.getInventory = async (req, res) => {
  try {
    const { low_stock } = req.query;
    let where = 'WHERE p.is_available = 1';
    if (low_stock === 'true') where += ' AND p.stock < 10';
    const [products] = await pool.query(
      `SELECT p.id, p.name, p.brand, p.stock, p.selling_price, p.mrp, c.name as category FROM products p JOIN categories c ON p.category_id = c.id ${where} ORDER BY p.stock ASC`
    );
    res.json({ success: true, products });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to fetch inventory' });
  }
};

// Get messages
exports.getMessages = async (req, res) => {
  try {
    const [messages] = await pool.query('SELECT * FROM contact_messages ORDER BY created_at DESC');
    res.json({ success: true, messages });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to fetch messages' });
  }
};
