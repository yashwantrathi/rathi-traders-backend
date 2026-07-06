const { pool } = require('../config/db');

// Get all products with filters
exports.getProducts = async (req, res) => {
  try {
    const { category, brand, search, min_price, max_price, sort, featured, bestseller, page = 1, limit = 20 } = req.query;
    let where = ['p.is_available = 1'];
    let params = [];

    if (category) { where.push('c.slug = ?'); params.push(category); }
    if (brand) { where.push('p.brand = ?'); params.push(brand); }
    if (search) { where.push('(p.name LIKE ? OR p.brand LIKE ? OR p.description LIKE ?)'); params.push(`%${search}%`, `%${search}%`, `%${search}%`); }
    if (min_price) { where.push('p.selling_price >= ?'); params.push(parseFloat(min_price)); }
    if (max_price) { where.push('p.selling_price <= ?'); params.push(parseFloat(max_price)); }
    if (featured === 'true') { where.push('p.is_featured = 1'); }
    if (bestseller === 'true') { where.push('p.is_bestseller = 1'); }

    let orderBy = 'p.id DESC';
    if (sort === 'price_asc') orderBy = 'p.selling_price ASC';
    else if (sort === 'price_desc') orderBy = 'p.selling_price DESC';
    else if (sort === 'rating') orderBy = 'p.rating DESC';
    else if (sort === 'name') orderBy = 'p.name ASC';

    const offset = (parseInt(page) - 1) * parseInt(limit);
    const whereClause = where.length ? `WHERE ${where.join(' AND ')}` : '';

    const countQuery = `SELECT COUNT(*) as total FROM products p JOIN categories c ON p.category_id = c.id ${whereClause}`;
    const [countResult] = await pool.query(countQuery, params);
    const total = countResult[0].total;

    const query = `SELECT p.*, c.name as category_name, c.slug as category_slug 
      FROM products p JOIN categories c ON p.category_id = c.id 
      ${whereClause} ORDER BY ${orderBy} LIMIT ${parseInt(limit)} OFFSET ${offset}`;
    const [products] = await pool.query(query, params);

    res.json({ success: true, products, total, page: parseInt(page), pages: Math.ceil(total / parseInt(limit)) });
  } catch (err) {
    console.error('Get products error:', err);
    res.status(500).json({ success: false, message: 'Failed to fetch products' });
  }
};

// Get single product
exports.getProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const isSlug = isNaN(parseInt(id));
    const field = isSlug ? 'p.slug' : 'p.id';
    const [rows] = await pool.query(
      `SELECT p.*, c.name as category_name, c.slug as category_slug FROM products p JOIN categories c ON p.category_id = c.id WHERE ${field} = ?`,
      [id]
    );
    if (!rows.length) return res.status(404).json({ success: false, message: 'Product not found' });
    const [reviews] = await pool.query(
      `SELECT r.*, cu.name as customer_name FROM reviews r JOIN customers cu ON r.customer_id = cu.id WHERE r.product_id = ? AND r.is_approved = 1 ORDER BY r.created_at DESC LIMIT 10`,
      [rows[0].id]
    );
    rows[0].reviews = reviews;
    res.json({ success: true, product: rows[0] });
  } catch (err) {
    console.error('Get product error:', err);
    res.status(500).json({ success: false, message: 'Failed to fetch product' });
  }
};

// Get featured products
exports.getFeaturedProducts = async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT p.*, c.name as category_name FROM products p JOIN categories c ON p.category_id = c.id WHERE p.is_featured = 1 AND p.is_available = 1 ORDER BY p.rating DESC LIMIT 12`
    );
    res.json({ success: true, products: rows });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to fetch featured products' });
  }
};

// Get bestsellers
exports.getBestsellers = async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT p.*, c.name as category_name FROM products p JOIN categories c ON p.category_id = c.id WHERE p.is_bestseller = 1 AND p.is_available = 1 ORDER BY p.rating DESC LIMIT 12`
    );
    res.json({ success: true, products: rows });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to fetch bestsellers' });
  }
};

// Get brands
exports.getBrands = async (req, res) => {
  try {
    const [rows] = await pool.query(`SELECT DISTINCT brand FROM products WHERE is_available = 1 AND brand IS NOT NULL ORDER BY brand`);
    res.json({ success: true, brands: rows.map(r => r.brand) });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to fetch brands' });
  }
};

// Search suggestions
exports.searchSuggestions = async (req, res) => {
  try {
    const { q } = req.query;
    if (!q || q.length < 2) return res.json({ success: true, suggestions: [] });
    const [rows] = await pool.query(
      `SELECT id, name, brand, selling_price, image FROM products WHERE is_available = 1 AND (name LIKE ? OR brand LIKE ?) LIMIT 8`,
      [`%${q}%`, `%${q}%`]
    );
    res.json({ success: true, suggestions: rows });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Search failed' });
  }
};

// ADMIN: Create product
exports.createProduct = async (req, res) => {
  try {
    const { name, category_id, brand, description, mrp, selling_price, gst_percent, stock, unit, weight, barcode, expiry_date, manufacture_date, is_featured, is_bestseller } = req.body;
    const image = req.file ? req.file.filename : 'default-product.jpg';
    const slug = name.toLowerCase().replace(/[^a-z0-9]+/g, '-') + '-' + Date.now();
    const [result] = await pool.query(
      `INSERT INTO products (name, slug, category_id, brand, description, mrp, selling_price, gst_percent, stock, unit, weight, image, barcode, expiry_date, manufacture_date, is_featured, is_bestseller) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      [name, slug, category_id, brand, description, mrp, selling_price, gst_percent || 0, stock || 0, unit || 'pcs', weight, image, barcode, expiry_date || null, manufacture_date || null, is_featured ? 1 : 0, is_bestseller ? 1 : 0]
    );
    res.status(201).json({ success: true, message: 'Product created', id: result.insertId });
  } catch (err) {
    console.error('Create product error:', err);
    res.status(500).json({ success: false, message: 'Failed to create product' });
  }
};

// ADMIN: Update product
exports.updateProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const fields = req.body;
    if (req.file) fields.image = req.file.filename;
    const keys = Object.keys(fields).filter(k => ['name','category_id','brand','description','mrp','selling_price','gst_percent','stock','unit','weight','image','barcode','expiry_date','manufacture_date','is_featured','is_bestseller','is_available'].includes(k));
    if (!keys.length) return res.status(400).json({ success: false, message: 'Nothing to update' });
    
    const set = keys.map(k => `${k} = ?`).join(', ');
    const vals = keys.map(k => {
      let val = fields[k];
      if ((k === 'expiry_date' || k === 'manufacture_date') && val === '') return null;
      if (k === 'is_featured' || k === 'is_bestseller' || k === 'is_available') return val === 'true' || val === true ? 1 : 0;
      return val;
    });

    await pool.query(`UPDATE products SET ${set} WHERE id = ?`, [...vals, id]);
    res.json({ success: true, message: 'Product updated' });
  } catch (err) {
    console.error('Update error:', err);
    res.status(500).json({ success: false, message: 'Failed to update product: ' + err.message });
  }
};

// ADMIN: Delete product
exports.deleteProduct = async (req, res) => {
  try {
    await pool.query('UPDATE products SET is_available = 0 WHERE id = ?', [req.params.id]);
    res.json({ success: true, message: 'Product disabled' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to delete product' });
  }
};
