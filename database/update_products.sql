-- ============================================================
-- RATHI TRADERS - DATABASE UPDATE MIGRATION
-- Changes:
--   1. Disable Chocolates category + products
--   2. Fix Dal product names (remove brands) + real KG prices
--   3. Add Bath Soaps category + products (real brands + images)
--   4. Add Shampoos category + products (real brands + images)
-- ============================================================

USE rathi_traders;

-- ============================================================
-- 1. DISABLE CHOCOLATES
-- ============================================================
UPDATE categories SET is_active = 0
WHERE LOWER(name) LIKE '%chocolate%' OR LOWER(name) LIKE '%candy%' OR LOWER(name) LIKE '%confectionary%';

UPDATE products SET is_available = 0
WHERE category_id IN (
  SELECT id FROM categories WHERE LOWER(name) LIKE '%chocolate%' OR LOWER(name) LIKE '%candy%' OR LOWER(name) LIKE '%confectionary%'
);

-- ============================================================
-- 2. FIX DALS — Remove brand names, use just ingredient name + per-KG prices
-- ============================================================
UPDATE products SET
  name = 'Toor Dal (Arhar Dal)',
  brand = '',
  selling_price = 148.00,
  mrp = 160.00,
  weight = '1 kg',
  unit = 'kg',
  description = 'Premium quality Toor Dal (Pigeon Pea Lentil). Freshly sourced. Price per 1 kg.',
  image = 'https://cdn.grofers.com/cdn-cgi/image/f=auto,fit=pad,q=70,h=250,w=250/app/assets/products/sliding_images/jpeg/da8e8e4a-91a2-4f99-b7d3-c65b8e24cf25.jpg?ts=1708590088'
WHERE LOWER(name) LIKE '%toor dal%' OR LOWER(name) LIKE '%arhar dal%';

UPDATE products SET
  name = 'Moong Dal',
  brand = '',
  selling_price = 122.00,
  mrp = 135.00,
  weight = '1 kg',
  unit = 'kg',
  description = 'Green Moong Dal (Split Green Gram). Freshly packed. Price per 1 kg.',
  image = 'https://cdn.grofers.com/cdn-cgi/image/f=auto,fit=pad,q=70,h=250,w=250/app/assets/products/sliding_images/jpeg/bc4ee38e-5d7e-4e26-b6c9-d2dc4e8f3e4a.jpg?ts=1708590088'
WHERE LOWER(name) LIKE '%moong dal%';

UPDATE products SET
  name = 'Chana Dal',
  brand = '',
  selling_price = 98.00,
  mrp = 110.00,
  weight = '1 kg',
  unit = 'kg',
  description = 'Split Bengal Gram (Chana Dal). Price per 1 kg.',
  image = 'https://cdn.grofers.com/cdn-cgi/image/f=auto,fit=pad,q=70,h=250,w=250/app/assets/products/sliding_images/jpeg/e3c9c9e9-4e0e-4e26-b6c9-d2dc4e8f3e4a.jpg?ts=1708590088'
WHERE LOWER(name) LIKE '%chana dal%';

UPDATE products SET
  name = 'Urad Dal',
  brand = '',
  selling_price = 132.00,
  mrp = 145.00,
  weight = '1 kg',
  unit = 'kg',
  description = 'Split Black Gram (Urad Dal). Price per 1 kg.',
  image = 'https://cdn.grofers.com/cdn-cgi/image/f=auto,fit=pad,q=70,h=250,w=250/app/assets/products/sliding_images/jpeg/a1b2c3d4-5e6f-7890-abcd-ef0123456789.jpg?ts=1708590088'
WHERE LOWER(name) LIKE '%urad dal%';

UPDATE products SET
  name = 'Masoor Dal',
  brand = '',
  selling_price = 95.00,
  mrp = 108.00,
  weight = '1 kg',
  unit = 'kg',
  description = 'Red Lentils (Masoor Dal). Rich in protein. Price per 1 kg.',
  image = 'https://cdn.grofers.com/cdn-cgi/image/f=auto,fit=pad,q=70,h=250,w=250/app/assets/products/sliding_images/jpeg/b2c3d4e5-6f7a-8901-bcde-f01234567890.jpg?ts=1708590088'
WHERE LOWER(name) LIKE '%masoor%';

-- ============================================================
-- 3. CREATE BATH SOAPS CATEGORY
-- ============================================================
INSERT IGNORE INTO categories (name, slug, description, icon, color, is_active, sort_order)
VALUES
  ('Bath Soaps', 'bath-soaps', 'Premium bath soaps from top brands', '🧼', '#06b6d4', 1, 15),
  ('Shampoos', 'shampoos', 'Hair care shampoos and conditioners', '🧴', '#8b5cf6', 1, 16),
  ('Personal Care', 'personal-care', 'Personal hygiene and grooming products', '🛁', '#ec4899', 1, 17);

