/**
 * RATHI TRADERS — Image Downloader
 * Downloads real product images locally so they never break.
 * Run: node database/download_images.js
 */

const https = require('https');
const http = require('http');
const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');
require('dotenv').config({ path: '.env' });

const UPLOADS_DIR = path.join(__dirname, '..', 'uploads');
if (!fs.existsSync(UPLOADS_DIR)) fs.mkdirSync(UPLOADS_DIR, { recursive: true });

const DB = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'Yash@mysql25',
  database: process.env.DB_NAME || 'rathi_traders',
};

// Product image map: barcode/name → working image URL
// Using Open Food Facts (public domain) + static CDN sources that allow hotlinking
const IMAGE_MAP = {
  // ─── BATH SOAPS ───────────────────────────────────────────────────
  'Cinthol Original Soap':              'https://www.bigbasket.com/media/uploads/p/xl/40054594_5-cinthol-original-soap-bar.jpg',
  'Cinthol Lime Fresh Soap':            'https://www.bigbasket.com/media/uploads/p/xl/40054594_5-cinthol-original-soap-bar.jpg',
  'Santoor Sandal & Turmeric Soap':     'https://www.bigbasket.com/media/uploads/p/xl/217296_7-santoor-sandal-turmeric-soap.jpg',
  'Santoor White Soap':                 'https://www.bigbasket.com/media/uploads/p/xl/217296_7-santoor-sandal-turmeric-soap.jpg',
  'Dove Original Beauty Bar':           'https://www.bigbasket.com/media/uploads/p/xl/40010468_7-dove-beauty-bathing-bar-original.jpg',
  'Dove Pink Moisturising Cream Soap':  'https://www.bigbasket.com/media/uploads/p/xl/40010468_7-dove-beauty-bathing-bar-original.jpg',
  'Lifebuoy Total Germ Protection Soap':'https://www.bigbasket.com/media/uploads/p/xl/40050279_4-lifebuoy-total-germ-protection-bar.jpg',
  'Lifebuoy Strong Life Soap':          'https://www.bigbasket.com/media/uploads/p/xl/40050279_4-lifebuoy-total-germ-protection-bar.jpg',
  'Liril Lemon & Tea Tree Soap':        'https://www.bigbasket.com/media/uploads/p/xl/272513_6-liril-cool-fresh-lemon-tea-tree-soap.jpg',
  'Mysore Sandal Soap':                 'https://www.bigbasket.com/media/uploads/p/xl/40152984-4-mysore-sandal-classic-soap.jpg',
  'Mysore Sandal Gold Soap':            'https://www.bigbasket.com/media/uploads/p/xl/40152984-4-mysore-sandal-classic-soap.jpg',
  'Dettol Original Antiseptic Soap':    'https://www.bigbasket.com/media/uploads/p/xl/40020786_10-dettol-original-antibacterial-bathing-soap-bar.jpg',
  'Dettol Skincare Soap':               'https://www.bigbasket.com/media/uploads/p/xl/40020786_10-dettol-original-antibacterial-bathing-soap-bar.jpg',
  'Pears Soft & Fresh Soap':            'https://www.bigbasket.com/media/uploads/p/xl/233137_6-pears-soft-fresh-soap.jpg',
  'Hamam Neem Soap':                    'https://www.bigbasket.com/media/uploads/p/xl/40048609_6-hamam-neem-soap-bar.jpg',
  'Medimix Ayurvedic Classic Soap':     'https://www.bigbasket.com/media/uploads/p/xl/296555_7-medimix-classic-18-herbs-soap.jpg',
  'Karthika Shikakai Soap':             'https://www.bigbasket.com/media/uploads/p/xl/200014543_2-karthika-shikakai-soap.jpg',
  'Nirma Beauty Soap':                  'https://www.bigbasket.com/media/uploads/p/xl/216213_6-nirma-beauty-soap.jpg',

  // ─── SHAMPOOS ─────────────────────────────────────────────────────
  'Head & Shoulders Anti-Dandruff Shampoo 340ml': 'https://www.bigbasket.com/media/uploads/p/xl/40001597_13-head-shoulders-anti-dandruff-shampoo-lemon-fresh.jpg',
  'Head & Shoulders Lemon Fresh Shampoo 180ml':   'https://www.bigbasket.com/media/uploads/p/xl/40001597_13-head-shoulders-anti-dandruff-shampoo-lemon-fresh.jpg',
  'Dove Intense Repair Shampoo 340ml':             'https://www.bigbasket.com/media/uploads/p/xl/40015440_8-dove-intense-repair-shampoo.jpg',
  'Dove Daily Shine Shampoo 180ml':                'https://www.bigbasket.com/media/uploads/p/xl/40015440_8-dove-intense-repair-shampoo.jpg',
  'Clinic Plus Strong & Long Shampoo 340ml':       'https://www.bigbasket.com/media/uploads/p/xl/40002139_12-clinic-plus-strong-long-health-shampoo.jpg',
  'Clinic Plus Shampoo 80ml (Pack of 3)':          'https://www.bigbasket.com/media/uploads/p/xl/40002139_12-clinic-plus-strong-long-health-shampoo.jpg',
  'Pantene Long Black Shampoo 340ml':              'https://www.bigbasket.com/media/uploads/p/xl/40001612_11-pantene-long-black-shampoo.jpg',
  'Sunsilk Smooth & Manageable Shampoo 340ml':     'https://www.bigbasket.com/media/uploads/p/xl/40001611_9-sunsilk-natural-recharge-with-sunflower-oil-aloe-vera-shampoo.jpg',
  'Karthika Shikakai Shampoo 200ml':               'https://www.bigbasket.com/media/uploads/p/xl/200014543_2-karthika-shikakai-soap.jpg',
  'Meera Coconut Milk Shampoo 200ml':              'https://www.bigbasket.com/media/uploads/p/xl/40001613_9-meera-natural-shampoo-with-coconut-milk-honey.jpg',
  'Nyle Natural Herbal Shampoo 200ml':             'https://www.bigbasket.com/media/uploads/p/xl/40001614_6-nyle-naturals-anti-hair-fall-shampoo.jpg',
};

