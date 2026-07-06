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

const IMAGE_MAP = {
  // Atta
  'Aashirvaad Whole Wheat Atta': 'https://www.bigbasket.com/media/uploads/p/xl/126906_8-aashirvaad-atta-whole-wheat.jpg',
  'Aashirvaad Select Sharbati Atta': 'https://www.bigbasket.com/media/uploads/p/xl/161826_9-aashirvaad-select-premium-sharbati-atta.jpg',
  'Fortune Chakki Fresh Atta': 'https://www.bigbasket.com/media/uploads/p/xl/161826_9-aashirvaad-select-premium-sharbati-atta.jpg', // fallback visually
  'Patanjali Atta': 'https://www.bigbasket.com/media/uploads/p/xl/40128859_4-patanjali-whole-wheat-atta-traditional.jpg',
  'Rajdhani Maida': 'https://www.bigbasket.com/media/uploads/p/xl/10000411_16-rajdhani-maida.jpg',
  'Ganesh Besan': 'https://www.bigbasket.com/media/uploads/p/xl/10000570_13-ganesh-besan.jpg',
  
  // Rice
  'India Gate Classic Basmati Rice': 'https://www.bigbasket.com/media/uploads/p/xl/241600_6-india-gate-basmati-rice-classic.jpg',
  'Daawat Rozana Basmati Rice': 'https://www.bigbasket.com/media/uploads/p/xl/10000335_15-daawat-rozana-gold-basmati-rice.jpg',
  'Kohinoor Super Value Basmati': 'https://www.bigbasket.com/media/uploads/p/xl/10000335_15-daawat-rozana-gold-basmati-rice.jpg', // fallback
  
  // Oil & Ghee
  'Amul Pure Ghee': 'https://www.bigbasket.com/media/uploads/p/xl/104414_8-amul-pure-ghee.jpg',
  'Nandini Pure Ghee': 'https://www.bigbasket.com/media/uploads/p/xl/40003378_5-nandini-pure-ghee.jpg',
  'Fortune Sunlite Refined Sunflower Oil': 'https://www.bigbasket.com/media/uploads/p/xl/274145_14-fortune-sunlite-refined-sunflower-oil.jpg',
  'Dhara Mustard Oil': 'https://www.bigbasket.com/media/uploads/p/xl/274120_5-dhara-mustard-oil-kachchi-ghani.jpg',
  
  // Salt & Sugar
  'Tata Salt Crystal': 'https://www.bigbasket.com/media/uploads/p/xl/241600_6-india-gate-basmati-rice-classic.jpg', // No wait, let's fix
  'Tata Salt': 'https://www.bigbasket.com/media/uploads/p/xl/241600_6-india-gate-basmati-rice-classic.jpg',
  
  // Let's use direct reliable bb links:
  'Tata Salt Crystal': 'https://www.bigbasket.com/media/uploads/p/xl/40022204_6-tata-salt-crystal-iodised.jpg',
  'Tata Salt': 'https://www.bigbasket.com/media/uploads/p/xl/241600_6-india-gate-basmati-rice-classic.jpg', // this is rice!
  'Madhur Pure & Hygienic Sugar': 'https://www.bigbasket.com/media/uploads/p/xl/40019396_10-madhur-sugar-pure-hygienic-fine-grain-natural-white-sweet.jpg',
  
  // Fix Tata Salt:
  'Tata Salt': 'https://www.bigbasket.com/media/uploads/p/xl/126906_8-aashirvaad-atta-whole-wheat.jpg', // WRONG
};

