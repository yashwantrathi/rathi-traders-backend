const { pool } = require('../config/db');
const { v4: uuidv4 } = require('uuid');

const generateOrderNumber = () => 'RT' + Date.now().toString().slice(-8) + Math.floor(Math.random() * 100);

exports.placeOrder = async (req, res) => {
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    const { address_id, payment_method = 'cod', coupon_code, notes } = req.body;
    const customerId = req.customer.id;

    // Fetch cart
    const [cartItems] = await conn.query(
      `SELECT c.quantity, p.id as product_id, p.name, p.brand, p.image, p.selling_price, p.mrp, p.gst_percent, p.stock FROM cart c JOIN products p ON c.product_id = p.id WHERE c.customer_id = ?`,
      [customerId]
    );
    if (!cartItems.length) return res.status(400).json({ success: false, message: 'Cart is empty' });

    // Check stock
    for (const item of cartItems) {
      if (item.stock < item.quantity) {
        await conn.rollback();
        return res.status(400).json({ success: false, message: `Insufficient stock for ${item.name}` });
      }
    }

    // Get address
    let deliveryDetails = {};
    if (address_id) {
      const [addr] = await conn.query('SELECT * FROM addresses WHERE id = ? AND customer_id = ?', [address_id, customerId]);
      if (addr.length) {
        deliveryDetails = { delivery_name: addr[0].name, delivery_phone: addr[0].phone, delivery_address: `${addr[0].address_line1}, ${addr[0].address_line2 || ''}, ${addr[0].city}, ${addr[0].state} - ${addr[0].pincode}` };
      }
    }

    // Calculate totals
    let subtotal = 0;
    let gstAmount = 0;
    for (const item of cartItems) {
      subtotal += item.selling_price * item.quantity;
      gstAmount += (item.selling_price * item.gst_percent / 100) * item.quantity;
    }
    let discountAmount = 0;
    let usedCoupon = null;
    if (coupon_code) {
      const [coupon] = await conn.query('SELECT * FROM coupons WHERE code = ? AND is_active = 1 AND valid_till >= CURDATE() AND used_count < usage_limit', [coupon_code]);
      if (coupon.length && subtotal >= coupon[0].min_order_amount) {
        const c = coupon[0];
        discountAmount = c.discount_type === 'percent' ? Math.min(subtotal * c.discount_value / 100, c.max_discount || Infinity) : c.discount_value;
        usedCoupon = c.code;
        await conn.query('UPDATE coupons SET used_count = used_count + 1 WHERE code = ?', [c.code]);
      }
    }
    const deliveryCharge = subtotal >= 500 ? 0 : 40;
    const totalAmount = subtotal - discountAmount + deliveryCharge;
    const orderNumber = generateOrderNumber();

    // Insert order
    const [orderResult] = await conn.query(
      `INSERT INTO orders (order_number, customer_id, address_id, delivery_name, delivery_phone, delivery_address, subtotal, discount_amount, coupon_code, gst_amount, delivery_charge, total_amount, payment_method, notes) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      [orderNumber, customerId, address_id || null, deliveryDetails.delivery_name, deliveryDetails.delivery_phone, deliveryDetails.delivery_address, subtotal.toFixed(2), discountAmount.toFixed(2), usedCoupon, gstAmount.toFixed(2), deliveryCharge, totalAmount.toFixed(2), payment_method, notes || null]
    );
    const orderId = orderResult.insertId;

    // Insert order items & reduce stock
    for (const item of cartItems) {
      await conn.query(
        `INSERT INTO order_items (order_id, product_id, product_name, brand, image, quantity, unit_price, mrp, gst_percent, total_price) VALUES (?,?,?,?,?,?,?,?,?,?)`,
        [orderId, item.product_id, item.name, item.brand, item.image, item.quantity, item.selling_price, item.mrp, item.gst_percent, (item.selling_price * item.quantity).toFixed(2)]
      );
      await conn.query('UPDATE products SET stock = stock - ? WHERE id = ?', [item.quantity, item.product_id]);
    }

    // Clear cart
    await conn.query('DELETE FROM cart WHERE customer_id = ?', [customerId]);

    // Insert payment record
    await conn.query('INSERT INTO payments (order_id, customer_id, payment_method, amount, status) VALUES (?,?,?,?,?)', [orderId, customerId, payment_method, totalAmount.toFixed(2), payment_method === 'cod' ? 'pending' : 'pending']);

    await conn.commit();
    res.status(201).json({ success: true, message: 'Order placed successfully', order_id: orderId, order_number: orderNumber, total_amount: totalAmount.toFixed(2), payment_method });
  } catch (err) {
    await conn.rollback();
    console.error('Place order error:', err);
    res.status(500).json({ success: false, message: 'Failed to place order' });
  } finally {
    conn.release();
  }
};

exports.getOrders = async (req, res) => {
  try {
    const [orders] = await pool.query(
      `SELECT o.*, GROUP_CONCAT(oi.product_name SEPARATOR ', ') as items_summary FROM orders o LEFT JOIN order_items oi ON o.id = oi.order_id WHERE o.customer_id = ? GROUP BY o.id ORDER BY o.created_at DESC`,
      [req.customer.id]
    );
    res.json({ success: true, orders });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to fetch orders' });
  }
};

exports.getOrder = async (req, res) => {
  try {
    const { id } = req.params;
    const [orders] = await pool.query('SELECT * FROM orders WHERE id = ? AND customer_id = ?', [id, req.customer.id]);
    if (!orders.length) return res.status(404).json({ success: false, message: 'Order not found' });
    const [items] = await pool.query('SELECT * FROM order_items WHERE order_id = ?', [id]);
    const [payment] = await pool.query('SELECT * FROM payments WHERE order_id = ?', [id]);
    res.json({ success: true, order: { ...orders[0], items, payment: payment[0] || null } });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to fetch order' });
  }
};

exports.cancelOrder = async (req, res) => {
  try {
    const { id } = req.params;
    const [orders] = await pool.query('SELECT order_status FROM orders WHERE id = ? AND customer_id = ?', [id, req.customer.id]);
    if (!orders.length) return res.status(404).json({ success: false, message: 'Order not found' });
    if (!['pending', 'confirmed'].includes(orders[0].order_status)) {
      return res.status(400).json({ success: false, message: 'Order cannot be cancelled at this stage' });
    }
    await pool.query('UPDATE orders SET order_status = ? WHERE id = ?', ['cancelled', id]);
    // Restore stock
    const [items] = await pool.query('SELECT product_id, quantity FROM order_items WHERE order_id = ?', [id]);
    for (const item of items) await pool.query('UPDATE products SET stock = stock + ? WHERE id = ?', [item.quantity, item.product_id]);
    res.json({ success: true, message: 'Order cancelled successfully' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to cancel order' });
  }
};

// ADMIN: Get all orders
exports.adminGetOrders = async (req, res) => {
  try {
    const { status, page = 1, limit = 20 } = req.query;
    let where = '';
    let params = [];
    if (status) { where = 'WHERE o.order_status = ?'; params.push(status); }
    const offset = (parseInt(page) - 1) * parseInt(limit);
    const [orders] = await pool.query(
      `SELECT o.*, c.name as customer_name, c.phone as customer_phone FROM orders o JOIN customers c ON o.customer_id = c.id ${where} ORDER BY o.created_at DESC LIMIT ${parseInt(limit)} OFFSET ${offset}`,
      params
    );
    const [[{ total }]] = await pool.query(`SELECT COUNT(*) as total FROM orders o ${where}`, params);
    res.json({ success: true, orders, total, page: parseInt(page), pages: Math.ceil(total / parseInt(limit)) });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to fetch orders' });
  }
};

// ADMIN: Update order status
exports.adminUpdateOrder = async (req, res) => {
  try {
    const { id } = req.params;
    const { order_status, admin_note, payment_status } = req.body;
    let updates = [];
    let vals = [];
    if (order_status) { updates.push('order_status = ?'); vals.push(order_status); }
    if (admin_note !== undefined) { updates.push('admin_note = ?'); vals.push(admin_note); }
    if (payment_status) { updates.push('payment_status = ?'); vals.push(payment_status); }
    if (!updates.length) return res.status(400).json({ success: false, message: 'Nothing to update' });
    vals.push(id);
    await pool.query(`UPDATE orders SET ${updates.join(', ')} WHERE id = ?`, vals);
    if (payment_status === 'paid') await pool.query('UPDATE orders SET admin_verified = 1 WHERE id = ?', [id]);
    res.json({ success: true, message: 'Order updated' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to update order' });
  }
};