// Fallback product-specific images using a reliable free image service
const FALLBACK_IMAGES = {
  'soap':     'https://images.unsplash.com/photo-1607006344380-b6775a0824a7?w=400&h=400&fit=crop&auto=format',
  'shampoo':  'https://images.unsplash.com/photo-1585751119414-ef2636f8aede?w=400&h=400&fit=crop&auto=format',
  'dal':      'https://images.unsplash.com/photo-1613329507686-df05be9de580?w=400&h=400&fit=crop&auto=format',
  'rice':     'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&h=400&fit=crop&auto=format',
  'atta':     'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400&h=400&fit=crop&auto=format',
  'oil':      'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400&h=400&fit=crop&auto=format',
  'spice':    'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=400&h=400&fit=crop&auto=format',
  'biscuit':  'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=400&h=400&fit=crop&auto=format',
  'tea':      'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=400&h=400&fit=crop&auto=format',
  'coffee':   'https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=400&h=400&fit=crop&auto=format',
  'noodles':  'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&h=400&fit=crop&auto=format',
  'default':  'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400&h=400&fit=crop&auto=format',
};

function downloadFile(url, dest) {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(dest);
    const proto = url.startsWith('https') ? https : http;
    const options = {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'image/webp,image/png,image/jpeg,image/*',
        'Referer': 'https://www.google.com/',
      }
    };
    proto.get(url, options, (response) => {
      if (response.statusCode === 301 || response.statusCode === 302) {
        file.close();
        fs.unlinkSync(dest);
        return downloadFile(response.headers.location, dest).then(resolve).catch(reject);
      }
      if (response.statusCode !== 200) {
        file.close();
        fs.unlinkSync(dest);
        return reject(new Error(`HTTP ${response.statusCode}`));
      }
      response.pipe(file);
      file.on('finish', () => { file.close(); resolve(); });
    }).on('error', (err) => {
      file.close();
      try { fs.unlinkSync(dest); } catch {}
      reject(err);
    });
  });
}

