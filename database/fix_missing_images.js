const fs = require('fs');
const path = require('path');
const https = require('https');
const mysql = require('mysql2/promise');
require('dotenv').config({ path: '.env' });

const UPLOADS_DIR = path.join(__dirname, '..', 'uploads');

const DB = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'Yash@mysql25',
  database: process.env.DB_NAME || 'rathi_traders',
};

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

function getFallbackKey(name) {
  const n = name.toLowerCase();
  if (n.includes('soap') || n.includes('bar')) return 'soap';
  if (n.includes('shampoo')) return 'shampoo';
  if (n.includes('dal') || n.includes('lentil') || n.includes('rajma') || n.includes('chana')) return 'dal';
  if (n.includes('rice') || n.includes('basmati')) return 'rice';
  if (n.includes('atta') || n.includes('flour') || n.includes('maida') || n.includes('besan')) return 'atta';
  if (n.includes('oil') || n.includes('ghee')) return 'oil';
  if (n.includes('spice') || n.includes('masala') || n.includes('haldi') || n.includes('jeera')) return 'spice';
  if (n.includes('biscuit') || n.includes('cookie') || n.includes('parle')) return 'biscuit';
  if (n.includes('tea') || n.includes('chai')) return 'tea';
  if (n.includes('coffee')) return 'coffee';
  if (n.includes('noodle') || n.includes('maggi') || n.includes('pasta')) return 'noodles';
  return 'default';
}

function download(url, dest) {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(dest);
    https.get(url, (response) => {
      if (response.statusCode === 301 || response.statusCode === 302) {
        return download(response.headers.location, dest).then(resolve).catch(reject);
      }
      response.pipe(file);
      file.on('finish', () => { file.close(); resolve(); });
    }).on('error', err => reject(err));
  });
}

async function run() {
  const conn = await mysql.createConnection(DB);
  console.log('✅ Connected. Checking missing images...');

  const [products] = await conn.query('SELECT id, name, image FROM products WHERE is_available = 1');
  
  let downloaded = 0;
  for (const product of products) {
    if (!product.image || product.image.startsWith('http')) continue;

    const filePath = path.join(UPLOADS_DIR, product.image);
    if (!fs.existsSync(filePath)) {
      const fallbackUrl = FALLBACK_IMAGES[getFallbackKey(product.name)];
      try {
        console.log(`Downloading placeholder for: ${product.image} (${product.name})`);
        await download(fallbackUrl, filePath);
        downloaded++;
        // Be gentle on unsplash
        await new Promise(r => setTimeout(r, 200));
      } catch (err) {
        console.error(`Failed to download for ${product.name}`, err);
      }
    }
  }

  console.log(`\n✅ Done! Fixed ${downloaded} missing images.`);
  await conn.end();
}

run().catch(console.error);
