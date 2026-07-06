const { pool } = require('../config/db');

exports.getCart = async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT c.id, c.quantity, p.id as product_id, p.name, p.brand, p.image, p.selling_price, p.mrp, p.gst_percent, p.stock, p.unit, p.is_available
       FROM cart c JOIN products p ON c.product_id = p.id WHERE c.customer_id = ?`,
      [req.customer.id]
    );
    const subtotal = rows.reduce((sum, item) => sum + item.selling_price * item.quantity, 0);
    res.json({ success: true, items: rows, subtotal: subtotal.toFixed(2), count: rows.length });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to fetch cart' });
  }
};

exports.addToCart = async (req, res) => {
  try {
    const { product_id, quantity = 1 } = req.body;
    const [product] = await pool.query('SELECT id, stock, is_available FROM products WHERE id = ?', [product_id]);
    if (!product.length || !product[0].is_available) return res.status(404).json({ success: false, message: 'Product not available' });
    if (product[0].stock < quantity) return res.status(400).json({ success: false, message: 'Insufficient stock' });
    const [existing] = await pool.query('SELECT id, quantity FROM cart WHERE customer_id = ? AND product_id = ?', [req.customer.id, product_id]);
    if (existing.length) {
      const newQty = existing[0].quantity + parseInt(quantity);
      if (newQty > product[0].stock) return res.status(400).json({ success: false, message: 'Cannot add more. Stock limit reached' });
      await pool.query('UPDATE cart SET quantity = ? WHERE id = ?', [newQty, existing[0].id]);
    } else {
      await pool.query('INSERT INTO cart (customer_id, product_id, quantity) VALUES (?, ?, ?)', [req.customer.id, product_id, quantity]);
    }
    res.json({ success: true, message: 'Added to cart' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to add to cart' });
  }
};

exports.updateCart = async (req, res) => {
  try {
    const { id } = req.params;
    const { quantity } = req.body;
    if (quantity < 1) {
      await pool.query('DELETE FROM cart WHERE id = ? AND customer_id = ?', [id, req.customer.id]);
      return res.json({ success: true, message: 'Item removed from cart' });
    }
    const [cartItem] = await pool.query('SELECT product_id FROM cart WHERE id = ? AND customer_id = ?', [id, req.customer.id]);
    if (!cartItem.length) return res.status(404).json({ success: false, message: 'Cart item not found' });
    const [product] = await pool.query('SELECT stock FROM products WHERE id = ?', [cartItem[0].product_id]);
    if (product[0].stock < quantity) return res.status(400).json({ success: false, message: 'Insufficient stock' });
    await pool.query('UPDATE cart SET quantity = ? WHERE id = ? AND customer_id = ?', [quantity, id, req.customer.id]);
    res.json({ success: true, message: 'Cart updated' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to update cart' });
  }
};

exports.removeFromCart = async (req, res) => {
  try {
    await pool.query('DELETE FROM cart WHERE id = ? AND customer_id = ?', [req.params.id, req.customer.id]);
    res.json({ success: true, message: 'Item removed from cart' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to remove from cart' });
  }
};

exports.clearCart = async (req, res) => {
  try {
    await pool.query('DELETE FROM cart WHERE customer_id = ?', [req.customer.id]);
    res.json({ success: true, message: 'Cart cleared' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to clear cart' });
  }
};
