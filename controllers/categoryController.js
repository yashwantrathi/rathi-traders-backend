const { pool } = require('../config/db');

exports.getCategories = async (req, res) => {
  try {
    const [rows] = await pool.query(`SELECT c.*, COUNT(p.id) as product_count FROM categories c LEFT JOIN products p ON c.id = p.category_id AND p.is_available = 1 WHERE c.is_active = 1 GROUP BY c.id ORDER BY c.sort_order`);
    res.json({ success: true, categories: rows });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to fetch categories' });
  }
};

exports.getCategory = async (req, res) => {
  try {
    const { slug } = req.params;
    const [rows] = await pool.query('SELECT * FROM categories WHERE slug = ? AND is_active = 1', [slug]);
    if (!rows.length) return res.status(404).json({ success: false, message: 'Category not found' });
    res.json({ success: true, category: rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to fetch category' });
  }
};

exports.createCategory = async (req, res) => {
  try {
    const { name, description, icon, color, sort_order } = req.body;
    const slug = name.toLowerCase().replace(/[^a-z0-9]+/g, '-');
    const image = req.file ? req.file.filename : null;
    const [result] = await pool.query('INSERT INTO categories (name, slug, description, image, icon, color, sort_order) VALUES (?,?,?,?,?,?,?)', [name, slug, description, image, icon, color, sort_order || 0]);
    res.status(201).json({ success: true, message: 'Category created', id: result.insertId });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to create category' });
  }
};

exports.updateCategory = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description, icon, color, sort_order, is_active } = req.body;
    const image = req.file ? req.file.filename : undefined;
    let q = 'UPDATE categories SET name=?, description=?, icon=?, color=?, sort_order=?, is_active=?';
    let p = [name, description, icon, color, sort_order, is_active !== undefined ? is_active : 1];
    if (image) { q += ', image=?'; p.push(image); }
    q += ' WHERE id=?'; p.push(id);
    await pool.query(q, p);
    res.json({ success: true, message: 'Category updated' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to update category' });
  }
};

exports.deleteCategory = async (req, res) => {
  try {
    await pool.query('UPDATE categories SET is_active = 0 WHERE id = ?', [req.params.id]);
    res.json({ success: true, message: 'Category disabled' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to delete category' });
  }
};