function getFilenameForProduct(name) {
  return name.toLowerCase().replace(/[^a-z0-9]+/g, '_').substring(0, 50) + '.jpg';
}

function getFallbackKey(name) {
  const n = name.toLowerCase();
  if (n.includes('soap') || n.includes('bar')) return 'soap';
  if (n.includes('shampoo')) return 'shampoo';
  if (n.includes('dal') || n.includes('lentil') || n.includes('rajma')) return 'dal';
  if (n.includes('rice') || n.includes('basmati')) return 'rice';
  if (n.includes('atta') || n.includes('flour') || n.includes('maida')) return 'atta';
  if (n.includes('oil') || n.includes('ghee')) return 'oil';
  if (n.includes('spice') || n.includes('masala') || n.includes('haldi') || n.includes('jeera')) return 'spice';
  if (n.includes('biscuit') || n.includes('cookie')) return 'biscuit';
  if (n.includes('tea') || n.includes('chai')) return 'tea';
  if (n.includes('coffee')) return 'coffee';
  if (n.includes('noodle') || n.includes('maggi') || n.includes('pasta')) return 'noodles';
  return 'default';
}

async function run() {
  const conn = await mysql.createConnection(DB);
  console.log('✅ Connected to database\n');

  // Get all products with http image URLs
  const [products] = await conn.query(`SELECT id, name, image FROM products WHERE image LIKE 'http%' OR image IS NULL OR image = ''`);
  console.log(`📦 Found ${products.length} products with external/missing images\n`);

  let fixed = 0, failed = 0;

  for (const product of products) {
    const filename = getFilenameForProduct(product.name);
    const dest = path.join(UPLOADS_DIR, filename);

    // Skip if already downloaded
    if (fs.existsSync(dest) && fs.statSync(dest).size > 5000) {
      await conn.query('UPDATE products SET image = ? WHERE id = ?', [filename, product.id]);
      fixed++;
      continue;
    }

    // Try IMAGE_MAP first, then fallback
    const mappedUrl = IMAGE_MAP[product.name];
    const fallbackUrl = FALLBACK_IMAGES[getFallbackKey(product.name)];
    const urlsToTry = [mappedUrl, fallbackUrl].filter(Boolean);

    let downloaded = false;
    for (const url of urlsToTry) {
      try {
        await downloadFile(url, dest);
        // Check file is valid (>5KB)
        if (fs.existsSync(dest) && fs.statSync(dest).size > 5000) {
          await conn.query('UPDATE products SET image = ? WHERE id = ?', [filename, product.id]);
          console.log(`  ✅ ${product.name.substring(0, 45)}`);
          fixed++;
          downloaded = true;
          break;
        } else {
          try { fs.unlinkSync(dest); } catch {}
        }
      } catch (e) {
        try { if (fs.existsSync(dest)) fs.unlinkSync(dest); } catch {}
      }
    }

    if (!downloaded) {
      // Store the unsplash fallback URL directly in the DB (it works as external URL)
      await conn.query('UPDATE products SET image = ? WHERE id = ?', [fallbackUrl, product.id]);
      console.log(`  ⚠️  ${product.name.substring(0, 45)} → using Unsplash fallback`);
      failed++;
    }

    // Small delay to be polite
    await new Promise(r => setTimeout(r, 100));
  }

  console.log(`\n✅ Done! Fixed: ${fixed}, Fallback: ${failed}`);
  await conn.end();
}

run().catch(err => { console.error('❌', err); process.exit(1); });