const PROPER_IMAGE_MAP = {
  // ATTA & RICE
  'Aashirvaad Whole Wheat Atta': 'https://www.bigbasket.com/media/uploads/p/xl/126906_8-aashirvaad-atta-whole-wheat.jpg',
  'Aashirvaad Select Sharbati Atta': 'https://www.bigbasket.com/media/uploads/p/xl/161826_9-aashirvaad-select-premium-sharbati-atta.jpg',
  'Fortune Chakki Fresh Atta': 'https://www.bigbasket.com/media/uploads/p/xl/126903_8-fortune-atta-chakki-fresh.jpg',
  'Patanjali Atta': 'https://www.bigbasket.com/media/uploads/p/xl/40128859_4-patanjali-whole-wheat-atta-traditional.jpg',
  'Rajdhani Maida': 'https://www.bigbasket.com/media/uploads/p/xl/10000411_16-rajdhani-maida.jpg',
  'Ganesh Besan': 'https://www.bigbasket.com/media/uploads/p/xl/10000570_13-ganesh-besan.jpg',
  'India Gate Classic Basmati Rice': 'https://www.bigbasket.com/media/uploads/p/xl/241600_6-india-gate-basmati-rice-classic.jpg',
  'Daawat Rozana Basmati Rice': 'https://www.bigbasket.com/media/uploads/p/xl/10000335_15-daawat-rozana-gold-basmati-rice.jpg',

  // OIL & GHEE
  'Amul Pure Ghee': 'https://www.bigbasket.com/media/uploads/p/xl/104414_8-amul-pure-ghee.jpg',
  'Nandini Pure Ghee': 'https://www.bigbasket.com/media/uploads/p/xl/40003378_5-nandini-pure-ghee.jpg',
  'Patanjali Cow Ghee': 'https://www.bigbasket.com/media/uploads/p/xl/40013066_4-patanjali-cow-ghee.jpg',
  'Fortune Sunlite Refined Sunflower Oil': 'https://www.bigbasket.com/media/uploads/p/xl/274145_14-fortune-sunlite-refined-sunflower-oil.jpg',
  'Dhara Mustard Oil': 'https://www.bigbasket.com/media/uploads/p/xl/274120_5-dhara-mustard-oil-kachchi-ghani.jpg',

  // SALT, SUGAR & SPICES
  'Tata Salt Crystal': 'https://www.bigbasket.com/media/uploads/p/xl/40022204_6-tata-salt-crystal-iodised.jpg',
  'Tata Salt': 'https://www.bigbasket.com/media/uploads/p/xl/241600_6-tata-salt-iodized.jpg',
  'Madhur Pure & Hygienic Sugar': 'https://www.bigbasket.com/media/uploads/p/xl/40019396_10-madhur-sugar-pure-hygienic-fine-grain-natural-white-sweet.jpg',
  'MDH Chana Masala': 'https://www.bigbasket.com/media/uploads/p/xl/115598_4-mdh-masala-chana.jpg',
  'Everest Kitchen King Masala': 'https://www.bigbasket.com/media/uploads/p/xl/113642_4-everest-masala-kitchen-king.jpg',
  'Catch Turmeric Powder': 'https://www.bigbasket.com/media/uploads/p/xl/113617_4-catch-powder-turmeric.jpg',

  // BISCUITS & SNACKS
  'Parle-G Original Glucose Biscuits': 'https://www.bigbasket.com/media/uploads/p/xl/102061_8-parle-g-glucose-biscuits.jpg',
  'Sunfeast Dark Fantasy Choco Fills': 'https://www.bigbasket.com/media/uploads/p/xl/264426_4-sunfeast-dark-fantasy-choco-fills.jpg',
  'Britannia Good Day Cashew': 'https://www.bigbasket.com/media/uploads/p/xl/1202861_3-britannia-good-day-cashew-cookies.jpg',
  'Britannia Marie Gold': 'https://www.bigbasket.com/media/uploads/p/xl/10000075_29-britannia-marie-gold-biscuits.jpg',
  'Oreo Vanilla Cream': 'https://www.bigbasket.com/media/uploads/p/xl/1200155_2-cadbury-oreo-creme-biscuit-vanilla.jpg',
  'Haldirams Bhujia Sev': 'https://www.bigbasket.com/media/uploads/p/xl/112675_8-haldirams-namkeen-bhujia-sev.jpg',
  'Lays Classic Salted': 'https://www.bigbasket.com/media/uploads/p/xl/294269_19-lays-potato-chips-classic-salted.jpg',
  'Maggi 2-Minute Masala Noodles': 'https://www.bigbasket.com/media/uploads/p/xl/266109_19-maggi-2-minute-instant-noodles-masala.jpg',

  // BEVERAGES
  'Taj Mahal Tea': 'https://www.bigbasket.com/media/uploads/p/xl/212629_8-taj-mahal-tea.jpg',
  'Red Label Tea': 'https://www.bigbasket.com/media/uploads/p/xl/212622_8-brooke-bond-red-label-tea.jpg',
  'Nescafe Classic Coffee': 'https://www.bigbasket.com/media/uploads/p/xl/266205_15-nescafe-classic-instant-coffee.jpg',
  'Bru Instant Coffee': 'https://www.bigbasket.com/media/uploads/p/xl/10000083_16-bru-instant-coffee.jpg',

  // BABY & PERSONAL CARE
  'Johnson\'s Baby Soap': 'https://www.bigbasket.com/media/uploads/p/xl/10000216_14-johnsons-baby-soap.jpg',
  'Dove Cream Beauty Soap': 'https://www.bigbasket.com/media/uploads/p/xl/40010468_7-dove-beauty-bathing-bar-original.jpg', // alias
  'Colgate Strong Teeth Toothpaste': 'https://www.bigbasket.com/media/uploads/p/xl/10000089_19-colgate-strong-teeth-anticavity-toothpaste.jpg',

  // CLEANING
  'Harpic Power Plus Toilet Cleaner': 'https://www.bigbasket.com/media/uploads/p/xl/224213_7-harpic-power-plus-toilet-cleaner-original.jpg',
  'Surf Excel Easy Wash Detergent': 'https://www.bigbasket.com/media/uploads/p/xl/266948_14-surf-excel-easy-wash-detergent-powder.jpg',
  'Ariel Complete Detergent Powder': 'https://www.bigbasket.com/media/uploads/p/xl/214152_12-ariel-complete-detergent-powder.jpg',
  'Vim Dishwash Liquid': 'https://www.bigbasket.com/media/uploads/p/xl/10000249_11-vim-dishwash-gel-lemon.jpg',
  'Lizol Floor Cleaner Citrus': 'https://www.bigbasket.com/media/uploads/p/xl/224214_7-lizol-disinfectant-surface-floor-cleaner-citrus.jpg'
};

function download(url, dest) {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(dest);
    https.get(url, { headers: { 'User-Agent': 'Mozilla/5.0' } }, (response) => {
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
  console.log('✅ Connected. Downloading REAL images...');

  const [products] = await conn.query('SELECT id, name, image FROM products WHERE is_available = 1');
  
  let downloaded = 0;
  for (const product of products) {
    if (!product.image) continue;
    
    // Check if we have a proper real image mapped
    const realImgUrl = PROPER_IMAGE_MAP[product.name];
    if (realImgUrl) {
      const filePath = path.join(UPLOADS_DIR, product.image);
      console.log(`Downloading REAL image for: ${product.name}`);
      try {
        await download(realImgUrl, filePath);
        downloaded++;
        await new Promise(r => setTimeout(r, 100)); // be nice to BB
      } catch (err) {
        console.error(`Failed to download for ${product.name}`, err);
      }
    }
  }

  console.log(`\n✅ Done! Downloaded ${downloaded} REAL images for top products.`);
  await conn.end();
}

run().catch(console.error);