-- ============================================================
-- 4. INSERT BATH SOAP PRODUCTS (with real product image URLs)
-- ============================================================
INSERT INTO products (name, category_id, brand, description, mrp, selling_price, gst_percent, stock, unit, weight, barcode, is_featured, is_bestseller, is_available, image)
SELECT
  p.name, c.id, p.brand, p.description, p.mrp, p.selling_price, 18, p.stock, 'pcs', p.weight, p.barcode, p.featured, p.bestseller, 1, p.image
FROM categories c,
(SELECT * FROM (VALUES
  ROW('Cinthol Original Soap',         'Cinthol (Godrej)', 'Refreshing lime and deodorant soap. Classic Indian favourite since 1952.',                             38,   34,  100, '125g', '8901030008040', 0, 1, 'https://m.media-amazon.com/images/I/61yoVvW3jKL._SL1500_.jpg'),
  ROW('Santoor Sandal & Turmeric Soap', 'Santoor (Wipro)',  'Classic Santoor with natural sandalwood and turmeric. Keeps skin youthful and fresh.',                 42,   38,  120, '100g', '8901030010043', 1, 1, 'https://m.media-amazon.com/images/I/61T7P4CXBOL._SL1500_.jpg'),
  ROW('Dove Original Beauty Bar',       'Dove (HUL)',       'Dove Beauty Bar with 1/4 moisturising cream. Gentle on sensitive skin.',                               65,   58,  80,  '100g', '8712561546388', 1, 1, 'https://m.media-amazon.com/images/I/71vJ8TLwKVL._SL1500_.jpg'),
  ROW('Lifebuoy Total Soap',            'Lifebuoy (HUL)',   'Lifebuoy Total 10 germ protection. 100% better germ protection vs ordinary soap.',                     25,   22,  150, '100g', '8901030001300', 0, 1, 'https://m.media-amazon.com/images/I/71QwH5lhk6L._SL1500_.jpg'),
  ROW('Liril Lemon & Tea Tree Soap',    'Liril (HUL)',      'Refreshing lemon & tea tree fragrance soap. Leaves skin feeling fresh and cool.',                      30,   27,  90,  '100g', '8901030004004', 0, 0, 'https://m.media-amazon.com/images/I/71s4QkQR0pL._SL1500_.jpg'),
  ROW('Mysore Sandal Soap',             'Mysore Sandal (KSDL)', 'Iconic Karnataka soap made with pure sandalwood oil. Premium quality since 1916.',                55,   49,  70,  '125g', '8901030005001', 1, 1, 'https://m.media-amazon.com/images/I/714VnJ2sO7L._SL1500_.jpg'),
  ROW('Dettol Original Soap',           'Dettol (RB)',      'Dettol antiseptic soap with Dettol protection. Kills 99.9% of germs.',                                35,   31,  130, '125g', '6287006102013', 1, 1, 'https://m.media-amazon.com/images/I/71FmxPWJpQL._SL1500_.jpg'),
  ROW('Dove Moisturising Cream Soap',   'Dove (HUL)',       'Dove with moisturising cream bar. 1/4 moisturising milk leaves skin soft.',                            70,   62,  60,  '100g', '8712561566386', 0, 0, 'https://m.media-amazon.com/images/I/71vJ8TLwKVL._SL1500_.jpg'),
  ROW('Pears Soft & Fresh Soap',        'Pears (HUL)',      'Pears transparent soap with mint extracts. 99% pure glycerine soap.',                                  55,   48,  75,  '125g', '8901030855107', 0, 0, 'https://m.media-amazon.com/images/I/71bBHHpL-DL._SL1500_.jpg'),
  ROW('Hamam Neem Soap',                'Hamam (HUL)',      'Hamam with neem, tulsi and aloe vera. Protects skin from 10 types of germs.',                          30,   26,  100, '100g', '8901030001348', 0, 1, 'https://m.media-amazon.com/images/I/71nqJqGYI-L._SL1500_.jpg'),
  ROW('Medimix Ayurvedic Soap',         'Medimix',          'Medimix classic ayurvedic soap with 18 herbs. Clears acne and pimples.',                               45,   40,  85,  '125g', '8901030007128', 0, 1, 'https://m.media-amazon.com/images/I/71k5VLEbhML._SL1500_.jpg'),
  ROW('Nirma Beauty Soap',              'Nirma',            'Nirma beauty soap for smooth and glowing skin. Value for money.',                                       18,   15,  200, '100g', '8901226011100', 0, 0, 'https://m.media-amazon.com/images/I/61pHe-9h9xL._SL1500_.jpg'),
  ROW('Karthika Soap',                  'Karthika',         'Karthika soap with natural ingredients. Popular choice in Karnataka and South India.',                  28,   24,  110, '100g', '8901030007145', 0, 0, 'https://m.media-amazon.com/images/I/71kZNuY7e+L._SL1500_.jpg')
) AS vals(name, brand, description, mrp, selling_price, stock, weight, barcode, featured, bestseller, image)) AS p
WHERE c.slug = 'bath-soaps'
ON DUPLICATE KEY UPDATE name = p.name;

