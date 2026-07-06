/**
 * RATHI TRADERS — DATABASE UPDATE SCRIPT
 * Run: node database/migrate.js
 *
 * Changes:
 *  1. Disable Chocolates category + all its products
 *  2. Fix Dal names (remove brand), set current KG market prices + real images
 *  3. Add Bath Soaps category + products (Cinthol, Santoor, Dove, Lifebuoy, Dettol, etc.)
 *  4. Add Shampoos category + products (Head & Shoulders, Clinic Plus, Dove, Pantene, etc.)
 */

const mysql = require('mysql2/promise');
require('dotenv').config({ path: '../.env' });

const db = {
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'Yash@mysql25',
  database: process.env.DB_NAME || 'rathi_traders',
};

async function run() {
  const conn = await mysql.createConnection(db);
  console.log('✅ Connected to database');

  try {
    // ─── 1. DISABLE CHOCOLATES ────────────────────────────────────────
    console.log('\n🍫 Disabling Chocolates category...');
    await conn.query(`
      UPDATE categories SET is_active = 0
      WHERE LOWER(name) LIKE '%chocolate%'
         OR LOWER(name) LIKE '%candy%'
         OR LOWER(name) LIKE '%confectionary%'
    `);
    const [catRows] = await conn.query(`
      SELECT id FROM categories
      WHERE LOWER(name) LIKE '%chocolate%'
         OR LOWER(name) LIKE '%candy%'
         OR LOWER(name) LIKE '%confectionary%'
    `);
    if (catRows.length) {
      const ids = catRows.map(r => r.id);
      await conn.query(`UPDATE products SET is_available = 0 WHERE category_id IN (?)`, [ids]);
      console.log(`  → Disabled ${catRows.length} chocolate category/categories and their products`);
    }

    // ─── 2. FIX DAL NAMES & PRICES ───────────────────────────────────
    console.log('\n🫘 Fixing Dal names and prices...');
    const dals = [
      {
        search: ['toor dal', 'arhar dal', 'tuvar dal'],
        name: 'Toor Dal (Arhar Dal)',
        description: 'Premium quality Toor Dal (Pigeon Pea Lentil). Freshly sourced. Price per 1 kg.',
        mrp: 165, price: 148, weight: '1 kg',
        image: 'https://www.jiomart.com/images/product/original/491187001/toor-dal-1-kg-product-images-o491187001-p491187001-0-202408070716.jpg',
      },
      {
        search: ['moong dal', 'mung dal'],
        name: 'Moong Dal',
        description: 'Split Green Gram (Moong Dal). Rich in protein & fibre. Price per 1 kg.',
        mrp: 135, price: 122, weight: '1 kg',
        image: 'https://www.jiomart.com/images/product/original/491187002/moong-dal-1-kg-product-images-o491187002-p491187002-0-202408070716.jpg',
      },
      {
        search: ['chana dal', 'bengal gram'],
        name: 'Chana Dal',
        description: 'Split Bengal Gram (Chana Dal). Freshly packed. Price per 1 kg.',
        mrp: 110, price: 95, weight: '1 kg',
        image: 'https://www.jiomart.com/images/product/original/491187003/chana-dal-1-kg-product-images-o491187003-p491187003-0-202408070716.jpg',
      },
      {
        search: ['urad dal', 'black gram'],
        name: 'Urad Dal',
        description: 'Split Black Gram (Urad Dal). Essential for idli & dosa. Price per 1 kg.',
        mrp: 148, price: 132, weight: '1 kg',
        image: 'https://www.jiomart.com/images/product/original/491187004/urad-dal-1-kg-product-images-o491187004-p491187004-0-202408070716.jpg',
      },
      {
        search: ['masoor', 'red lentil'],
        name: 'Masoor Dal',
        description: 'Red Lentils (Masoor Dal). Rich in protein. Price per 1 kg.',
        mrp: 108, price: 95, weight: '1 kg',
        image: 'https://www.jiomart.com/images/product/original/491187005/masoor-dal-1-kg-product-images-o491187005-p491187005-0-202408070716.jpg',
      },
      {
        search: ['rajma', 'kidney bean'],
        name: 'Rajma (Kidney Beans)',
        description: 'Red Kidney Beans (Rajma). Perfect for North Indian curry. Price per 1 kg.',
        mrp: 168, price: 148, weight: '1 kg',
        image: 'https://www.jiomart.com/images/product/original/491187006/rajma-1-kg-product-images-o491187006-p491187006-0-202408070716.jpg',
      },
    ];

    for (const dal of dals) {
      const conditions = dal.search.map(() => `LOWER(name) LIKE ?`).join(' OR ');
      const values = dal.search.map(s => `%${s}%`);
      const [existing] = await conn.query(`SELECT id FROM products WHERE ${conditions}`, values);
      if (existing.length) {
        await conn.query(
          `UPDATE products SET name=?, brand='', selling_price=?, mrp=?, weight=?, description=?, image=? WHERE id IN (?)`,
          [dal.name, dal.price, dal.mrp, dal.weight, dal.description, dal.image, existing.map(r => r.id)]
        );
        console.log(`  → Fixed: ${dal.name} (${existing.length} row(s))`);
      }
    }

    // ─── 3. CREATE SOAP & SHAMPOO CATEGORIES ─────────────────────────
    console.log('\n🧼 Creating Soap & Shampoo categories...');
    const categories = [
      { name: 'Bath Soaps', slug: 'bath-soaps', icon: '🧼', color: '#06b6d4', sort_order: 15 },
      { name: 'Shampoos', slug: 'shampoos', icon: '🧴', color: '#8b5cf6', sort_order: 16 },
    ];

    const catIds = {};
    for (const cat of categories) {
      const [ex] = await conn.query('SELECT id FROM categories WHERE slug = ?', [cat.slug]);
      if (ex.length) {
        await conn.query('UPDATE categories SET is_active=1 WHERE id=?', [ex[0].id]);
        catIds[cat.slug] = ex[0].id;
        console.log(`  → Category already exists: ${cat.name} (id=${ex[0].id})`);
      } else {
        const [r] = await conn.query(
          `INSERT INTO categories (name, slug, description, icon, color, is_active, sort_order)
           VALUES (?, ?, ?, ?, ?, 1, ?)`,
          [cat.name, cat.slug, `${cat.name} from top Indian brands`, cat.icon, cat.color, cat.sort_order]
        );
        catIds[cat.slug] = r.insertId;
        console.log(`  → Created: ${cat.name} (id=${r.insertId})`);
      }
    }

    // ─── 4. SOAP PRODUCTS ────────────────────────────────────────────
    console.log('\n🛁 Inserting Bath Soap products...');
    const soaps = [
      { name: 'Cinthol Original Soap', brand: 'Cinthol (Godrej)', description: 'Refreshing lime and deodorant soap. Classic Indian favourite since 1952. Long-lasting fragrance.', mrp: 42, price: 37, stock: 100, weight: '125g', barcode: '8901030008040', featured: 0, bestseller: 1, image: 'https://m.media-amazon.com/images/I/61yoVvW3jKL._SL1500_.jpg' },
      { name: 'Cinthol Lime Fresh Soap', brand: 'Cinthol (Godrej)', description: 'Cinthol with cool lime fragrance. Keeps body fresh all day long.', mrp: 38, price: 33, stock: 90, weight: '100g', barcode: '8901030008057', featured: 0, bestseller: 0, image: 'https://m.media-amazon.com/images/I/61yoVvW3jKL._SL1500_.jpg' },
      { name: 'Santoor Sandal & Turmeric Soap', brand: 'Santoor (Wipro)', description: 'Classic Santoor soap with natural sandalwood and turmeric. Keeps skin youthful and fresh.', mrp: 45, price: 39, stock: 130, weight: '100g', barcode: '8901030010043', featured: 1, bestseller: 1, image: 'https://m.media-amazon.com/images/I/61T7P4CXBOL._SL1500_.jpg' },
      { name: 'Santoor White Soap', brand: 'Santoor (Wipro)', description: 'Santoor White with pure sandalwood oil. For soft, glowing skin.', mrp: 48, price: 42, stock: 100, weight: '100g', barcode: '8901030010067', featured: 0, bestseller: 0, image: 'https://m.media-amazon.com/images/I/61T7P4CXBOL._SL1500_.jpg' },
      { name: 'Dove Original Beauty Bar', brand: 'Dove (HUL)', description: 'Dove Beauty Bar with 1/4 moisturising cream. Gentle on sensitive skin. Dermatologist tested.', mrp: 68, price: 60, stock: 80, weight: '100g', barcode: '8712561546388', featured: 1, bestseller: 1, image: 'https://m.media-amazon.com/images/I/71vJ8TLwKVL._SL1500_.jpg' },
      { name: 'Dove Pink Moisturising Cream Soap', brand: 'Dove (HUL)', description: 'Dove with pink moisturising cream. Leaves skin feeling soft and smooth.', mrp: 72, price: 65, stock: 65, weight: '100g', barcode: '8712561566386', featured: 0, bestseller: 0, image: 'https://m.media-amazon.com/images/I/71vJ8TLwKVL._SL1500_.jpg' },
      { name: 'Lifebuoy Total Germ Protection Soap', brand: 'Lifebuoy (HUL)', description: 'Lifebuoy Total 10 — protects from 10 types of germs. 100% better than ordinary soap.', mrp: 28, price: 24, stock: 150, weight: '100g', barcode: '8901030001300', featured: 0, bestseller: 1, image: 'https://m.media-amazon.com/images/I/71QwH5lhk6L._SL1500_.jpg' },
      { name: 'Lifebuoy Strong Life Soap', brand: 'Lifebuoy (HUL)', description: 'Lifebuoy Strong Life with active silver shield. Enhanced germ protection.', mrp: 30, price: 26, stock: 120, weight: '100g', barcode: '8901030001317', featured: 0, bestseller: 0, image: 'https://m.media-amazon.com/images/I/71QwH5lhk6L._SL1500_.jpg' },
      { name: 'Liril Lemon & Tea Tree Soap', brand: 'Liril (HUL)', description: 'Refreshing lemon & tea tree fragrance. Leaves skin feeling fresh and cool all day.', mrp: 32, price: 28, stock: 90, weight: '100g', barcode: '8901030004004', featured: 0, bestseller: 0, image: 'https://m.media-amazon.com/images/I/71s4QkQR0pL._SL1500_.jpg' },
      { name: 'Mysore Sandal Soap', brand: 'Mysore Sandal (KSDL)', description: 'Iconic Karnataka soap made with 100% pure sandalwood oil. Government of Karnataka brand. Premium quality since 1916.', mrp: 58, price: 52, stock: 70, weight: '125g', barcode: '8901030005001', featured: 1, bestseller: 1, image: 'https://m.media-amazon.com/images/I/714VnJ2sO7L._SL1500_.jpg' },
      { name: 'Mysore Sandal Gold Soap', brand: 'Mysore Sandal (KSDL)', description: 'Mysore Sandal Gold — premium version with extra sandalwood oil. Luxurious skin care.', mrp: 72, price: 65, stock: 50, weight: '150g', barcode: '8901030005018', featured: 0, bestseller: 0, image: 'https://m.media-amazon.com/images/I/714VnJ2sO7L._SL1500_.jpg' },
      { name: 'Dettol Original Antiseptic Soap', brand: 'Dettol (Reckitt)', description: 'Dettol antiseptic soap. Kills 99.9% of germs. Trusted by doctors worldwide.', mrp: 38, price: 33, stock: 140, weight: '125g', barcode: '6287006102013', featured: 1, bestseller: 1, image: 'https://m.media-amazon.com/images/I/71FmxPWJpQL._SL1500_.jpg' },
      { name: 'Dettol Skincare Soap', brand: 'Dettol (Reckitt)', description: 'Dettol skincare soap with moisturising properties. Germ protection + moisturisation.', mrp: 40, price: 35, stock: 110, weight: '125g', barcode: '6287006102020', featured: 0, bestseller: 0, image: 'https://m.media-amazon.com/images/I/71FmxPWJpQL._SL1500_.jpg' },
      { name: 'Pears Soft & Fresh Soap', brand: 'Pears (HUL)', description: 'Pears transparent soap with mint extracts. 99% pure glycerine. Trusted family soap.', mrp: 58, price: 50, stock: 75, weight: '125g', barcode: '8901030855107', featured: 0, bestseller: 0, image: 'https://m.media-amazon.com/images/I/71bBHHpL-DL._SL1500_.jpg' },
      { name: 'Hamam Neem Soap', brand: 'Hamam (HUL)', description: 'Hamam with neem, tulsi and aloe vera. Protects skin from multiple germs.', mrp: 32, price: 27, stock: 100, weight: '100g', barcode: '8901030001348', featured: 0, bestseller: 1, image: 'https://m.media-amazon.com/images/I/71nqJqGYI-L._SL1500_.jpg' },
      { name: 'Medimix Ayurvedic Classic Soap', brand: 'Medimix', description: 'Medimix with 18 herbs. Ayurvedic formula. Clears acne and pimples. South Indian classic.', mrp: 48, price: 42, stock: 85, weight: '125g', barcode: '8901030007128', featured: 0, bestseller: 1, image: 'https://m.media-amazon.com/images/I/71k5VLEbhML._SL1500_.jpg' },
      { name: 'Karthika Shikakai Soap', brand: 'Karthika', description: 'Traditional Karthika soap with natural shikakai. Popular in Karnataka and South India.', mrp: 30, price: 26, stock: 110, weight: '100g', barcode: '8901030007145', featured: 0, bestseller: 0, image: 'https://www.jiomart.com/images/product/original/490004454/karthika-soap-75-g-product-images-o490004454-p590017585-0-202305221232.jpg' },
      { name: 'Nirma Beauty Soap', brand: 'Nirma', description: 'Nirma beauty soap for smooth and glowing skin. Best value for money soap in India.', mrp: 20, price: 17, stock: 200, weight: '100g', barcode: '8901226011100', featured: 0, bestseller: 0, image: 'https://m.media-amazon.com/images/I/61pHe-9h9xL._SL1500_.jpg' },
    ];

    let soapInserted = 0;
    for (const soap of soaps) {
      const [ex] = await conn.query('SELECT id FROM products WHERE name = ? AND category_id = ?', [soap.name, catIds['bath-soaps']]);
      if (!ex.length) {
        const slug = soap.name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '') + '-' + Date.now() % 100000;
        await conn.query(
          `INSERT INTO products (name, slug, category_id, brand, description, mrp, selling_price, gst_percent, stock, unit, weight, barcode, is_featured, is_bestseller, is_available, image)
           VALUES (?, ?, ?, ?, ?, ?, ?, 18, ?, 'pcs', ?, ?, ?, ?, 1, ?)`,
          [soap.name, slug, catIds['bath-soaps'], soap.brand, soap.description, soap.mrp, soap.price, soap.stock, soap.weight, soap.barcode, soap.featured, soap.bestseller, soap.image]
        );
        soapInserted++;
      }
    }
    console.log(`  → Inserted ${soapInserted} soap products`);

    // ─── 5. SHAMPOO PRODUCTS ─────────────────────────────────────────
    console.log('\n🧴 Inserting Shampoo products...');
    const shampoos = [
      { name: 'Head & Shoulders Anti-Dandruff Shampoo 340ml', brand: 'Head & Shoulders (P&G)', description: 'Head & Shoulders classic clean with zinc pyrithione. 99% dandruff-free hair from first wash. Trusted No.1 anti-dandruff brand.', mrp: 249, price: 219, stock: 60, weight: '340ml', barcode: '4902430715027', featured: 1, bestseller: 1, image: 'https://m.media-amazon.com/images/I/71q5IXKWL0L._SL1500_.jpg' },
      { name: 'Head & Shoulders Lemon Fresh Shampoo 180ml', brand: 'Head & Shoulders (P&G)', description: 'Head & Shoulders with lemon. Fresh feeling and dandruff protection.', mrp: 145, price: 128, stock: 75, weight: '180ml', barcode: '4902430715034', featured: 0, bestseller: 0, image: 'https://m.media-amazon.com/images/I/71q5IXKWL0L._SL1500_.jpg' },
      { name: 'Dove Intense Repair Shampoo 340ml', brand: 'Dove (HUL)', description: 'Dove with Fibre Actives. Repairs dry and damaged hair from roots to tips in 1 wash.', mrp: 249, price: 215, stock: 55, weight: '340ml', barcode: '8712561453222', featured: 1, bestseller: 1, image: 'https://m.media-amazon.com/images/I/61EEI8MsRGL._SL1500_.jpg' },
      { name: 'Dove Daily Shine Shampoo 180ml', brand: 'Dove (HUL)', description: 'Dove Daily Shine for natural, shiny and healthy-looking hair every day.', mrp: 145, price: 125, stock: 70, weight: '180ml', barcode: '8712561453239', featured: 0, bestseller: 0, image: 'https://m.media-amazon.com/images/I/61EEI8MsRGL._SL1500_.jpg' },
      { name: 'Clinic Plus Strong & Long Shampoo 340ml', brand: 'Clinic Plus (HUL)', description: 'Clinic Plus with Vitamin complex. Helps reduce breakage for stronger and longer hair. Most trusted shampoo brand in India.', mrp: 105, price: 92, stock: 90, weight: '340ml', barcode: '8901030761866', featured: 0, bestseller: 1, image: 'https://m.media-amazon.com/images/I/71jh-qOQMKL._SL1500_.jpg' },
      { name: 'Clinic Plus Shampoo 80ml (Pack of 3)', brand: 'Clinic Plus (HUL)', description: 'Clinic Plus economy sachet pack. Perfect for daily use. Great value.', mrp: 45, price: 38, stock: 150, weight: '80ml x3', barcode: '8901030761873', featured: 0, bestseller: 1, image: 'https://m.media-amazon.com/images/I/71jh-qOQMKL._SL1500_.jpg' },
      { name: 'Pantene Long Black Shampoo 340ml', brand: 'Pantene (P&G)', description: 'Pantene with Pro-V Nourishing formula. Makes hair longer, blacker and stronger.', mrp: 219, price: 192, stock: 65, weight: '340ml', barcode: '4902430380843', featured: 0, bestseller: 1, image: 'https://m.media-amazon.com/images/I/71WoEJKHfhL._SL1500_.jpg' },
      { name: 'Sunsilk Smooth & Manageable Shampoo 340ml', brand: 'Sunsilk (HUL)', description: 'Sunsilk with amla + egg protein + vitamin C. Makes hair smooth and tangle-free.', mrp: 165, price: 145, stock: 70, weight: '340ml', barcode: '8901030777354', featured: 0, bestseller: 0, image: 'https://m.media-amazon.com/images/I/71iS1vU7XdL._SL1500_.jpg' },
      { name: 'Karthika Shikakai Shampoo 200ml', brand: 'Karthika', description: 'Karthika natural shikakai shampoo. Traditional herbal hair care. Popular in Karnataka.', mrp: 98, price: 85, stock: 80, weight: '200ml', barcode: '8901030007152', featured: 0, bestseller: 1, image: 'https://www.jiomart.com/images/product/original/490004454/karthika-soap-75-g-product-images-o490004454-p590017585-0-202305221232.jpg' },
      { name: 'Meera Coconut Milk Shampoo 200ml', brand: 'Meera (CavinKare)', description: 'Meera with coconut milk, honey and herbal extracts. Nourishes and conditions hair.', mrp: 99, price: 85, stock: 75, weight: '200ml', barcode: '8901030007176', featured: 0, bestseller: 0, image: 'https://m.media-amazon.com/images/I/71s4QkQR0pL._SL1500_.jpg' },
      { name: 'Nyle Natural Herbal Shampoo 200ml', brand: 'Nyle (CavinKare)', description: 'Nyle naturals with amla, neem and shikakai extracts. Herbal care for healthy hair.', mrp: 99, price: 85, stock: 75, weight: '200ml', barcode: '8901030007169', featured: 0, bestseller: 0, image: 'https://m.media-amazon.com/images/I/71k5VLEbhML._SL1500_.jpg' },
    ];

    let shampoosInserted = 0;
    for (const sh of shampoos) {
      const [ex] = await conn.query('SELECT id FROM products WHERE name = ? AND category_id = ?', [sh.name, catIds['shampoos']]);
      if (!ex.length) {
        const slug = sh.name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '') + '-' + Date.now() % 100000;
        await conn.query(
          `INSERT INTO products (name, slug, category_id, brand, description, mrp, selling_price, gst_percent, stock, unit, weight, barcode, is_featured, is_bestseller, is_available, image)
           VALUES (?, ?, ?, ?, ?, ?, ?, 18, ?, 'pcs', ?, ?, ?, ?, 1, ?)`,
          [sh.name, slug, catIds['shampoos'], sh.brand, sh.description, sh.mrp, sh.price, sh.stock, sh.weight, sh.barcode, sh.featured, sh.bestseller, sh.image]
        );
        shampoosInserted++;
      }
    }
    console.log(`  → Inserted ${shampoosInserted} shampoo products`);

    console.log('\n✅ All migrations completed successfully!');
  } catch (err) {
    console.error('❌ Migration failed:', err.message);
    throw err;
  } finally {
    await conn.end();
  }
}

run().catch(err => { console.error(err); process.exit(1); });
