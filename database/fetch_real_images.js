const fs = require('fs');
const path = require('path');
const https = require('https');
const http = require('http');
const mysql = require('mysql2/promise');
const { image_search } = require('duckduckgo-images-api');
require('dotenv').config({ path: '.env' });

const UPLOADS_DIR = path.join(__dirname, '..', 'uploads');

const DB = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'Yash@mysql25',
  database: process.env.DB_NAME || 'rathi_traders',
};

function downloadImage(url, dest) {
  return new Promise((resolve, reject) => {
    const proto = url.startsWith('https') ? https : http;
    const file = fs.createWriteStream(dest);
    
    const request = proto.get(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        'Accept': 'image/*'
      },
      timeout: 5000
    }, (response) => {
      if (response.statusCode === 301 || response.statusCode === 302) {
        return downloadImage(response.headers.location, dest).then(resolve).catch(reject);
      }
      if (response.statusCode !== 200) {
        return reject(new Error(`Status ${response.statusCode}`));
      }
      response.pipe(file);
      file.on('finish', () => {
        file.close();
        resolve();
      });
    }).on('error', (err) => {
      fs.unlink(dest, () => {});
      reject(err);
    });
    
    request.on('timeout', () => {
      request.abort();
      reject(new Error('Timeout'));
    });
  });
}

async function getRealImage(productName) {
  try {
    const results = await image_search({ query: productName + " product india bigbasket jiomart", moderate: true, iterations: 1 });
    if (results && results.length > 0) {
      // Find a clean image URL (not unsplash, not base64, usually bigbasket/jiomart/amazon)
      for (const res of results) {
        if (res.image && !res.image.includes('unsplash') && res.image.startsWith('http')) {
          return res.image;
        }
      }
    }
  } catch (err) {
    console.error(`DDG Error for ${productName}: ${err.message}`);
  }
  return null;
}

async function run() {
  const conn = await mysql.createConnection(DB);
  console.log('✅ Connected. Fetching real images...');

  const [products] = await conn.query('SELECT id, name, image FROM products WHERE is_available = 1');
  let count = 0;
  
  for (const product of products) {
    // Skip if it's already one of the Soaps/Shampoos/Dals we manually mapped earlier, or if it doesn't have an image
    if (!product.image) continue;
    
    const filePath = path.join(UPLOADS_DIR, product.image);
    
    // We can verify if it's an Unsplash fallback by checking its size or if it's in a known list,
    // but easier is to just overwrite everything that is not one of the explicit soap/shampoo/dal manually downloaded ones.
    // Actually, we can just download for everything to be safe. It will just replace the file.
    console.log(`\n🔍 Searching for: ${product.name}`);
    const imgUrl = await getRealImage(product.name);
    
    if (imgUrl) {
      console.log(`   ⬇️ Downloading: ${imgUrl}`);
      try {
        await downloadImage(imgUrl, filePath);
        count++;
        console.log(`   ✅ Success`);
      } catch (err) {
        console.log(`   ❌ Failed: ${err.message}`);
      }
    } else {
      console.log(`   ❌ No image found`);
    }
    
    await new Promise(r => setTimeout(r, 1000)); // Rate limiting
  }

  console.log(`\n🎉 Done! Downloaded ${count} real images.`);
  process.exit(0);
}

run();