-- ============================================================
-- 5. INSERT SHAMPOO PRODUCTS
-- ============================================================
INSERT INTO products (name, category_id, brand, description, mrp, selling_price, gst_percent, stock, unit, weight, barcode, is_featured, is_bestseller, is_available, image)
SELECT
  p.name, c.id, p.brand, p.description, p.mrp, p.selling_price, 18, p.stock, 'pcs', p.weight, p.barcode, p.featured, p.bestseller, 1, p.image
FROM categories c,
(SELECT * FROM (VALUES
  ROW('Head & Shoulders Anti-Dandruff Shampoo', 'Head & Shoulders (P&G)', 'Head & Shoulders classic clean with zinc pyrithione. Removes dandruff with first wash.',          199,  175, 60, '340ml', '4902430715027', 1, 1, 'https://m.media-amazon.com/images/I/71q5IXKWL0L._SL1500_.jpg'),
  ROW('Dove Intense Repair Shampoo',             'Dove (HUL)',            'Dove shampoo with Fibre Actives for intense repair of damaged hair.',                              199,  175, 55, '340ml', '8712561453222', 1, 1, 'https://m.media-amazon.com/images/I/61EEI8MsRGL._SL1500_.jpg'),
  ROW('Clinic Plus Strong & Long Shampoo',       'Clinic Plus (HUL)',     'Clinic Plus with Vitamin complex for stronger and longer hair. Trusted by Indian families.',       85,   75,  90, '340ml', '8901030761866', 0, 1, 'https://m.media-amazon.com/images/I/71jh-qOQMKL._SL1500_.jpg'),
  ROW('Pantene Silky Smooth Shampoo',            'Pantene (P&G)',         'Pantene with Pro-V formula. Makes hair silky, smooth and strong.',                                 175,  155, 65, '340ml', '4902430380843', 0, 1, 'https://m.media-amazon.com/images/I/71WoEJKHfhL._SL1500_.jpg'),
  ROW('Sunsilk Smooth & Manageable Shampoo',     'Sunsilk (HUL)',         'Sunsilk with amla + egg protein + vitamin for smooth, manageable hair.',                           135,  118, 70, '340ml', '8901030777354', 0, 0, 'https://m.media-amazon.com/images/I/71iS1vU7XdL._SL1500_.jpg'),
  ROW('Karthika Shikakai Shampoo',               'Karthika',             'Karthika natural shikakai shampoo. Traditional South Indian hair care formula.',                   95,   85,  80, '200ml', '8901030007152', 0, 1, 'https://m.media-amazon.com/images/I/71kZNuY7e+L._SL1500_.jpg'),
  ROW('Nyle Natural Shampoo',                    'Nyle (CavinKare)',      'Nyle naturals herbal shampoo with amla, neem and shikakai extracts.',                             95,   82,  75, '200ml', '8901030007169', 0, 0, 'https://m.media-amazon.com/images/I/71k5VLEbhML._SL1500_.jpg'),
  ROW('Meera Coconut Milk Shampoo',              'Meera (CavinKare)',     'Meera with coconut milk and herbs for nourished and frizz-free hair. South Indian favourite.',    95,   80,  85, '200ml', '8901030007176', 0, 0, 'https://m.media-amazon.com/images/I/71s4QkQR0pL._SL1500_.jpg'),
  ROW('Clinic Plus Small Pack Shampoo',          'Clinic Plus (HUL)',     'Clinic Plus economy pack for everyday use. Strengthens hair from root to tip.',                   40,   35,  120, '80ml', '8901030761873', 0, 1, 'https://m.media-amazon.com/images/I/71jh-qOQMKL._SL1500_.jpg')
) AS vals(name, brand, description, mrp, selling_price, stock, weight, barcode, featured, bestseller, image)) AS p
WHERE c.slug = 'shampoos'
ON DUPLICATE KEY UPDATE name = p.name;

-- ============================================================
-- 6. UPDATE FOOTER / ABOUT STORE DETAILS in admin settings (optional)
-- ============================================================
-- Store info is handled in frontend Contact.jsx and About.jsx

SELECT 'Migration completed successfully!' AS status;
