-- ============================================================
-- RATHI TRADERS - Complete MySQL Schema
-- Traditional Indian Kirana Store
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';
SET time_zone = '+05:30';

-- ============================================================
-- TABLE: admins
-- ============================================================
CREATE TABLE IF NOT EXISTS `admins` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(150) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `phone` VARCHAR(15),
  `role` ENUM('superadmin','admin','manager') DEFAULT 'admin',
  `is_active` TINYINT(1) DEFAULT 1,
  `last_login` DATETIME,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLE: customers
-- ============================================================
CREATE TABLE IF NOT EXISTS `customers` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(150) NOT NULL UNIQUE,
  `phone` VARCHAR(15),
  `password` VARCHAR(255) NOT NULL,
  `profile_image` VARCHAR(255),
  `is_active` TINYINT(1) DEFAULT 1,
  `is_verified` TINYINT(1) DEFAULT 0,
  `otp` VARCHAR(6),
  `otp_expires` DATETIME,
  `last_login` DATETIME,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLE: categories
-- ============================================================
CREATE TABLE IF NOT EXISTS `categories` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `slug` VARCHAR(120) NOT NULL UNIQUE,
  `description` TEXT,
  `image` VARCHAR(255),
  `icon` VARCHAR(50),
  `color` VARCHAR(20) DEFAULT '#FF6B35',
  `parent_id` INT UNSIGNED DEFAULT NULL,
  `sort_order` INT DEFAULT 0,
  `is_active` TINYINT(1) DEFAULT 1,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_slug` (`slug`),
  KEY `idx_parent` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLE: products
-- ============================================================
CREATE TABLE IF NOT EXISTS `products` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(200) NOT NULL,
  `slug` VARCHAR(220) NOT NULL UNIQUE,
  `category_id` INT UNSIGNED NOT NULL,
  `brand` VARCHAR(100),
  `description` TEXT,
  `mrp` DECIMAL(10,2) NOT NULL,
  `selling_price` DECIMAL(10,2) NOT NULL,
  `gst_percent` DECIMAL(5,2) DEFAULT 0.00,
  `stock` INT DEFAULT 0,
  `unit` VARCHAR(30) DEFAULT 'pcs',
  `weight` VARCHAR(30),
  `image` VARCHAR(255) DEFAULT 'default-product.jpg',
  `barcode` VARCHAR(50),
  `expiry_date` DATE,
  `manufacture_date` DATE,
  `is_available` TINYINT(1) DEFAULT 1,
  `is_featured` TINYINT(1) DEFAULT 0,
  `is_bestseller` TINYINT(1) DEFAULT 0,
  `rating` DECIMAL(3,2) DEFAULT 4.00,
  `review_count` INT DEFAULT 0,
  `min_order_qty` INT DEFAULT 1,
  `max_order_qty` INT DEFAULT 50,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_category` (`category_id`),
  KEY `idx_brand` (`brand`),
  KEY `idx_available` (`is_available`),
  KEY `idx_featured` (`is_featured`),
  FULLTEXT KEY `ft_search` (`name`, `brand`, `description`),
  CONSTRAINT `fk_product_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLE: addresses
-- ============================================================
CREATE TABLE IF NOT EXISTS `addresses` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` INT UNSIGNED NOT NULL,
  `label` VARCHAR(50) DEFAULT 'Home',
  `name` VARCHAR(100) NOT NULL,
  `phone` VARCHAR(15) NOT NULL,
  `address_line1` VARCHAR(255) NOT NULL,
  `address_line2` VARCHAR(255),
  `city` VARCHAR(100) NOT NULL,
  `state` VARCHAR(100) NOT NULL,
  `pincode` VARCHAR(10) NOT NULL,
  `landmark` VARCHAR(150),
  `is_default` TINYINT(1) DEFAULT 0,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_customer` (`customer_id`),
  CONSTRAINT `fk_addr_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLE: cart
-- ============================================================
CREATE TABLE IF NOT EXISTS `cart` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` INT UNSIGNED NOT NULL,
  `product_id` INT UNSIGNED NOT NULL,
  `quantity` INT NOT NULL DEFAULT 1,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_cart_item` (`customer_id`, `product_id`),
  KEY `idx_customer` (`customer_id`),
  CONSTRAINT `fk_cart_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cart_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLE: wishlist
-- ============================================================
CREATE TABLE IF NOT EXISTS `wishlist` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` INT UNSIGNED NOT NULL,
  `product_id` INT UNSIGNED NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_wishlist` (`customer_id`, `product_id`),
  CONSTRAINT `fk_wish_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_wish_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLE: coupons
-- ============================================================
CREATE TABLE IF NOT EXISTS `coupons` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(30) NOT NULL UNIQUE,
  `description` VARCHAR(255),
  `discount_type` ENUM('percent','flat') DEFAULT 'percent',
  `discount_value` DECIMAL(10,2) NOT NULL,
  `min_order_amount` DECIMAL(10,2) DEFAULT 0,
  `max_discount` DECIMAL(10,2),
  `usage_limit` INT DEFAULT 100,
  `used_count` INT DEFAULT 0,
  `valid_from` DATE,
  `valid_till` DATE,
  `is_active` TINYINT(1) DEFAULT 1,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLE: orders
-- ============================================================
CREATE TABLE IF NOT EXISTS `orders` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_number` VARCHAR(30) NOT NULL UNIQUE,
  `customer_id` INT UNSIGNED NOT NULL,
  `address_id` INT UNSIGNED,
  `delivery_name` VARCHAR(100),
  `delivery_phone` VARCHAR(15),
  `delivery_address` TEXT,
  `subtotal` DECIMAL(10,2) NOT NULL,
  `discount_amount` DECIMAL(10,2) DEFAULT 0,
  `coupon_code` VARCHAR(30),
  `gst_amount` DECIMAL(10,2) DEFAULT 0,
  `delivery_charge` DECIMAL(10,2) DEFAULT 0,
  `total_amount` DECIMAL(10,2) NOT NULL,
  `payment_method` ENUM('upi','cod','card') DEFAULT 'cod',
  `payment_status` ENUM('pending','paid','failed','refunded') DEFAULT 'pending',
  `order_status` ENUM('pending','confirmed','packed','out_for_delivery','delivered','cancelled','returned') DEFAULT 'pending',
  `notes` TEXT,
  `upi_transaction_ref` VARCHAR(100),
  `screenshot_url` VARCHAR(255),
  `admin_verified` TINYINT(1) DEFAULT 0,
  `admin_note` TEXT,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_customer` (`customer_id`),
  KEY `idx_status` (`order_status`),
  KEY `idx_payment` (`payment_status`),
  CONSTRAINT `fk_order_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLE: order_items
-- ============================================================
CREATE TABLE IF NOT EXISTS `order_items` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_id` INT UNSIGNED NOT NULL,
  `product_id` INT UNSIGNED NOT NULL,
  `product_name` VARCHAR(200) NOT NULL,
  `brand` VARCHAR(100),
  `image` VARCHAR(255),
  `quantity` INT NOT NULL,
  `unit_price` DECIMAL(10,2) NOT NULL,
  `mrp` DECIMAL(10,2) NOT NULL,
  `gst_percent` DECIMAL(5,2) DEFAULT 0,
  `total_price` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_order` (`order_id`),
  CONSTRAINT `fk_item_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_item_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLE: payments
-- ============================================================
CREATE TABLE IF NOT EXISTS `payments` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_id` INT UNSIGNED NOT NULL,
  `customer_id` INT UNSIGNED NOT NULL,
  `payment_method` ENUM('upi','cod','card') DEFAULT 'upi',
  `amount` DECIMAL(10,2) NOT NULL,
  `upi_id` VARCHAR(100),
  `transaction_ref` VARCHAR(100),
  `screenshot_url` VARCHAR(255),
  `status` ENUM('pending','verified','failed','refunded') DEFAULT 'pending',
  `verified_by` INT UNSIGNED,
  `verified_at` DATETIME,
  `notes` VARCHAR(255),
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_order` (`order_id`),
  CONSTRAINT `fk_pay_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLE: reviews
-- ============================================================
CREATE TABLE IF NOT EXISTS `reviews` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `product_id` INT UNSIGNED NOT NULL,
  `customer_id` INT UNSIGNED NOT NULL,
  `order_id` INT UNSIGNED,
  `rating` TINYINT NOT NULL DEFAULT 5,
  `title` VARCHAR(150),
  `comment` TEXT,
  `is_approved` TINYINT(1) DEFAULT 1,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_product` (`product_id`),
  CONSTRAINT `fk_rev_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_rev_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLE: offers
-- ============================================================
CREATE TABLE IF NOT EXISTS `offers` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(150) NOT NULL,
  `description` TEXT,
  `image` VARCHAR(255),
  `discount_percent` DECIMAL(5,2),
  `category_id` INT UNSIGNED,
  `valid_from` DATETIME,
  `valid_till` DATETIME,
  `is_active` TINYINT(1) DEFAULT 1,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLE: notifications
-- ============================================================
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` INT UNSIGNED,
  `title` VARCHAR(150) NOT NULL,
  `message` TEXT NOT NULL,
  `type` ENUM('order','payment','offer','system') DEFAULT 'system',
  `is_read` TINYINT(1) DEFAULT 0,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_customer` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TABLE: contact_messages
-- ============================================================
CREATE TABLE IF NOT EXISTS `contact_messages` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(150) NOT NULL,
  `phone` VARCHAR(15),
  `subject` VARCHAR(200),
  `message` TEXT NOT NULL,
  `is_read` TINYINT(1) DEFAULT 0,
  `admin_reply` TEXT,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- SEED: Categories
-- ============================================================
INSERT IGNORE INTO `categories` (`id`, `name`, `slug`, `description`, `icon`, `color`, `sort_order`) VALUES
(1,  'Atta & Flour',     'atta-flour',      'Wheat flour, maida, besan and more',  '🌾', '#F59E0B', 1),
(2,  'Rice',             'rice',            'Basmati, sona masoori and more',       '🍚', '#FBBF24', 2),
(3,  'Dal & Pulses',     'dal-pulses',      'All types of lentils and pulses',      '🫘', '#D97706', 3),
(4,  'Sugar & Salt',     'sugar-salt',      'Sugar, salt and sweeteners',           '🧂', '#6B7280', 4),
(5,  'Oil & Ghee',       'oil-ghee',        'Cooking oils and pure ghee',           '🫙', '#FBBF24', 5),
(6,  'Masala & Spices',  'masala-spices',   'Ground masalas and whole spices',      '🌶️', '#EF4444', 6),
(7,  'Dry Fruits',       'dry-fruits',      'Almonds, cashews, raisins and more',   '🥜', '#92400E', 7),
(8,  'Poha & Rava',      'poha-rava',       'Flattened rice, semolina, murmura',    '🌾', '#FDE68A', 8),
(9,  'Papad & Pickles',  'papad-pickles',   'Papads, pickles and chutneys',         '🥒', '#84CC16', 9),
(10, 'Tea & Coffee',     'tea-coffee',      'Tea leaves, coffee powder, filters',   '☕', '#7C3AED', 10),
(11, 'Milk Powder',      'milk-powder',     'Dairy whiteners and milk powder',      '🥛', '#E5E7EB', 11),
(12, 'Biscuits',         'biscuits',        'Glucose biscuits, crackers and more',  '🍪', '#B45309', 12),
(13, 'Namkeen & Snacks', 'namkeen-snacks',  'Sev, chips, mixture and more',         '🥨', '#F97316', 13),
(14, 'Chocolates',       'chocolates',      'Chocolates and confectionery',         '🍫', '#7C2D12', 14),
(15, 'Instant Food',     'instant-food',    'Noodles, vermicelli, pasta',           '🍜', '#DC2626', 15),
(16, 'Cornflakes & Oats','cornflakes-oats', 'Breakfast cereals and oats',          '🥣', '#D97706', 16),
(17, 'Sauces & Jams',    'sauces-jams',     'Tomato sauce, jams, honey',            '🍯', '#DC2626', 17),
(18, 'Soap',             'soap',            'Bath soaps and hand wash',             '🧼', '#3B82F6', 18),
(19, 'Shampoo & Hair',   'shampoo-hair',    'Shampoos, conditioners, hair oils',    '💆', '#8B5CF6', 19),
(20, 'Toothpaste',       'toothpaste',      'Toothpaste and toothbrushes',          '🦷', '#10B981', 20),
(21, 'Detergent',        'detergent',       'Washing powder, liquid and bars',      '👕', '#2563EB', 21),
(22, 'Dishwash',         'dishwash',        'Dish bars, liquids and scrubbers',     '🍽️', '#0EA5E9', 22),
(23, 'Floor & Toilet',   'floor-toilet',    'Floor cleaners and toilet cleaners',   '🧹', '#10B981', 23),
(24, 'Mosquito Repellent','mosquito-repellent','Coils, mats, liquids',             '🦟', '#6B7280', 24),
(25, 'Personal Care',    'personal-care',   'Creams, lotions, deodorants',          '🧴', '#EC4899', 25),
(26, 'Baby Care',        'baby-care',       'Baby soaps, oils, powder',             '👶', '#F472B6', 26),
(27, 'Kitchen Essentials','kitchen-essentials','Matchbox, candles, napkins',        '🏠', '#F59E0B', 27),
(28, 'Pooja Items',      'pooja-items',     'Agarbatti, camphor, puja essentials',  '🪔', '#FF6B35', 28),
(29, 'Stationery',       'stationery',      'Notebooks, pens, pencils',             '✏️', '#6366F1', 29),
(30, 'Batteries',        'batteries',       'AA, AAA and other batteries',          '🔋', '#374151', 30);

-- ============================================================
-- SEED: 200+ Products
-- ============================================================

-- ============ ATTA & FLOUR (category_id=1) ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
(1, 'Aashirvaad Whole Wheat Atta', 'aashirvaad-whole-wheat-atta-5kg', 1, 'Aashirvaad', 'Superior MP Wheat Atta for soft chapatis. Made from finest quality wheat grains.', 285.00, 268.00, 0.00, 200, 'bag', '5 kg', 'atta-aashirvaad-5kg.jpg', '8901030863579', '2026-06-01', '2025-06-01', 1, 1, 1, 4.5),
(2, 'Aashirvaad Whole Wheat Atta', 'aashirvaad-whole-wheat-atta-10kg', 1, 'Aashirvaad', 'Superior MP Wheat Atta. Value pack for families.', 545.00, 510.00, 0.00, 150, 'bag', '10 kg', 'atta-aashirvaad-10kg.jpg', '8901030863586', '2026-06-01', '2025-06-01', 1, 0, 1, 4.5),
(3, 'Fortune Chakki Fresh Atta', 'fortune-chakki-fresh-atta-5kg', 1, 'Fortune', 'Freshly ground chakki atta for soft and tasty rotis.', 275.00, 258.00, 0.00, 180, 'bag', '5 kg', 'atta-fortune-5kg.jpg', '8901063127013', '2026-05-01', '2025-05-01', 1, 0, 1, 4.3),
(4, 'Pillsbury Chakki Fresh Atta', 'pillsbury-chakki-atta-5kg', 1, 'Pillsbury', 'Fresh wheat atta from Pillsbury for soft rotis.', 270.00, 255.00, 0.00, 100, 'bag', '5 kg', 'atta-pillsbury-5kg.jpg', '8901030109018', '2026-04-01', '2025-04-01', 1, 0, 0, 4.2),
(5, 'Aashirvaad Multigrain Atta', 'aashirvaad-multigrain-atta-5kg', 1, 'Aashirvaad', 'Atta with 6 grains including oats, soya, wheat, channa, maize and psyllium.', 320.00, 299.00, 0.00, 80, 'bag', '5 kg', 'atta-multigrain-5kg.jpg', '8901030863654', '2026-06-01', '2025-06-01', 1, 1, 0, 4.4),
(6, 'Patanjali Atta', 'patanjali-atta-5kg', 1, 'Patanjali', 'Pure wheat atta from Patanjali. Made from natural wheat.', 230.00, 215.00, 0.00, 120, 'bag', '5 kg', 'atta-patanjali-5kg.jpg', '8904109480023', '2026-03-01', '2025-03-01', 1, 0, 0, 4.0),
(7, 'Rajdhani Maida', 'rajdhani-maida-1kg', 1, 'Rajdhani', 'Fine quality refined flour for baking and cooking.', 38.00, 35.00, 5.00, 200, 'pkt', '1 kg', 'maida-rajdhani-1kg.jpg', '8906015720019', '2026-03-01', '2025-03-01', 1, 0, 0, 4.0),
(8, 'Ganesh Besan', 'ganesh-besan-1kg', 1, 'Ganesh', 'Chana dal besan for kadhi, pakoda and sweets.', 75.00, 70.00, 5.00, 150, 'pkt', '1 kg', 'besan-ganesh-1kg.jpg', '8906063720011', '2026-04-01', '2025-04-01', 1, 0, 1, 4.3),
(9, 'MTR Corn Flour', 'mtr-corn-flour-500g', 1, 'MTR', 'Fine corn flour for thickening and baking.', 55.00, 50.00, 5.00, 100, 'pkt', '500 g', 'cornflour-mtr-500g.jpg', '8901053003765', '2026-06-01', '2025-06-01', 1, 0, 0, 4.1),
(10, 'Aashirvaad Select Sharbati Atta', 'aashirvaad-select-sharbati-5kg', 1, 'Aashirvaad', 'Made from special Sharbati wheat from MP for extra soft rotis.', 305.00, 288.00, 0.00, 90, 'bag', '5 kg', 'atta-aashirvaad-select-5kg.jpg', '8901030863692', '2026-07-01', '2025-07-01', 1, 1, 0, 4.6);

-- ============ RICE (category_id=2) ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
(11, 'India Gate Classic Basmati Rice', 'india-gate-classic-basmati-5kg', 2, 'India Gate', 'Premium aged basmati rice with long grains and rich aroma.', 545.00, 510.00, 5.00, 200, 'bag', '5 kg', 'rice-indiagate-classic-5kg.jpg', '8901130000086', '2027-01-01', '2024-01-01', 1, 1, 1, 4.6),
(12, 'India Gate Feast Rozzana Basmati', 'india-gate-feast-basmati-5kg', 2, 'India Gate', 'Perfect for daily cooking. Long grain basmati rice.', 395.00, 370.00, 5.00, 180, 'bag', '5 kg', 'rice-indiagate-feast-5kg.jpg', '8901130000109', '2027-01-01', '2024-01-01', 1, 0, 1, 4.3),
(13, 'Daawat Rozana Basmati Rice', 'daawat-rozana-basmati-5kg', 2, 'Daawat', 'Everyday basmati rice with consistent quality.', 380.00, 355.00, 5.00, 150, 'bag', '5 kg', 'rice-daawat-5kg.jpg', '8901719100024', '2027-01-01', '2024-01-01', 1, 0, 0, 4.2),
(14, 'Kohinoor Super Value Basmati', 'kohinoor-super-basmati-5kg', 2, 'Kohinoor', 'Authentic basmati rice with natural aroma.', 420.00, 395.00, 5.00, 100, 'bag', '5 kg', 'rice-kohinoor-5kg.jpg', '8901063125989', '2027-01-01', '2024-01-01', 1, 0, 0, 4.1),
(15, 'Fortune Biryani Special Basmati', 'fortune-biryani-basmati-5kg', 2, 'Fortune', 'Extra long grain basmati perfect for biryani.', 460.00, 430.00, 5.00, 80, 'bag', '5 kg', 'rice-fortune-biryani-5kg.jpg', '8901063127075', '2027-01-01', '2024-01-01', 1, 1, 0, 4.4),
(16, 'Patanjali Basmati Rice', 'patanjali-basmati-rice-5kg', 2, 'Patanjali', 'Natural and pure basmati rice from Himalayan fields.', 350.00, 328.00, 5.00, 120, 'bag', '5 kg', 'rice-patanjali-5kg.jpg', '8904109480108', '2027-01-01', '2024-01-01', 1, 0, 0, 4.0);

-- ============ DAL & PULSES (category_id=3) ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
(17, 'Tata Sampann Toor Dal', 'tata-sampann-toor-dal-1kg', 3, 'Tata Sampann', 'Unpolished toor dal with natural goodness. Protein rich.', 165.00, 155.00, 5.00, 200, 'pkt', '1 kg', 'dal-tata-toor-1kg.jpg', '8901719111082', '2026-12-01', '2025-12-01', 1, 1, 1, 4.4),
(18, 'Tata Sampann Chana Dal', 'tata-sampann-chana-dal-1kg', 3, 'Tata Sampann', 'Clean and sorted chana dal for everyday cooking.', 145.00, 135.00, 5.00, 180, 'pkt', '1 kg', 'dal-tata-chana-1kg.jpg', '8901719111099', '2026-12-01', '2025-12-01', 1, 0, 1, 4.3),
(19, 'Tata Sampann Masoor Dal', 'tata-sampann-masoor-dal-1kg', 3, 'Tata Sampann', 'Red lentils - quick cooking and highly nutritious.', 140.00, 130.00, 5.00, 160, 'pkt', '1 kg', 'dal-tata-masoor-1kg.jpg', '8901719111105', '2026-12-01', '2025-12-01', 1, 0, 0, 4.2),
(20, 'Tata Sampann Moong Dal', 'tata-sampann-moong-dal-1kg', 3, 'Tata Sampann', 'Yellow moong dal for khichdi and dal preparations.', 175.00, 162.00, 5.00, 150, 'pkt', '1 kg', 'dal-tata-moong-1kg.jpg', '8901719111112', '2026-12-01', '2025-12-01', 1, 0, 0, 4.3),
(21, 'Rajdhani Urad Dal', 'rajdhani-urad-dal-1kg', 3, 'Rajdhani', 'White urad dal for idli, dosa batter and dal makhani.', 158.00, 148.00, 5.00, 120, 'pkt', '1 kg', 'dal-urad-1kg.jpg', '8906015720064', '2026-11-01', '2025-11-01', 1, 0, 0, 4.1),
(22, 'Rajdhani Rajma Chitra', 'rajdhani-rajma-1kg', 3, 'Rajdhani', 'Kidney beans for authentic rajma curry.', 185.00, 172.00, 5.00, 100, 'pkt', '1 kg', 'rajma-1kg.jpg', '8906015720088', '2026-11-01', '2025-11-01', 1, 0, 0, 4.2),
(23, 'Haldirams Roasted Chana', 'haldirams-roasted-chana-200g', 3, 'Haldirams', 'Roasted and salted whole chana as a healthy snack.', 35.00, 32.00, 5.00, 200, 'pkt', '200 g', 'chana-haldirams-200g.jpg', '8902519101025', '2026-06-01', '2025-06-01', 1, 0, 0, 4.0);

-- ============ SUGAR & SALT (category_id=4) ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
(24, 'Tata Salt Crystal', 'tata-salt-1kg', 4, 'Tata Salt', 'Vacuum evaporated iodized salt for healthy living.', 26.00, 24.00, 0.00, 500, 'pkt', '1 kg', 'salt-tata-1kg.jpg', '8901069010106', '2027-06-01', '2025-06-01', 1, 1, 1, 4.7),
(25, 'Tata Salt Lite Low Sodium', 'tata-salt-lite-1kg', 4, 'Tata Salt', 'Low sodium salt for health-conscious consumers.', 30.00, 28.00, 0.00, 200, 'pkt', '1 kg', 'salt-tata-lite-1kg.jpg', '8901069010113', '2027-06-01', '2025-06-01', 1, 0, 0, 4.3),
(26, 'Annapurna Salt', 'annapurna-iodised-salt-1kg', 4, 'Annapurna', 'Free flow iodized salt. Easy to use.', 22.00, 20.00, 0.00, 400, 'pkt', '1 kg', 'salt-annapurna-1kg.jpg', '8901030106659', '2027-01-01', '2025-01-01', 1, 0, 0, 4.1),
(27, 'Uttam Sugar', 'uttam-refined-sugar-1kg', 4, 'Uttam', 'Pure refined sugar for daily use.', 58.00, 55.00, 5.00, 300, 'pkt', '1 kg', 'sugar-1kg.jpg', '8906050000010', '2026-12-01', '2025-01-01', 1, 0, 1, 4.0),
(28, 'Patanjali Natural Sugar', 'patanjali-natural-sugar-1kg', 4, 'Patanjali', 'Chemical free natural sugar from Patanjali.', 60.00, 56.00, 5.00, 200, 'pkt', '1 kg', 'sugar-patanjali-1kg.jpg', '8904109480269', '2026-12-01', '2025-01-01', 1, 0, 0, 4.2),
(29, 'Tata Sugar', 'tata-sugar-1kg', 4, 'Tata', 'Pure and hygienic refined sugar.', 56.00, 52.00, 5.00, 250, 'pkt', '1 kg', 'sugar-tata-1kg.jpg', '8901069000107', '2026-12-01', '2025-01-01', 1, 0, 0, 4.1);

-- ============ OIL & GHEE (category_id=5) ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
(30, 'Fortune Sunflower Refined Oil', 'fortune-sunflower-oil-1l', 5, 'Fortune', 'Heart healthy refined sunflower oil with Vitamin E.', 155.00, 145.00, 5.00, 200, 'bottle', '1 L', 'oil-fortune-sunflower-1l.jpg', '8901063127006', '2026-12-01', '2025-06-01', 1, 1, 1, 4.4),
(31, 'Fortune Sunflower Oil', 'fortune-sunflower-oil-5l', 5, 'Fortune', 'Value pack sunflower refined oil for daily cooking.', 720.00, 680.00, 5.00, 150, 'can', '5 L', 'oil-fortune-sunflower-5l.jpg', '8901063127020', '2026-12-01', '2025-06-01', 1, 0, 1, 4.4),
(32, 'Saffola Gold Refined Oil', 'saffola-gold-oil-1l', 5, 'Saffola', 'Blended rice bran and corn oil for heart health.', 175.00, 162.00, 5.00, 120, 'bottle', '1 L', 'oil-saffola-gold-1l.jpg', '8901063002091', '2026-12-01', '2025-06-01', 1, 1, 0, 4.5),
(33, 'Dhara Mustard Oil', 'dhara-mustard-oil-1l', 5, 'Dhara', 'Filtered kachi ghani mustard oil with pungent taste.', 145.00, 135.00, 5.00, 150, 'bottle', '1 L', 'oil-dhara-mustard-1l.jpg', '8901030863975', '2026-12-01', '2025-06-01', 1, 0, 1, 4.3),
(34, 'Amul Pure Ghee', 'amul-pure-ghee-500g', 5, 'Amul', 'Pure cow ghee with rich aroma and taste.', 285.00, 268.00, 12.00, 200, 'tin', '500 g', 'ghee-amul-500g.jpg', '8901063000004', '2026-12-01', '2025-06-01', 1, 1, 1, 4.7),
(35, 'Amul Pure Ghee', 'amul-pure-ghee-1kg', 5, 'Amul', 'Pure cow ghee value pack for festivals and daily use.', 565.00, 535.00, 12.00, 150, 'tin', '1 kg', 'ghee-amul-1kg.jpg', '8901063000011', '2026-12-01', '2025-06-01', 1, 0, 1, 4.7),
(36, 'Patanjali Cow Ghee', 'patanjali-cow-ghee-1kg', 5, 'Patanjali', 'Pure desi cow ghee from Patanjali.', 520.00, 490.00, 12.00, 100, 'tin', '1 kg', 'ghee-patanjali-1kg.jpg', '8904109480306', '2026-12-01', '2025-06-01', 1, 0, 0, 4.4),
(37, 'Fortune Kachi Ghani Mustard Oil', 'fortune-mustard-oil-1l', 5, 'Fortune', 'Traditional kachi ghani mustard oil for authentic taste.', 148.00, 138.00, 5.00, 130, 'bottle', '1 L', 'oil-fortune-mustard-1l.jpg', '8901063127044', '2026-12-01', '2025-06-01', 1, 0, 0, 4.2),
(38, 'Nandini Pure Ghee', 'nandini-pure-ghee-500g', 5, 'Nandini', 'Karnataka cooperative dairy ghee. Pure and fresh.', 270.00, 255.00, 12.00, 80, 'tin', '500 g', 'ghee-nandini-500g.jpg', '8904109480399', '2026-06-01', '2025-06-01', 1, 0, 1, 4.6),
(39, 'Emami Healthy & Tasty Oil', 'emami-healthy-tasty-oil-1l', 5, 'Emami', 'Kachi ghani mustard oil enriched with vitamins.', 150.00, 140.00, 5.00, 100, 'bottle', '1 L', 'oil-emami-1l.jpg', '8906074300010', '2026-12-01', '2025-06-01', 1, 0, 0, 4.0);

-- ============ MASALA & SPICES (category_id=6) ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
(40, 'MDH Deggi Mirch', 'mdh-deggi-mirch-100g', 6, 'MDH', 'Spicy red chilli powder for colour and taste.', 65.00, 60.00, 5.00, 300, 'pkt', '100 g', 'masala-mdh-deggi-100g.jpg', '8901650100018', '2026-12-01', '2025-06-01', 1, 1, 1, 4.5),
(41, 'MDH Garam Masala', 'mdh-garam-masala-100g', 6, 'MDH', 'Aromatic garam masala blend for authentic Indian cooking.', 85.00, 78.00, 5.00, 250, 'pkt', '100 g', 'masala-mdh-garam-100g.jpg', '8901650100025', '2026-12-01', '2025-06-01', 1, 1, 1, 4.6),
(42, 'MDH Chhole Masala', 'mdh-chhole-masala-100g', 6, 'MDH', 'Special blend for authentic chhole.', 75.00, 70.00, 5.00, 200, 'pkt', '100 g', 'masala-mdh-chhole-100g.jpg', '8901650100032', '2026-12-01', '2025-06-01', 1, 0, 1, 4.4),
(43, 'Everest Kitchen King Masala', 'everest-kitchen-king-100g', 6, 'Everest', 'All-in-one masala blend for Indian gravies.', 80.00, 74.00, 5.00, 220, 'pkt', '100 g', 'masala-everest-kitchenking-100g.jpg', '8901897000015', '2026-12-01', '2025-06-01', 1, 1, 1, 4.5),
(44, 'Everest Sambhar Masala', 'everest-sambhar-masala-100g', 6, 'Everest', 'Authentic South Indian sambhar masala blend.', 70.00, 65.00, 5.00, 180, 'pkt', '100 g', 'masala-everest-sambhar-100g.jpg', '8901897000022', '2026-12-01', '2025-06-01', 1, 0, 0, 4.3),
(45, 'Everest Rajma Masala', 'everest-rajma-masala-100g', 6, 'Everest', 'Perfect blend for rajma curry.', 72.00, 67.00, 5.00, 160, 'pkt', '100 g', 'masala-everest-rajma-100g.jpg', '8901897000039', '2026-12-01', '2025-06-01', 1, 0, 0, 4.2),
(46, 'Catch Turmeric Powder', 'catch-turmeric-powder-200g', 6, 'Catch', 'Pure turmeric powder with high curcumin content.', 55.00, 50.00, 5.00, 300, 'pkt', '200 g', 'haldi-catch-200g.jpg', '8901234100010', '2026-12-01', '2025-06-01', 1, 0, 1, 4.3),
(47, 'Catch Coriander Powder', 'catch-coriander-powder-200g', 6, 'Catch', 'Finely ground coriander powder for all Indian dishes.', 52.00, 48.00, 5.00, 250, 'pkt', '200 g', 'dhaniya-catch-200g.jpg', '8901234100027', '2026-12-01', '2025-06-01', 1, 0, 1, 4.2),
(48, 'Patanjali Haldi Powder', 'patanjali-haldi-powder-200g', 6, 'Patanjali', 'Natural turmeric powder with medicinal properties.', 50.00, 45.00, 5.00, 200, 'pkt', '200 g', 'haldi-patanjali-200g.jpg', '8904109480436', '2026-12-01', '2025-06-01', 1, 0, 0, 4.1),
(49, 'MDH Pav Bhaji Masala', 'mdh-pav-bhaji-masala-100g', 6, 'MDH', 'Authentic pav bhaji masala for the perfect street food taste.', 78.00, 72.00, 5.00, 180, 'pkt', '100 g', 'masala-mdh-pavbhaji-100g.jpg', '8901650100049', '2026-12-01', '2025-06-01', 1, 0, 0, 4.4),
(50, 'Everest Meat Masala', 'everest-meat-masala-100g', 6, 'Everest', 'Robust masala blend for non-vegetarian dishes.', 82.00, 76.00, 5.00, 120, 'pkt', '100 g', 'masala-everest-meat-100g.jpg', '8901897000046', '2026-12-01', '2025-06-01', 1, 0, 0, 4.2),
(51, 'Catch Black Pepper Powder', 'catch-black-pepper-100g', 6, 'Catch', 'Freshly ground black pepper powder.', 85.00, 79.00, 5.00, 150, 'pkt', '100 g', 'pepper-catch-100g.jpg', '8901234100041', '2026-12-01', '2025-06-01', 1, 0, 0, 4.3),
(52, 'MDH Biryani Masala', 'mdh-biryani-masala-50g', 6, 'MDH', 'Royal blend of spices for aromatic biryani.', 55.00, 50.00, 5.00, 200, 'pkt', '50 g', 'masala-mdh-biryani-50g.jpg', '8901650100056', '2026-12-01', '2025-06-01', 1, 0, 0, 4.5);

-- ============ DRY FRUITS (category_id=7) ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
(53, 'Happilo Premium Almonds', 'happilo-almonds-200g', 7, 'Happilo', 'California almonds, rich in protein and healthy fats.', 199.00, 185.00, 5.00, 100, 'pkt', '200 g', 'almonds-happilo-200g.jpg', '8906088800015', '2026-06-01', '2025-06-01', 1, 1, 1, 4.5),
(54, 'Happilo Premium Cashews', 'happilo-cashews-200g', 7, 'Happilo', 'W320 grade cashews. Whole and creamy.', 225.00, 210.00, 5.00, 80, 'pkt', '200 g', 'cashews-happilo-200g.jpg', '8906088800022', '2026-06-01', '2025-06-01', 1, 1, 1, 4.6),
(55, 'Haldirams Raisins', 'haldirams-raisins-200g', 7, 'Haldirams', 'Seedless golden raisins for desserts and snacking.', 85.00, 78.00, 5.00, 120, 'pkt', '200 g', 'raisins-haldirams-200g.jpg', '8902519101049', '2026-12-01', '2025-06-01', 1, 0, 1, 4.3),
(56, 'Happilo Walnuts', 'happilo-walnuts-200g', 7, 'Happilo', 'California walnuts, packed with omega-3 fatty acids.', 285.00, 265.00, 5.00, 60, 'pkt', '200 g', 'walnuts-happilo-200g.jpg', '8906088800039', '2026-06-01', '2025-06-01', 1, 0, 0, 4.4),
(57, 'Tulsi Pista', 'tulsi-pista-100g', 7, 'Tulsi', 'Roasted and salted pistachios.', 165.00, 155.00, 5.00, 80, 'pkt', '100 g', 'pista-100g.jpg', '8907112000010', '2026-06-01', '2025-06-01', 1, 0, 0, 4.2),
(58, 'Patanjali Mixed Dry Fruits', 'patanjali-mixed-dry-fruits-200g', 7, 'Patanjali', 'Mix of almonds, cashews, raisins and pistachios.', 245.00, 228.00, 5.00, 70, 'pkt', '200 g', 'mixdryfruits-patanjali-200g.jpg', '8904109480542', '2026-06-01', '2025-06-01', 1, 0, 0, 4.1);

-- ============ POHA & RAVA (category_id=8) ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
(59, 'Aashirvaad Thick Poha', 'aashirvaad-thick-poha-1kg', 8, 'Aashirvaad', 'Thick flattened rice for poha preparation.', 65.00, 60.00, 0.00, 200, 'pkt', '1 kg', 'poha-aashirvaad-1kg.jpg', '8901030863838', '2026-12-01', '2025-06-01', 1, 0, 1, 4.3),
(60, 'MTR Rava Upma Mix', 'mtr-rava-upma-mix-200g', 8, 'MTR', 'Ready to cook rava upma mix.', 48.00, 44.00, 12.00, 150, 'pkt', '200 g', 'upma-mtr-200g.jpg', '8901053003789', '2026-06-01', '2025-06-01', 1, 0, 0, 4.2),
(61, 'Double Horse Roasted Rava', 'double-horse-rava-1kg', 8, 'Double Horse', 'Fine semolina for idli, upma and halwa.', 55.00, 50.00, 0.00, 150, 'pkt', '1 kg', 'rava-doublehorse-1kg.jpg', '8901030100014', '2026-12-01', '2025-06-01', 1, 0, 1, 4.2),
(62, 'Ganesh Murmura', 'ganesh-murmura-500g', 8, 'Ganesh', 'Light puffed rice for bhel puri and chivda.', 30.00, 28.00, 0.00, 200, 'pkt', '500 g', 'murmura-500g.jpg', '8906063720028', '2026-12-01', '2025-06-01', 1, 0, 0, 4.0);

-- ============ PAPAD & PICKLES (category_id=9) ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
(63, 'Lijjat Papad Urad Special', 'lijjat-papad-urad-200g', 9, 'Lijjat', 'Crispy urad dal papads for frying or roasting.', 55.00, 50.00, 5.00, 200, 'pkt', '200 g', 'papad-lijjat-200g.jpg', '8904030000010', '2026-12-01', '2025-06-01', 1, 0, 1, 4.5),
(64, 'Priya Mango Pickle', 'priya-mango-pickle-300g', 9, 'Priya', 'Traditional Andhra style spicy mango pickle.', 95.00, 88.00, 12.00, 150, 'jar', '300 g', 'pickle-priya-mango-300g.jpg', '8901234210010', '2026-12-01', '2025-06-01', 1, 0, 1, 4.3),
(65, 'Mother\'s Recipe Mixed Pickle', 'mothers-recipe-mixed-pickle-400g', 9, 'Mother\'s Recipe', 'Traditional mixed pickle with authentic spices.', 115.00, 105.00, 12.00, 120, 'jar', '400 g', 'pickle-mothers-mixed-400g.jpg', '8901278000104', '2026-12-01', '2025-06-01', 1, 0, 0, 4.2),
(66, 'Patanjali Amla Murabba', 'patanjali-amla-murabba-500g', 9, 'Patanjali', 'Sweet amla preserve rich in Vitamin C.', 85.00, 78.00, 12.00, 80, 'jar', '500 g', 'murabba-patanjali-amla-500g.jpg', '8904109480573', '2026-12-01', '2025-06-01', 1, 0, 0, 4.1);

-- ============ TEA & COFFEE (category_id=10) ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
(67, 'Tata Tea Gold', 'tata-tea-gold-250g', 10, 'Tata Tea', 'Refreshing and strong CTC tea with golden leaves.', 138.00, 128.00, 5.00, 300, 'pkt', '250 g', 'tea-tata-gold-250g.jpg', '8901069050149', '2026-12-01', '2025-06-01', 1, 1, 1, 4.5),
(68, 'Tata Tea Gold', 'tata-tea-gold-500g', 10, 'Tata Tea', 'Economy pack of Tata Tea Gold.', 265.00, 248.00, 5.00, 200, 'pkt', '500 g', 'tea-tata-gold-500g.jpg', '8901069050163', '2026-12-01', '2025-06-01', 1, 0, 1, 4.5),
(69, 'Red Label Natural Care Tea', 'red-label-tea-500g', 10, 'Brooke Bond', 'Tea with 5 Ayurvedic ingredients for immunity.', 272.00, 255.00, 5.00, 200, 'pkt', '500 g', 'tea-redlabel-500g.jpg', '8901030005040', '2026-12-01', '2025-06-01', 1, 0, 1, 4.4),
(70, 'Wagh Bakri Premium Tea', 'wagh-bakri-premium-250g', 10, 'Wagh Bakri', 'Premium quality tea from Gujarat\'s finest leaves.', 120.00, 112.00, 5.00, 150, 'pkt', '250 g', 'tea-waghbakri-250g.jpg', '8905548000011', '2026-12-01', '2025-06-01', 1, 0, 0, 4.5),
(71, 'Bru Original Filter Coffee', 'bru-filter-coffee-200g', 10, 'Bru', 'Rich and aromatic filter coffee blend.', 178.00, 165.00, 5.00, 150, 'jar', '200 g', 'coffee-bru-200g.jpg', '8901030004036', '2026-12-01', '2025-06-01', 1, 1, 1, 4.4),
(72, 'Nescafe Classic Coffee', 'nescafe-classic-100g', 10, 'Nescafe', 'Instant coffee with bold taste and rich aroma.', 250.00, 232.00, 5.00, 120, 'jar', '100 g', 'coffee-nescafe-classic-100g.jpg', '8901030004883', '2026-12-01', '2025-06-01', 1, 1, 0, 4.5),
(73, 'Patanjali Dant Kanti Herbal Tea', 'patanjali-herbal-tea-100g', 10, 'Patanjali', 'Herbal tea with tulsi, ginger and other herbs.', 55.00, 50.00, 5.00, 100, 'pkt', '100 g', 'tea-patanjali-herbal-100g.jpg', '8904109480610', '2026-12-01', '2025-06-01', 1, 0, 0, 4.0),
(74, 'Tata Tea Agni', 'tata-tea-agni-500g', 10, 'Tata Tea', 'Strong CTC tea for an energizing cup.', 235.00, 220.00, 5.00, 180, 'pkt', '500 g', 'tea-tata-agni-500g.jpg', '8901069050187', '2026-12-01', '2025-06-01', 1, 0, 0, 4.3),
(75, 'Nescafe Sunrise Premium', 'nescafe-sunrise-200g', 10, 'Nescafe', 'Coffee and chicory blend for a smooth cup.', 235.00, 220.00, 5.00, 100, 'jar', '200 g', 'coffee-nescafe-sunrise-200g.jpg', '8901030003855', '2026-12-01', '2025-06-01', 1, 0, 0, 4.3);

-- ============ MILK POWDER (category_id=11) ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
(76, 'Amul Sagar Skimmed Milk Powder', 'amul-sagar-milk-powder-500g', 11, 'Amul', 'Low fat skimmed milk powder for tea and cooking.', 245.00, 228.00, 5.00, 150, 'pkt', '500 g', 'milkpowder-amul-500g.jpg', '8901063000042', '2026-12-01', '2025-06-01', 1, 1, 1, 4.4),
(77, 'Nestlé Everyday Dairy Whitener', 'nestle-everyday-whitener-400g', 11, 'Nestlé', 'Rich and creamy dairy whitener for perfect tea.', 225.00, 210.00, 5.00, 120, 'pkt', '400 g', 'whitener-nestle-400g.jpg', '8901234568010', '2026-12-01', '2025-06-01', 1, 0, 1, 4.4),
(78, 'Horlicks Classic Malt', 'horlicks-classic-500g', 11, 'Horlicks', 'Nutritious malt-based health drink for family.', 325.00, 305.00, 12.00, 150, 'jar', '500 g', 'horlicks-classic-500g.jpg', '8901030005095', '2026-12-01', '2025-06-01', 1, 1, 1, 4.5),
(79, 'Bournvita Health Drink', 'bournvita-500g', 11, 'Cadbury', 'Chocolate malt-based health drink for children.', 295.00, 278.00, 12.00, 150, 'jar', '500 g', 'bournvita-500g.jpg', '8901030004500', '2026-12-01', '2025-06-01', 1, 1, 1, 4.5),
(80, 'Complan Chocolate', 'complan-chocolate-200g', 11, 'Complan', 'Nutrition drink with 100% complete protein.', 165.00, 155.00, 12.00, 100, 'pkt', '200 g', 'complan-choco-200g.jpg', '8906090000010', '2026-12-01', '2025-06-01', 1, 0, 0, 4.3),
(81, 'Boost Health Drink', 'boost-health-drink-500g', 11, 'Boost', 'Energy and stamina drink for active individuals.', 285.00, 268.00, 12.00, 120, 'jar', '500 g', 'boost-500g.jpg', '8901030004524', '2026-12-01', '2025-06-01', 1, 0, 1, 4.4);

-- ============ BISCUITS (category_id=12) ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
(82, 'Parle-G Original Glucose Biscuits', 'parle-g-original-799g', 12, 'Parle', 'World\'s largest selling biscuit. Crispy and sweet.', 65.00, 60.00, 18.00, 500, 'pkt', '799 g', 'parle-g-799g.jpg', '8901718100015', '2026-06-01', '2025-06-01', 1, 1, 1, 4.6),
(83, 'Britannia Good Day Butter', 'britannia-good-day-butter-200g', 12, 'Britannia', 'Buttery cashew biscuits with rich taste.', 35.00, 32.00, 18.00, 400, 'pkt', '200 g', 'goodday-butter-200g.jpg', '8901063005009', '2026-06-01', '2025-06-01', 1, 1, 1, 4.5),
(84, 'Britannia Marie Gold Tea Biscuit', 'britannia-marie-gold-200g', 12, 'Britannia', 'Light and crispy tea time biscuit.', 25.00, 22.00, 18.00, 400, 'pkt', '200 g', 'mariegold-200g.jpg', '8901063005016', '2026-06-01', '2025-06-01', 1, 0, 1, 4.4),
(85, 'Sunfeast Dark Fantasy Choco Fills', 'sunfeast-dark-fantasy-75g', 12, 'Sunfeast', 'Luxury chocolate filled biscuits.', 30.00, 28.00, 18.00, 300, 'pkt', '75 g', 'darkfantasy-75g.jpg', '8901030010990', '2026-06-01', '2025-06-01', 1, 1, 1, 4.7),
(86, 'Parle Hide & Seek Fab', 'parle-hide-seek-fab-120g', 12, 'Parle', 'Choco chip biscuits with rich chocolate.', 30.00, 28.00, 18.00, 300, 'pkt', '120 g', 'hideseeekfab-120g.jpg', '8901718100077', '2026-06-01', '2025-06-01', 1, 0, 1, 4.5),
(87, 'Britannia NutriChoice Digestive', 'britannia-nutrichoice-digestive-250g', 12, 'Britannia', 'Healthy digestive biscuits with whole wheat.', 55.00, 50.00, 18.00, 200, 'pkt', '250 g', 'nutrichoice-digestive-250g.jpg', '8901063005023', '2026-06-01', '2025-06-01', 1, 0, 0, 4.4),
(88, 'Sunfeast Farmlite Digestive', 'sunfeast-farmlite-digestive-100g', 12, 'Sunfeast', 'High fibre digestive biscuit.', 25.00, 23.00, 18.00, 250, 'pkt', '100 g', 'farmlite-digestive-100g.jpg', '8901030011003', '2026-06-01', '2025-06-01', 1, 0, 0, 4.3),
(89, 'Parle Monaco Salted', 'parle-monaco-salted-200g', 12, 'Parle', 'Crispy salted cracker biscuits.', 28.00, 26.00, 18.00, 350, 'pkt', '200 g', 'monaco-200g.jpg', '8901718100084', '2026-06-01', '2025-06-01', 1, 0, 1, 4.4),
(90, 'Oreo Vanilla Cream', 'oreo-vanilla-cream-120g', 12, 'Oreo', 'Twist, lick, dunk! Classic chocolate sandwich biscuit.', 30.00, 28.00, 18.00, 400, 'pkt', '120 g', 'oreo-vanilla-120g.jpg', '8901030011706', '2026-06-01', '2025-06-01', 1, 1, 1, 4.7),
(91, 'Britannia Bourbon Cream', 'britannia-bourbon-100g', 12, 'Britannia', 'Chocolate cream sandwich biscuit.', 20.00, 18.00, 18.00, 400, 'pkt', '100 g', 'bourbon-100g.jpg', '8901063005030', '2026-06-01', '2025-06-01', 1, 0, 1, 4.3);

-- ============ NAMKEEN & SNACKS (category_id=13) ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
(92, 'Haldirams Bhujia Sev', 'haldirams-bhujia-sev-400g', 13, 'Haldirams', 'Classic Rajasthani bhujia with authentic spices.', 120.00, 112.00, 12.00, 200, 'pkt', '400 g', 'bhujia-haldirams-400g.jpg', '8902519101001', '2026-06-01', '2025-06-01', 1, 1, 1, 4.6),
(93, 'Haldirams Aloo Bhujia', 'haldirams-aloo-bhujia-400g', 13, 'Haldirams', 'Crispy potato sev with perfect seasoning.', 110.00, 102.00, 12.00, 180, 'pkt', '400 g', 'aloobhujia-haldirams-400g.jpg', '8902519101018', '2026-06-01', '2025-06-01', 1, 0, 1, 4.5),
(94, 'Haldirams Mixture', 'haldirams-mixture-400g', 13, 'Haldirams', 'Tasty mixed namkeen with nuts and sev.', 115.00, 108.00, 12.00, 160, 'pkt', '400 g', 'mixture-haldirams-400g.jpg', '8902519101032', '2026-06-01', '2025-06-01', 1, 0, 1, 4.4),
(95, 'Lays Classic Salted', 'lays-classic-salted-52g', 13, 'Lay\'s', 'Light and crispy potato chips with salted flavour.', 20.00, 20.00, 12.00, 500, 'pkt', '52 g', 'lays-classic-52g.jpg', '8901030012017', '2026-03-01', '2025-09-01', 1, 0, 1, 4.2),
(96, 'Kurkure Masala Munch', 'kurkure-masala-munch-90g', 13, 'Kurkure', 'Corn puff with tangy masala flavour.', 20.00, 20.00, 12.00, 500, 'pkt', '90 g', 'kurkure-masala-90g.jpg', '8901030012031', '2026-03-01', '2025-09-01', 1, 0, 1, 4.3),
(97, 'Bingo Mad Angles', 'bingo-mad-angles-90g', 13, 'Bingo', 'Crispy triangle chips with achaari flavour.', 20.00, 20.00, 12.00, 400, 'pkt', '90 g', 'bingo-madangles-90g.jpg', '8901030012048', '2026-03-01', '2025-09-01', 1, 0, 0, 4.2),
(98, 'Haldirams Khatta Meetha', 'haldirams-khatta-meetha-400g', 13, 'Haldirams', 'Sweet and tangy mixture with various nuts.', 118.00, 110.00, 12.00, 150, 'pkt', '400 g', 'khattameetha-haldirams-400g.jpg', '8902519101063', '2026-06-01', '2025-06-01', 1, 0, 0, 4.3),
(99, 'Balaji Wafers Cream Onion', 'balaji-wafers-cream-onion-60g', 13, 'Balaji', 'Crispy potato wafers with cream and onion flavour.', 20.00, 20.00, 12.00, 300, 'pkt', '60 g', 'balaji-creamonion-60g.jpg', '8906012300019', '2026-03-01', '2025-09-01', 1, 0, 0, 4.1),
(100, 'Parle Fulltoss Snack', 'parle-fulltoss-70g', 13, 'Parle', 'Puffed wheat snack with chilli lime flavour.', 20.00, 20.00, 12.00, 300, 'pkt', '70 g', 'fulltoss-parle-70g.jpg', '8901718100091', '2026-03-01', '2025-09-01', 1, 0, 0, 4.0);

-- ============ CHOCOLATES (category_id=14) ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
(101, 'Cadbury Dairy Milk', 'cadbury-dairy-milk-123g', 14, 'Cadbury', 'Smooth and creamy milk chocolate. The taste of India.', 85.00, 80.00, 28.00, 300, 'pkt', '123 g', 'dairymilk-cadbury-123g.jpg', '8901030009048', '2026-06-01', '2025-06-01', 1, 1, 1, 4.8),
(102, 'Cadbury 5 Star', 'cadbury-5star-40g', 14, 'Cadbury', 'Chocolate with caramel and nougat. Hard to resist.', 20.00, 20.00, 28.00, 500, 'pcs', '40 g', '5star-40g.jpg', '8901030009055', '2026-06-01', '2025-06-01', 1, 0, 1, 4.6),
(103, 'KitKat 4 Finger', 'kitkat-4finger-37g', 14, 'Nestlé', 'Crispy wafer fingers covered in chocolate.', 40.00, 38.00, 28.00, 400, 'pcs', '37 g', 'kitkat-4finger-37g.jpg', '8901234500153', '2026-06-01', '2025-06-01', 1, 1, 1, 4.7),
(104, 'Munch Choco Bar', 'munch-choco-26g', 14, 'Nestlé', 'Crispy wafer with chocolate coating.', 10.00, 10.00, 28.00, 500, 'pcs', '26 g', 'munch-26g.jpg', '8901234500177', '2026-06-01', '2025-06-01', 1, 0, 1, 4.4),
(105, 'Ferrero Rocher', 'ferrero-rocher-8pcs', 14, 'Ferrero', 'Premium hazelnut chocolate. Perfect gift.', 210.00, 198.00, 28.00, 100, 'box', '100 g', 'ferrero-rocher-8pcs.jpg', '8000500008393', '2026-06-01', '2025-06-01', 1, 1, 0, 4.8),
(106, 'Cadbury Perk', 'cadbury-perk-38g', 14, 'Cadbury', 'Wafer layers covered in smooth chocolate.', 20.00, 20.00, 28.00, 400, 'pcs', '38 g', 'perk-38g.jpg', '8901030009062', '2026-06-01', '2025-06-01', 1, 0, 1, 4.4),
(107, 'Milky Bar', 'milkybar-white-choco-22g', 14, 'Nestlé', 'Smooth and creamy white chocolate.', 15.00, 15.00, 28.00, 400, 'pcs', '22 g', 'milkybar-22g.jpg', '8901234500191', '2026-06-01', '2025-06-01', 1, 0, 0, 4.3);

-- ============ INSTANT FOOD (category_id=15) ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
(108, 'Maggi 2-Minute Masala Noodles', 'maggi-masala-noodles-70g', 15, 'Maggi', 'Iconic instant noodles with masala tastemaker.', 14.00, 14.00, 18.00, 1000, 'pkt', '70 g', 'maggi-masala-70g.jpg', '8901234301118', '2026-06-01', '2025-06-01', 1, 1, 1, 4.5),
(109, 'Maggi 2-Minute Noodles Pack of 4', 'maggi-masala-noodles-4pack', 15, 'Maggi', 'Pack of 4 masala noodles. Economy pack.', 55.00, 52.00, 18.00, 500, 'pkt', '280 g', 'maggi-4pack.jpg', '8901234301125', '2026-06-01', '2025-06-01', 1, 0, 1, 4.5),
(110, 'Sunfeast Yippee Noodles', 'sunfeast-yippee-magic-masala-70g', 15, 'Sunfeast', 'Long smooth noodles with magic masala flavour.', 14.00, 14.00, 18.00, 800, 'pkt', '70 g', 'yippee-magic-70g.jpg', '8901030008041', '2026-06-01', '2025-06-01', 1, 0, 1, 4.3),
(111, 'MTR Dal Makhani Ready Mix', 'mtr-dal-makhani-ready-mix', 15, 'MTR', 'Restaurant quality dal makhani in minutes.', 85.00, 78.00, 12.00, 150, 'pkt', '300 g', 'dalmakhani-mtr-300g.jpg', '8901053003826', '2026-12-01', '2025-06-01', 1, 0, 0, 4.2),
(112, 'MTR Poha Mix', 'mtr-poha-mix-200g', 15, 'MTR', 'Instant poha mix - ready in 5 minutes.', 48.00, 44.00, 12.00, 200, 'pkt', '200 g', 'poha-mtr-200g.jpg', '8901053003833', '2026-12-01', '2025-06-01', 1, 0, 0, 4.2),
(113, 'Knorr Classic Tomato Soup', 'knorr-tomato-soup-40g', 15, 'Knorr', 'Instant tomato soup with real tomato pieces.', 30.00, 28.00, 12.00, 200, 'pkt', '40 g', 'soup-knorr-tomato-40g.jpg', '8901030013113', '2026-12-01', '2025-06-01', 1, 0, 0, 4.3),
(114, 'Patanjali Dalia', 'patanjali-dalia-500g', 15, 'Patanjali', 'Broken wheat dalia for nutritious breakfast.', 40.00, 36.00, 0.00, 200, 'pkt', '500 g', 'dalia-patanjali-500g.jpg', '8904109480764', '2026-12-01', '2025-06-01', 1, 0, 0, 4.0),
(115, 'Maggi Oats Noodles', 'maggi-oats-masala-64g', 15, 'Maggi', 'Healthy noodles made with oats.', 15.00, 14.00, 18.00, 400, 'pkt', '64 g', 'maggi-oats-64g.jpg', '8901234301149', '2026-06-01', '2025-06-01', 1, 0, 0, 4.1);

-- ============ CORNFLAKES & OATS (category_id=16) ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
(116, 'Kellogg\'s Corn Flakes Original', 'kelloggs-cornflakes-original-475g', 16, 'Kellogg\'s', 'Crispy corn flakes for a healthy breakfast.', 225.00, 210.00, 18.00, 150, 'box', '475 g', 'cornflakes-kelloggs-475g.jpg', '5010189104893', '2026-06-01', '2025-06-01', 1, 1, 1, 4.4),
(117, 'Quaker Oats Original', 'quaker-oats-500g', 16, 'Quaker', '100% whole grain rolled oats. Heart healthy.', 135.00, 125.00, 18.00, 200, 'pkt', '500 g', 'oats-quaker-500g.jpg', '8901030010464', '2026-12-01', '2025-06-01', 1, 1, 1, 4.5),
(118, 'Saffola Oats', 'saffola-oats-1kg', 16, 'Saffola', 'Heart healthy oats with high fibre and protein.', 215.00, 200.00, 18.00, 120, 'pkt', '1 kg', 'oats-saffola-1kg.jpg', '8901063006037', '2026-12-01', '2025-06-01', 1, 0, 0, 4.4),
(119, 'Kellogg\'s Chocos', 'kelloggs-chocos-375g', 16, 'Kellogg\'s', 'Whole grain wheat cereal coated with chocolate.', 195.00, 182.00, 18.00, 100, 'box', '375 g', 'chocos-kelloggs-375g.jpg', '8901030010501', '2026-06-01', '2025-06-01', 1, 0, 0, 4.5),
(120, 'Bagrry\'s Crunchy Muesli', 'bagrrys-muesli-500g', 16, 'Bagrry\'s', 'Multi-grain muesli with nuts, seeds and berries.', 285.00, 265.00, 18.00, 80, 'box', '500 g', 'muesli-bagrrys-500g.jpg', '8906017700022', '2026-12-01', '2025-06-01', 1, 0, 0, 4.3);

-- ============ SAUCES & JAMS (category_id=17) ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
(121, 'Maggi Hot & Sweet Tomato Chilli Sauce', 'maggi-hot-sweet-sauce-900g', 17, 'Maggi', 'Tangy tomato sauce with a spicy kick.', 145.00, 135.00, 12.00, 200, 'bottle', '900 g', 'sauce-maggi-hotsweet-900g.jpg', '8901234502001', '2026-12-01', '2025-06-01', 1, 0, 1, 4.4),
(122, 'Kissan Mixed Fruit Jam', 'kissan-mixed-fruit-jam-500g', 17, 'Kissan', 'Fresh mixed fruit jam with natural fruit pieces.', 135.00, 125.00, 12.00, 150, 'jar', '500 g', 'jam-kissan-mixed-500g.jpg', '8901030009116', '2026-12-01', '2025-06-01', 1, 1, 1, 4.5),
(123, 'Dabur Honey', 'dabur-honey-500g', 17, 'Dabur', '100% pure honey with no added sugar.', 225.00, 210.00, 12.00, 200, 'jar', '500 g', 'honey-dabur-500g.jpg', '8901207000041', '2026-12-01', '2025-06-01', 1, 1, 1, 4.6),
(124, 'Patanjali Pure Honey', 'patanjali-honey-500g', 17, 'Patanjali', 'Pure natural honey from Himalayan bees.', 195.00, 182.00, 12.00, 150, 'jar', '500 g', 'honey-patanjali-500g.jpg', '8904109480818', '2026-12-01', '2025-06-01', 1, 0, 0, 4.3),
(125, 'Kissan Tomato Ketchup', 'kissan-tomato-ketchup-1kg', 17, 'Kissan', 'Rich tomato ketchup made from fresh tomatoes.', 165.00, 155.00, 12.00, 180, 'bottle', '1 kg', 'ketchup-kissan-1kg.jpg', '8901030009130', '2026-12-01', '2025-06-01', 1, 0, 1, 4.4),
(126, 'Veeba Mayonnaise', 'veeba-mayo-275g', 17, 'Veeba', 'Creamy eggless mayonnaise for sandwiches and salads.', 95.00, 88.00, 12.00, 100, 'jar', '275 g', 'mayo-veeba-275g.jpg', '8906037900010', '2026-12-01', '2025-06-01', 1, 0, 0, 4.2),
(127, 'Chings Schezwan Chutney', 'chings-schezwan-chutney-250g', 17, 'Ching\'s', 'Spicy Schezwan chutney for Indo-Chinese dishes.', 75.00, 70.00, 12.00, 150, 'jar', '250 g', 'schezwan-chings-250g.jpg', '8901030009147', '2026-12-01', '2025-06-01', 1, 0, 0, 4.3);

-- ============ SOAP (category_id=18) ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
(128, 'Lux Soft Touch Rose Soap', 'lux-soft-touch-rose-100g', 18, 'Lux', 'Rose extracts for soft and glowing skin.', 45.00, 42.00, 18.00, 500, 'bar', '100 g', 'soap-lux-rose-100g.jpg', '8901030756018', '2026-12-01', '2024-12-01', 1, 1, 1, 4.4),
(129, 'Dove Cream Beauty Soap', 'dove-cream-beauty-soap-100g', 18, 'Dove', 'Moisturising beauty bar with 1/4 moisturising cream.', 55.00, 50.00, 18.00, 400, 'bar', '100 g', 'soap-dove-cream-100g.jpg', '8901030769124', '2026-12-01', '2024-12-01', 1, 1, 1, 4.7),
(130, 'Lifebuoy Total 10 Soap', 'lifebuoy-total-10-soap-100g', 18, 'Lifebuoy', 'Complete germ protection for family hygiene.', 40.00, 37.00, 18.00, 500, 'bar', '100 g', 'soap-lifebuoy-100g.jpg', '8901030769131', '2026-12-01', '2024-12-01', 1, 0, 1, 4.3),
(131, 'Dettol Original Soap', 'dettol-original-soap-75g', 18, 'Dettol', '100% better protection against germs.', 45.00, 42.00, 18.00, 400, 'bar', '75 g', 'soap-dettol-original-75g.jpg', '8901396063536', '2026-12-01', '2024-12-01', 1, 1, 1, 4.6),
(132, 'Pears Pure & Gentle Soap', 'pears-pure-gentle-125g', 18, 'Pears', 'Transparent soap with natural glycerine.', 52.00, 48.00, 18.00, 300, 'bar', '125 g', 'soap-pears-125g.jpg', '8901030769155', '2026-12-01', '2024-12-01', 1, 0, 0, 4.5),
(133, 'Santoor Sandal & Turmeric Soap', 'santoor-sandal-turmeric-100g', 18, 'Santoor', 'Sandalwood and turmeric soap for glowing skin.', 38.00, 35.00, 18.00, 400, 'bar', '100 g', 'soap-santoor-100g.jpg', '8901396064007', '2026-12-01', '2024-12-01', 1, 0, 1, 4.4),
(134, 'Godrej No.1 Sandal Soap', 'godrej-no1-sandal-100g', 18, 'Godrej', 'Sandal soap with natural ingredients.', 35.00, 32.00, 18.00, 400, 'bar', '100 g', 'soap-godrej-no1-100g.jpg', '8901017000053', '2026-12-01', '2024-12-01', 1, 0, 1, 4.2),
(135, 'Savlon Moisturizing Handwash', 'savlon-handwash-200ml', 18, 'Savlon', 'Kills 99.9% germs while moisturizing hands.', 75.00, 68.00, 18.00, 300, 'bottle', '200 ml', 'handwash-savlon-200ml.jpg', '8901396033102', '2026-12-01', '2024-12-01', 1, 0, 1, 4.4),
(136, 'Dettol Liquid Handwash', 'dettol-handwash-200ml', 18, 'Dettol', 'Original germ-killing handwash.', 78.00, 72.00, 18.00, 300, 'bottle', '200 ml', 'handwash-dettol-200ml.jpg', '8901396063390', '2026-12-01', '2024-12-01', 1, 0, 1, 4.5);

-- ============ SHAMPOO & HAIR (category_id=19) ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
(137, 'Clinic Plus Strength & Shine Shampoo', 'clinic-plus-strength-175ml', 19, 'Clinic Plus', 'Strengthens hair with milk protein formula.', 115.00, 105.00, 18.00, 200, 'bottle', '175 ml', 'shampoo-clinicplus-175ml.jpg', '8901030756049', '2026-12-01', '2024-12-01', 1, 1, 1, 4.3),
(138, 'Head & Shoulders Anti-Dandruff Shampoo', 'head-shoulders-anti-dandruff-340ml', 19, 'Head & Shoulders', 'Removes dandruff and keeps scalp clean.', 295.00, 275.00, 18.00, 150, 'bottle', '340 ml', 'shampoo-heads-340ml.jpg', '8001090214812', '2026-12-01', '2024-12-01', 1, 1, 1, 4.5),
(139, 'Pantene Pro-V Smooth Shampoo', 'pantene-prov-smooth-340ml', 19, 'Pantene', 'Smooth and sleek formula for frizz-free hair.', 285.00, 265.00, 18.00, 120, 'bottle', '340 ml', 'shampoo-pantene-340ml.jpg', '8001090141477', '2026-12-01', '2024-12-01', 1, 0, 0, 4.4),
(140, 'Dove Intense Repair Shampoo', 'dove-intense-repair-shampoo-340ml', 19, 'Dove', 'Repairs deeply damaged hair.', 315.00, 295.00, 18.00, 100, 'bottle', '340 ml', 'shampoo-dove-340ml.jpg', '8901030769209', '2026-12-01', '2024-12-01', 1, 0, 0, 4.5),
(141, 'Dabur Vatika Naturals Shampoo', 'dabur-vatika-shampoo-340ml', 19, 'Dabur', 'Natural herbal shampoo with coconut and amla.', 225.00, 210.00, 18.00, 150, 'bottle', '340 ml', 'shampoo-vatika-340ml.jpg', '8901207064148', '2026-12-01', '2024-12-01', 1, 0, 1, 4.3),
(142, 'Navratna Cool Hair Oil', 'navratna-cool-hair-oil-200ml', 19, 'Navratna', '9 powerful herbs for cool and healthy hair.', 125.00, 115.00, 18.00, 200, 'bottle', '200 ml', 'hairoil-navratna-200ml.jpg', '8901207020014', '2026-12-01', '2024-12-01', 1, 1, 1, 4.4),
(143, 'Dabur Amla Hair Oil', 'dabur-amla-hair-oil-200ml', 19, 'Dabur', 'Amla hair oil for strong and shiny hair.', 115.00, 105.00, 18.00, 200, 'bottle', '200 ml', 'hairoil-dabur-amla-200ml.jpg', '8901207000010', '2026-12-01', '2024-12-01', 1, 0, 1, 4.4),
(144, 'Parachute Coconut Hair Oil', 'parachute-coconut-oil-200ml', 19, 'Parachute', 'Pure coconut oil for traditional hair care.', 95.00, 88.00, 18.00, 300, 'bottle', '200 ml', 'hairoil-parachute-200ml.jpg', '8901138519200', '2026-12-01', '2024-12-01', 1, 0, 1, 4.5),
(145, 'Himalaya Anti-Dandruff Shampoo', 'himalaya-anti-dandruff-shampoo-400ml', 19, 'Himalaya', 'Natural anti-dandruff with tea tree and rosemary.', 255.00, 238.00, 18.00, 100, 'bottle', '400 ml', 'shampoo-himalaya-400ml.jpg', '8901138510239', '2026-12-01', '2024-12-01', 1, 0, 0, 4.4);

-- ============ TOOTHPASTE (category_id=20) ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
(146, 'Colgate Strong Teeth Toothpaste', 'colgate-strong-teeth-200g', 20, 'Colgate', 'Calcium and minerals for strong healthy teeth.', 115.00, 105.00, 12.00, 400, 'tube', '200 g', 'toothpaste-colgate-strong-200g.jpg', '8901030023631', '2026-12-01', '2024-12-01', 1, 1, 1, 4.5),
(147, 'Colgate MaxFresh Blue Gel', 'colgate-maxfresh-blue-150g', 20, 'Colgate', 'Cooling crystals for maximum fresh breath.', 98.00, 90.00, 12.00, 350, 'tube', '150 g', 'toothpaste-colgate-maxfresh-150g.jpg', '8901030023648', '2026-12-01', '2024-12-01', 1, 0, 1, 4.4),
(148, 'Pepsodent Germicheck Toothpaste', 'pepsodent-germicheck-150g', 20, 'Pepsodent', 'IHF antibacterial formula for germ protection.', 90.00, 83.00, 12.00, 300, 'tube', '150 g', 'toothpaste-pepsodent-150g.jpg', '8901030756056', '2026-12-01', '2024-12-01', 1, 0, 1, 4.2),
(149, 'Close Up Red Hot Toothpaste', 'closeup-red-hot-150g', 20, 'Close Up', 'Spicy fresh toothpaste with mouthwash effect.', 88.00, 82.00, 12.00, 300, 'tube', '150 g', 'toothpaste-closeup-150g.jpg', '8901030756063', '2026-12-01', '2024-12-01', 1, 0, 0, 4.3),
(150, 'Patanjali Dant Kanti Herbal Toothpaste', 'patanjali-dant-kanti-200g', 20, 'Patanjali', 'Ayurvedic herbal toothpaste with neem and clove.', 75.00, 68.00, 12.00, 400, 'tube', '200 g', 'toothpaste-patanjali-200g.jpg', '8904109481013', '2026-12-01', '2024-12-01', 1, 0, 1, 4.4),
(151, 'Himalaya Complete Care Toothpaste', 'himalaya-complete-care-80g', 20, 'Himalaya', 'Natural toothpaste with pomegranate and holy basil.', 65.00, 60.00, 12.00, 250, 'tube', '80 g', 'toothpaste-himalaya-80g.jpg', '8901138514213', '2026-12-01', '2024-12-01', 1, 0, 0, 4.3),
(152, 'Colgate Toothbrush ZigZag', 'colgate-toothbrush-zigzag', 20, 'Colgate', 'Zigzag bristles for superior cleaning.', 45.00, 42.00, 12.00, 500, 'pcs', '1 pc', 'brush-colgate-zigzag.jpg', '8901030023655', '2028-12-01', '2024-12-01', 1, 0, 1, 4.3),
(153, 'Oral-B Pro-Health Toothbrush', 'oral-b-pro-health-brush', 20, 'Oral-B', 'Criss-cross bristles for deep clean.', 55.00, 50.00, 12.00, 400, 'pcs', '1 pc', 'brush-oralb.jpg', '3014260274504', '2028-12-01', '2024-12-01', 1, 0, 0, 4.4);

-- ============ DETERGENT (category_id=21) ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
(154, 'Surf Excel Easy Wash Detergent', 'surf-excel-easy-wash-3kg', 21, 'Surf Excel', 'Removes tough stains even in cold water.', 395.00, 368.00, 18.00, 200, 'bag', '3 kg', 'detergent-surfexcel-3kg.jpg', '8901030756070', '2026-12-01', '2024-12-01', 1, 1, 1, 4.5),
(155, 'Ariel Complete Detergent Powder', 'ariel-complete-2kg', 21, 'Ariel', 'Superior cleaning for bright clothes.', 340.00, 315.00, 18.00, 180, 'bag', '2 kg', 'detergent-ariel-2kg.jpg', '8001090141880', '2026-12-01', '2024-12-01', 1, 0, 1, 4.5),
(156, 'Wheel Active 3 Bar Detergent', 'wheel-active3-detergent-1kg', 21, 'Wheel', 'Powerful washing powder for tough stains.', 95.00, 88.00, 18.00, 300, 'bag', '1 kg', 'detergent-wheel-1kg.jpg', '8901030756087', '2026-12-01', '2024-12-01', 1, 0, 1, 4.2),
(157, 'Ghadi Detergent Powder', 'ghadi-detergent-2kg', 21, 'Ghadi', 'Budget-friendly detergent with good cleaning power.', 180.00, 165.00, 18.00, 250, 'bag', '2 kg', 'detergent-ghadi-2kg.jpg', '8906025900019', '2026-12-01', '2024-12-01', 1, 0, 1, 4.1),
(158, 'Surf Excel Matic Liquid', 'surf-excel-matic-liquid-1l', 21, 'Surf Excel', 'Front load washing machine liquid detergent.', 295.00, 275.00, 18.00, 150, 'bottle', '1 L', 'detergent-surfexcel-matic-1l.jpg', '8901030756094', '2026-12-01', '2024-12-01', 1, 0, 0, 4.4),
(159, 'Rin Advanced Bar', 'rin-advanced-bar-250g', 21, 'Rin', 'Detergent bar for bright white clothes.', 45.00, 42.00, 18.00, 400, 'bar', '250 g', 'rin-bar-250g.jpg', '8901030756100', '2026-12-01', '2024-12-01', 1, 0, 1, 4.2);

-- ============ DISHWASH (category_id=22) ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
(160, 'Vim Dishwash Liquid', 'vim-dishwash-liquid-500ml', 22, 'Vim', 'Concentrated dish liquid that cuts tough grease.', 95.00, 88.00, 18.00, 300, 'bottle', '500 ml', 'dishwash-vim-500ml.jpg', '8901030756117', '2026-12-01', '2024-12-01', 1, 1, 1, 4.4),
(161, 'Vim Bar', 'vim-bar-300g', 22, 'Vim', 'Dishwash bar with lime for sparkling clean utensils.', 30.00, 28.00, 18.00, 500, 'bar', '300 g', 'vim-bar-300g.jpg', '8901030756124', '2026-12-01', '2024-12-01', 1, 0, 1, 4.3),
(162, 'Pril Dishwash Liquid', 'pril-dishwash-500ml', 22, 'Pril', 'Powerful degreasing formula for clean utensils.', 98.00, 90.00, 18.00, 250, 'bottle', '500 ml', 'dishwash-pril-500ml.jpg', '8906025900026', '2026-12-01', '2024-12-01', 1, 0, 0, 4.2),
(163, 'Scotch Brite Scrub Pad', 'scotchbrite-scrub-pad-3pcs', 22, 'Scotch Brite', 'Heavy duty scrub pad for tough cleaning.', 55.00, 50.00, 18.00, 400, 'pkt', '3 pcs', 'scrubpad-scotchbrite-3pcs.jpg', '8902280000018', '2028-12-01', '2024-12-01', 1, 0, 1, 4.5);

-- ============ FLOOR & TOILET CLEANER (category_id=23) ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
(164, 'Harpic Power Plus Toilet Cleaner', 'harpic-power-plus-1l', 23, 'Harpic', 'Kills 99.9% germs in toilet. Removes stains.', 145.00, 135.00, 18.00, 200, 'bottle', '1 L', 'harpic-powerplus-1l.jpg', '8901396049117', '2026-12-01', '2024-12-01', 1, 1, 1, 4.6),
(165, 'Lizol Floor Cleaner Citrus', 'lizol-floor-cleaner-1l', 23, 'Lizol', 'Disinfectant floor cleaner with citrus fragrance.', 155.00, 145.00, 18.00, 200, 'bottle', '1 L', 'lizol-citrus-1l.jpg', '8901396049124', '2026-12-01', '2024-12-01', 1, 1, 1, 4.5),
(166, 'Domex Ultra Thick Bleach', 'domex-ultra-thick-1l', 23, 'Domex', 'Bleach-based cleaner for white and sparkling toilets.', 135.00, 125.00, 18.00, 150, 'bottle', '1 L', 'domex-1l.jpg', '8901030756131', '2026-12-01', '2024-12-01', 1, 0, 0, 4.3),
(167, 'Phenyl Floor Cleaner', 'phenyl-floor-cleaner-1l', 23, 'Rathi Brand', 'Pine phenyl for floor cleaning and disinfection.', 75.00, 68.00, 18.00, 200, 'bottle', '1 L', 'phenyl-1l.jpg', '8906000000000', '2026-12-01', '2024-12-01', 1, 0, 1, 4.0);

-- ============ MOSQUITO REPELLENT (category_id=24) ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
(168, 'Good Knight Power Activ+ Refill', 'goodknight-power-activ-refill-45ml', 24, 'Good Knight', 'Mosquito liquid machine refill. 45 nights protection.', 125.00, 115.00, 12.00, 200, 'bottle', '45 ml', 'goodknight-refill-45ml.jpg', '8901030600035', '2026-12-01', '2024-12-01', 1, 1, 1, 4.5),
(169, 'Good Knight Power Activ Machine + Refill', 'goodknight-machine-refill-combo', 24, 'Good Knight', 'Mosquito repellent machine with refill starter pack.', 165.00, 155.00, 12.00, 150, 'set', '1 set', 'goodknight-machine-combo.jpg', '8901030600059', '2026-12-01', '2024-12-01', 1, 0, 1, 4.4),
(170, 'All Out Ultra Power+ Refill', 'allout-ultra-refill-45ml', 24, 'All Out', 'Fast action liquid mosquito repellent refill.', 120.00, 110.00, 12.00, 150, 'bottle', '45 ml', 'allout-ultra-45ml.jpg', '8901030600073', '2026-12-01', '2024-12-01', 1, 0, 1, 4.4),
(171, 'Tortoise Mosquito Coil', 'tortoise-mosquito-coil-10pcs', 24, 'Tortoise', 'Long lasting mosquito coil. Pack of 10.', 45.00, 42.00, 12.00, 300, 'pkt', '10 pcs', 'coil-tortoise-10pcs.jpg', '8901030600090', '2026-12-01', '2024-12-01', 1, 0, 1, 4.1),
(172, 'Odomos Mosquito Repellent Cream', 'odomos-cream-50g', 24, 'Odomos', 'Non-sticky mosquito repellent cream. Safe for family.', 68.00, 62.00, 12.00, 200, 'tube', '50 g', 'odomos-cream-50g.jpg', '8901030600107', '2026-12-01', '2024-12-01', 1, 0, 0, 4.2);

-- ============ PERSONAL CARE (category_id=25) ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
(173, 'Vaseline Intensive Care Lotion', 'vaseline-intensive-care-300ml', 25, 'Vaseline', 'Deep moisture repair lotion for dry skin.', 225.00, 210.00, 18.00, 200, 'bottle', '300 ml', 'vaseline-lotion-300ml.jpg', '8901030756148', '2026-12-01', '2024-12-01', 1, 1, 1, 4.5),
(174, 'Boroline Antiseptic Cream', 'boroline-antiseptic-cream-50g', 25, 'Boroline', 'Antiseptic moisturizing cream for skin protection.', 68.00, 62.00, 12.00, 200, 'tube', '50 g', 'boroline-50g.jpg', '8901030756155', '2026-12-01', '2024-12-01', 1, 0, 1, 4.5),
(175, 'Himalaya Nourishing Skin Cream', 'himalaya-nourishing-cream-50g', 25, 'Himalaya', 'Natural moisturizer with milk cream and natural vitamins.', 85.00, 78.00, 12.00, 200, 'tube', '50 g', 'cream-himalaya-50g.jpg', '8901138511465', '2026-12-01', '2024-12-01', 1, 0, 0, 4.3),
(176, 'Fair & Lovely Advanced Multi Vitamin', 'faireandlovely-multivitamin-50g', 25, 'Glow & Lovely', 'Advanced skin brightening with multivitamins.', 95.00, 88.00, 18.00, 200, 'tube', '50 g', 'glowlovely-50g.jpg', '8901030756162', '2026-12-01', '2024-12-01', 1, 0, 0, 4.0),
(177, 'Axe Dark Temptation Deo Body Spray', 'axe-dark-temptation-150ml', 25, 'Axe', 'Long lasting deodorant with dark temptation fragrance.', 175.00, 162.00, 18.00, 150, 'can', '150 ml', 'axe-dark-150ml.jpg', '8901030756179', '2026-12-01', '2024-12-01', 1, 0, 0, 4.3),
(178, 'Fogg Fresh Body Spray', 'fogg-fresh-body-spray-150ml', 25, 'Fogg', 'No gas, only perfume body spray for long freshness.', 165.00, 155.00, 18.00, 150, 'can', '150 ml', 'fogg-fresh-150ml.jpg', '8906090000027', '2026-12-01', '2024-12-01', 1, 0, 1, 4.4),
(179, 'Johnson\'s Baby Powder', 'johnsons-baby-powder-200g', 26, 'Johnson\'s', 'Gentle talc powder for baby skin.', 135.00, 125.00, 18.00, 200, 'bottle', '200 g', 'johnsons-powder-200g.jpg', '8901030756186', '2026-12-01', '2024-12-01', 1, 0, 0, 4.6);

-- ============ BABY CARE (category_id=26) ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
(180, 'Johnson\'s Baby Soap', 'johnsons-baby-soap-100g', 26, 'Johnson\'s', 'Mild and gentle baby soap for sensitive skin.', 58.00, 54.00, 18.00, 200, 'bar', '100 g', 'johnsons-soap-100g.jpg', '8901030756193', '2026-12-01', '2024-12-01', 1, 1, 1, 4.7),
(181, 'Johnson\'s Baby Shampoo', 'johnsons-baby-shampoo-200ml', 26, 'Johnson\'s', 'No more tears formula. Gentle for baby eyes.', 155.00, 145.00, 18.00, 150, 'bottle', '200 ml', 'johnsons-shampoo-200ml.jpg', '8901030756200', '2026-12-01', '2024-12-01', 1, 0, 1, 4.7),
(182, 'Himalaya Baby Cream', 'himalaya-baby-cream-100g', 26, 'Himalaya', 'Natural moisturizing baby cream with olive oil.', 115.00, 105.00, 12.00, 100, 'tube', '100 g', 'himalaya-babycream-100g.jpg', '8901138516248', '2026-12-01', '2024-12-01', 1, 0, 0, 4.6),
(183, 'Dabur Lal Tail Baby Oil', 'dabur-lal-tail-100ml', 26, 'Dabur', 'Traditional Ayurvedic massage oil for babies.', 115.00, 105.00, 12.00, 100, 'bottle', '100 ml', 'dabur-laltail-100ml.jpg', '8901207000027', '2026-12-01', '2024-12-01', 1, 0, 0, 4.5);

-- ============ KITCHEN ESSENTIALS (category_id=27) ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
(184, 'Shalimar Matchbox', 'shalimar-matchbox-10pcs', 27, 'Shalimar', 'Pack of 10 safety matchboxes.', 25.00, 22.00, 0.00, 500, 'pkt', '10 pcs', 'matchbox-shalimar.jpg', '8906063000010', '2027-12-01', '2024-12-01', 1, 0, 1, 4.2),
(185, 'Godrej Ezee Liquid Detergent', 'godrej-ezee-500ml', 27, 'Godrej', 'Gentle liquid detergent for delicate clothes.', 115.00, 105.00, 18.00, 150, 'bottle', '500 ml', 'ezee-godrej-500ml.jpg', '8901017000091', '2026-12-01', '2024-12-01', 1, 0, 0, 4.3),
(186, 'Cello Tape', 'cello-tape-transparent', 27, 'Cello', 'Transparent adhesive tape for packaging.', 25.00, 22.00, 18.00, 300, 'pcs', '1 roll', 'cellotape.jpg', '8906063000027', '2028-12-01', '2024-12-01', 1, 0, 0, 4.0),
(187, 'Ziplock Polybags 100pcs', 'ziplock-polybags-100pcs', 27, 'Local', 'Resealable ziplock bags for storage.', 45.00, 40.00, 18.00, 200, 'pkt', '100 pcs', 'ziplock-bags.jpg', '8906063000034', '2028-12-01', '2024-12-01', 1, 0, 0, 4.0),
(188, 'Nirlon Kitchen Foil', 'nirlon-kitchen-foil-9m', 27, 'Nirlon', 'Aluminium foil for food storage and cooking.', 65.00, 60.00, 18.00, 150, 'pkt', '9 m', 'foil-nirlon-9m.jpg', '8906063000041', '2028-12-01', '2024-12-01', 1, 0, 0, 4.1),
(189, 'Swach Broom', 'swach-broom', 27, 'Swach', 'Natural fiber broom for floor sweeping.', 55.00, 50.00, 5.00, 100, 'pcs', '1 pc', 'broom.jpg', '8906063000058', '2028-12-01', '2024-12-01', 1, 0, 0, 4.0),
(190, 'Scotch Brite Mop', 'scotchbrite-mop', 27, 'Scotch Brite', 'Easy squeeze mop for floor cleaning.', 295.00, 275.00, 18.00, 50, 'pcs', '1 pc', 'mop-scotchbrite.jpg', '8902280000025', '2028-12-01', '2024-12-01', 1, 0, 0, 4.3);

-- ============ POOJA ITEMS (category_id=28) ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
(191, 'Cycle Pure Agarbatti Sandal', 'cycle-agarbatti-sandal-100g', 28, 'Cycle Pure', 'Sandalwood incense sticks for prayer.', 45.00, 42.00, 5.00, 300, 'pkt', '100 g', 'agarbatti-cycle-sandal.jpg', '8904180000010', '2026-12-01', '2024-12-01', 1, 0, 1, 4.4),
(192, 'Mangaldeep Rose Agarbatti', 'mangaldeep-rose-agarbatti', 28, 'Mangaldeep', 'Rose fragrance agarbatti for daily puja.', 35.00, 32.00, 5.00, 300, 'pkt', '30 g', 'agarbatti-mangaldeep-rose.jpg', '8904180000027', '2026-12-01', '2024-12-01', 1, 0, 1, 4.3),
(193, 'Patanjali Havan Samagri', 'patanjali-havan-samagri-200g', 28, 'Patanjali', 'Pure herbal havan samagri for yagna.', 55.00, 50.00, 5.00, 200, 'pkt', '200 g', 'havansamagri-patanjali.jpg', '8904109481051', '2026-12-01', '2024-12-01', 1, 0, 0, 4.5),
(194, 'Parag Camphor', 'parag-camphor-50g', 28, 'Parag', 'Pure camphor tablets for puja.', 38.00, 35.00, 5.00, 400, 'pkt', '50 g', 'camphor-parag-50g.jpg', '8906063000065', '2026-12-01', '2024-12-01', 1, 0, 1, 4.4),
(195, 'Kumkum Bindi Packet', 'kumkum-bindi-packet', 28, 'Local', 'Red kumkum powder for tilak and puja.', 20.00, 18.00, 5.00, 500, 'pkt', '50 g', 'kumkum.jpg', '8906063000072', '2028-12-01', '2024-12-01', 1, 0, 0, 4.2);

-- ============ STATIONERY (category_id=29) ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
(196, 'Classmate Notebook 200 Pages', 'classmate-notebook-200pages', 29, 'Classmate', 'Single line notebook for school and college.', 65.00, 60.00, 12.00, 200, 'pcs', '1 pc', 'notebook-classmate-200.jpg', '8906063000089', '2028-12-01', '2024-12-01', 1, 0, 1, 4.3),
(197, 'Cello Gripper Ballpen Blue', 'cello-gripper-ballpen-blue', 29, 'Cello', 'Smooth writing ball pen for daily use.', 15.00, 14.00, 12.00, 500, 'pcs', '1 pc', 'pen-cello-blue.jpg', '8906063000096', '2028-12-01', '2024-12-01', 1, 0, 1, 4.2),
(198, 'Natraj Pencil HB', 'natraj-pencil-hb-10pcs', 29, 'Natraj', 'HB pencil set. Smooth writing.', 30.00, 28.00, 12.00, 400, 'pkt', '10 pcs', 'pencil-natraj-10.jpg', '8906063000102', '2028-12-01', '2024-12-01', 1, 0, 1, 4.2),
(199, 'Fevicol MR White Adhesive', 'fevicol-mr-50g', 29, 'Fevicol', 'Synthetic resin adhesive for paper and craft.', 35.00, 32.00, 18.00, 300, 'bottle', '50 g', 'fevicol-mr-50g.jpg', '8906063000119', '2026-12-01', '2024-12-01', 1, 0, 0, 4.4);

-- ============ BATTERIES (category_id=30) ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
(200, 'Duracell AA Alkaline Batteries', 'duracell-aa-4pack', 30, 'Duracell', 'Long lasting AA alkaline batteries. Pack of 4.', 185.00, 172.00, 18.00, 200, 'pkt', '4 pcs', 'battery-duracell-aa-4.jpg', '5000394077515', '2032-12-01', '2024-12-01', 1, 0, 1, 4.6),
(201, 'Eveready AA Batteries', 'eveready-aa-4pack', 30, 'Eveready', 'Powerful AA batteries for all devices.', 85.00, 78.00, 18.00, 300, 'pkt', '4 pcs', 'battery-eveready-aa-4.jpg', '8901030200019', '2030-12-01', '2024-12-01', 1, 0, 1, 4.3),
(202, 'Eveready AAA Batteries', 'eveready-aaa-4pack', 30, 'Eveready', 'AAA batteries for remotes and small devices.', 75.00, 68.00, 18.00, 300, 'pkt', '4 pcs', 'battery-eveready-aaa-4.jpg', '8901030200026', '2030-12-01', '2024-12-01', 1, 0, 0, 4.2),
(203, 'Nippo AA Carbon Battery', 'nippo-aa-carbon-2pack', 30, 'Nippo', 'Budget AA carbon batteries.', 35.00, 32.00, 18.00, 400, 'pkt', '2 pcs', 'battery-nippo-aa-2.jpg', '8906063000126', '2028-12-01', '2024-12-01', 1, 0, 0, 4.0);

-- ============ ADDITIONAL PRODUCTS - More categories and brands ============
INSERT IGNORE INTO `products` (`id`,`name`,`slug`,`category_id`,`brand`,`description`,`mrp`,`selling_price`,`gst_percent`,`stock`,`unit`,`weight`,`image`,`barcode`,`expiry_date`,`manufacture_date`,`is_available`,`is_featured`,`is_bestseller`,`rating`) VALUES
-- More Tea & Coffee
(204, 'Tetley Green Tea', 'tetley-green-tea-25bags', 10, 'Tetley', 'Refreshing green tea bags with natural antioxidants.', 125.00, 115.00, 5.00, 100, 'box', '25 bags', 'tea-tetley-green-25.jpg', '8901030000133', '2026-12-01', '2025-06-01', 1, 0, 0, 4.3),
(205, 'Lipton Yellow Label Tea', 'lipton-yellow-label-250g', 10, 'Lipton', 'Brisk and refreshing yellow label tea.', 130.00, 120.00, 5.00, 150, 'pkt', '250 g', 'tea-lipton-250g.jpg', '8901030000157', '2026-12-01', '2025-06-01', 1, 0, 0, 4.2),

-- More Oil
(206, 'Groundnut Oil Fortune', 'fortune-groundnut-oil-1l', 5, 'Fortune', 'Pure groundnut oil for Indian cooking.', 178.00, 165.00, 5.00, 120, 'bottle', '1 L', 'oil-groundnut-fortune-1l.jpg', '8901063127051', '2026-12-01', '2025-06-01', 1, 0, 0, 4.2),
(207, 'Coconut Oil Parachute', 'parachute-coconut-oil-cooking-500ml', 5, 'Parachute', 'Pure coconut oil for south Indian cooking.', 115.00, 105.00, 5.00, 100, 'bottle', '500 ml', 'oil-coconut-parachute-500ml.jpg', '8901138515111', '2026-12-01', '2025-06-01', 1, 0, 0, 4.4),

-- More Atta
(208, 'MTR Atta Plain Flour Mix', 'mtr-maida-1kg', 1, 'MTR', 'Fine maida for bakery and cooking.', 42.00, 38.00, 5.00, 150, 'pkt', '1 kg', 'mtr-maida-1kg.jpg', '8901053003840', '2026-06-01', '2025-06-01', 1, 0, 0, 4.0),

-- More Masala
(209, 'MDH Chicken Masala', 'mdh-chicken-masala-50g', 6, 'MDH', 'Authentic blend for Indian chicken dishes.', 55.00, 50.00, 5.00, 150, 'pkt', '50 g', 'masala-mdh-chicken-50g.jpg', '8901650100063', '2026-12-01', '2025-06-01', 1, 0, 0, 4.4),
(210, 'Everest Pav Bhaji Masala', 'everest-pav-bhaji-50g', 6, 'Everest', 'Perfect spice blend for pav bhaji street food.', 48.00, 44.00, 5.00, 180, 'pkt', '50 g', 'masala-everest-pavbhaji-50g.jpg', '8901897000053', '2026-12-01', '2025-06-01', 1, 0, 0, 4.3),
(211, 'Catch Jeera Powder', 'catch-jeera-powder-100g', 6, 'Catch', 'Pure roasted cumin powder.', 65.00, 60.00, 5.00, 200, 'pkt', '100 g', 'jeera-catch-100g.jpg', '8901234100058', '2026-12-01', '2025-06-01', 1, 0, 0, 4.2),

-- More Biscuits
(212, 'Britannia 50-50 Maska Chaska', 'britannia-5050-maska-chaska-200g', 12, 'Britannia', 'Snacky biscuit with butter and spice flavour.', 28.00, 26.00, 18.00, 300, 'pkt', '200 g', '5050-maska-200g.jpg', '8901063005047', '2026-06-01', '2025-06-01', 1, 0, 0, 4.3),
(213, 'Parle Krackjack Sweet Salty', 'parle-krackjack-200g', 12, 'Parle', 'Classic sweet and salty cracker biscuit.', 25.00, 23.00, 18.00, 350, 'pkt', '200 g', 'krackjack-200g.jpg', '8901718100108', '2026-06-01', '2025-06-01', 1, 0, 0, 4.3),

-- More Snacks
(214, 'Too Yumm Multigrain Puffs', 'tooyumm-multigrain-50g', 13, 'Too Yumm', 'Baked multigrain puffs with less oil.', 20.00, 20.00, 12.00, 300, 'pkt', '50 g', 'tooyumm-multigrain-50g.jpg', '8906037900027', '2026-03-01', '2025-09-01', 1, 0, 0, 4.1),
(215, 'Haldirams Moong Dal', 'haldirams-moong-dal-400g', 13, 'Haldirams', 'Crispy fried moong dal with spices.', 115.00, 108.00, 12.00, 150, 'pkt', '400 g', 'moongdal-haldirams-400g.jpg', '8902519101087', '2026-06-01', '2025-06-01', 1, 0, 0, 4.4),

-- More chocolates
(216, 'Cadbury Gems Chocolate', 'cadbury-gems-18g', 14, 'Cadbury', 'Colourful crispy chocolate buttons for kids.', 10.00, 10.00, 28.00, 500, 'pkt', '18 g', 'gems-cadbury-18g.jpg', '8901030009079', '2026-06-01', '2025-06-01', 1, 0, 1, 4.5),
(217, 'Cadbury Eclairs', 'cadbury-eclairs-250g', 14, 'Cadbury', 'Chocolate toffee with liquid chocolate centre.', 80.00, 75.00, 28.00, 300, 'pkt', '250 g', 'eclairs-cadbury-250g.jpg', '8901030009086', '2026-06-01', '2025-06-01', 1, 0, 1, 4.4),

-- More Personal Care
(218, 'Nivea Soft Light Moisturiser', 'nivea-soft-200ml', 25, 'Nivea', 'Instant moisture for face, hands and body.', 195.00, 182.00, 18.00, 150, 'jar', '200 ml', 'nivea-soft-200ml.jpg', '4005808317004', '2026-12-01', '2024-12-01', 1, 0, 0, 4.5),
(219, 'Ponds Cold Cream', 'ponds-cold-cream-55g', 25, 'Pond\'s', 'Classic cold cream moisturizer for skin care.', 78.00, 72.00, 18.00, 200, 'jar', '55 g', 'ponds-coldcream-55g.jpg', '8901030756216', '2026-12-01', '2024-12-01', 1, 0, 0, 4.3),

-- More Detergent
(220, 'Vim Dishwash Gel', 'vim-dishwash-gel-250ml', 22, 'Vim', 'Concentrated dishwash gel in easy squeeze bottle.', 55.00, 50.00, 18.00, 250, 'bottle', '250 ml', 'vim-gel-250ml.jpg', '8901030756223', '2026-12-01', '2024-12-01', 1, 0, 0, 4.3),

-- More Rice
(221, 'Daawat Basmati Brown Rice', 'daawat-brown-rice-1kg', 2, 'Daawat', 'Whole grain brown basmati for healthy cooking.', 155.00, 142.00, 5.00, 80, 'pkt', '1 kg', 'rice-daawat-brown-1kg.jpg', '8901719100048', '2027-01-01', '2024-01-01', 1, 0, 0, 4.2),
(222, 'Lal Qilla Basmati Rice', 'lal-qilla-basmati-5kg', 2, 'Lal Qilla', 'Traditional aged basmati with long grain.', 490.00, 460.00, 5.00, 100, 'bag', '5 kg', 'rice-lalqilla-5kg.jpg', '8901234700012', '2027-01-01', '2024-01-01', 1, 0, 0, 4.4),

-- More Dal
(223, 'Tata Sampann Kabuli Chana', 'tata-sampann-kabuli-chana-1kg', 3, 'Tata Sampann', 'White chickpeas for chole and curries.', 178.00, 165.00, 5.00, 120, 'pkt', '1 kg', 'chana-tata-kabuli-1kg.jpg', '8901719111129', '2026-12-01', '2025-12-01', 1, 0, 0, 4.3),
(224, 'Rajdhani Chana Sattu', 'rajdhani-chana-sattu-500g', 3, 'Rajdhani', 'Roasted chana flour for healthy drinks.', 65.00, 60.00, 5.00, 100, 'pkt', '500 g', 'sattu-rajdhani-500g.jpg', '8906015720102', '2026-12-01', '2025-12-01', 1, 0, 0, 4.1),

-- More Instant food
(225, 'Patanjali Atta Noodles', 'patanjali-atta-noodles-70g', 15, 'Patanjali', 'Atta-based instant noodles with masala.', 15.00, 14.00, 18.00, 400, 'pkt', '70 g', 'noodles-patanjali-70g.jpg', '8904109481068', '2026-06-01', '2025-06-01', 1, 0, 0, 4.0),
(226, 'MTR Upma Mix', 'mtr-upma-mix-500g', 15, 'MTR', 'Traditional South Indian upma mix.', 115.00, 105.00, 12.00, 100, 'pkt', '500 g', 'upma-mtr-500g.jpg', '8901053003857', '2026-12-01', '2025-06-01', 1, 0, 0, 4.2),
(227, 'Knorr Chinese Noodles', 'knorr-chinese-noodles-60g', 15, 'Knorr', 'Indo-Chinese style noodles in hakka style.', 28.00, 26.00, 18.00, 200, 'pkt', '60 g', 'noodles-knorr-60g.jpg', '8901030013137', '2026-06-01', '2025-06-01', 1, 0, 0, 4.0),

-- More Soap and hygiene
(228, 'Medimix Ayurvedic Soap', 'medimix-ayurvedic-soap-125g', 18, 'Medimix', '18 ayurvedic herbs soap for healthy skin.', 45.00, 42.00, 18.00, 300, 'bar', '125 g', 'soap-medimix-125g.jpg', '8906025900033', '2026-12-01', '2024-12-01', 1, 0, 1, 4.5),
(229, 'Savlon Antiseptic Liquid', 'savlon-antiseptic-liquid-200ml', 18, 'Savlon', 'Antiseptic liquid for wound cleaning.', 95.00, 88.00, 12.00, 150, 'bottle', '200 ml', 'savlon-liquid-200ml.jpg', '8901396033119', '2026-12-01', '2024-12-01', 1, 0, 0, 4.4),
(230, 'Dettol Antiseptic Liquid', 'dettol-antiseptic-liquid-250ml', 18, 'Dettol', 'Multi-purpose antiseptic for personal hygiene.', 125.00, 115.00, 12.00, 150, 'bottle', '250 ml', 'dettol-antiseptic-250ml.jpg', '8901396063543', '2026-12-01', '2024-12-01', 1, 0, 0, 4.5),

-- Additional Spices & Masala
(231, 'MDH Sambhar Masala', 'mdh-sambhar-masala-500g', 6, 'MDH', 'Economy pack of sambhar masala blend.', 220.00, 205.00, 5.00, 100, 'pkt', '500 g', 'masala-mdh-sambhar-500g.jpg', '8901650100070', '2026-12-01', '2025-06-01', 1, 0, 0, 4.4),
(232, 'Everest Garam Masala', 'everest-garam-masala-100g', 6, 'Everest', 'Premium blend of whole and ground spices.', 82.00, 76.00, 5.00, 200, 'pkt', '100 g', 'masala-everest-garam-100g.jpg', '8901897000060', '2026-12-01', '2025-06-01', 1, 0, 0, 4.4),
(233, 'Patanjali Shahi Paneer Masala', 'patanjali-shahi-paneer-masala-50g', 6, 'Patanjali', 'Ready masala for creamy paneer preparations.', 42.00, 38.00, 5.00, 150, 'pkt', '50 g', 'masala-patanjali-paneer-50g.jpg', '8904109481075', '2026-12-01', '2025-06-01', 1, 0, 0, 4.1),

-- Papad
(234, 'Lijjat Masala Papad', 'lijjat-masala-papad-200g', 9, 'Lijjat', 'Spicy masala papads for frying.', 60.00, 55.00, 5.00, 200, 'pkt', '200 g', 'papad-lijjat-masala-200g.jpg', '8904030000027', '2026-12-01', '2025-06-01', 1, 0, 0, 4.4),
(235, 'Bikano Khichiya Papad', 'bikano-khichiya-papad-200g', 9, 'Bikano', 'Rice papad - light and crispy.', 55.00, 50.00, 5.00, 150, 'pkt', '200 g', 'papad-bikano-khichiya-200g.jpg', '8902519200010', '2026-12-01', '2025-06-01', 1, 0, 0, 4.2),

-- Cornflakes & cereals
(236, 'Kellogg\'s Special K', 'kelloggs-special-k-400g', 16, 'Kellogg\'s', 'Thin crispy flakes with fiber for slimming.', 265.00, 248.00, 18.00, 80, 'box', '400 g', 'specialk-kelloggs-400g.jpg', '5010189103742', '2026-06-01', '2025-06-01', 1, 0, 0, 4.3),
(237, 'Quaker Oats with Chia Seeds', 'quaker-oats-chia-seeds-400g', 16, 'Quaker', 'Rolled oats enriched with chia seeds.', 175.00, 162.00, 18.00, 100, 'pkt', '400 g', 'oats-quaker-chia-400g.jpg', '8901030010488', '2026-12-01', '2025-06-01', 1, 0, 0, 4.4),

-- Dry Fruits extra
(238, 'Happilo Dates Medjool', 'happilo-dates-250g', 7, 'Happilo', 'Soft and sweet premium dates.', 285.00, 265.00, 5.00, 60, 'pkt', '250 g', 'dates-happilo-250g.jpg', '8906088800046', '2026-06-01', '2025-06-01', 1, 0, 0, 4.4),
(239, 'Tulsi Akhrot Kernels', 'tulsi-walnut-kernels-100g', 7, 'Tulsi', 'Shelled walnut kernels.', 215.00, 198.00, 5.00, 50, 'pkt', '100 g', 'walnut-kernels-100g.jpg', '8907112000027', '2026-06-01', '2025-06-01', 1, 0, 0, 4.3),

-- More ghee and oil
(240, 'Ananda Desi Ghee', 'ananda-desi-ghee-1kg', 5, 'Ananda', 'Pure desi cow ghee from UP cooperative dairy.', 540.00, 510.00, 12.00, 80, 'tin', '1 kg', 'ghee-ananda-1kg.jpg', '8904180000034', '2026-12-01', '2025-06-01', 1, 0, 0, 4.5),

-- Personal care additions
(241, 'Godrej Cinthol Deo Soap', 'godrej-cinthol-deo-100g', 18, 'Godrej', 'Deodorant soap with long-lasting freshness.', 40.00, 37.00, 18.00, 300, 'bar', '100 g', 'soap-cinthol-100g.jpg', '8901017000060', '2026-12-01', '2024-12-01', 1, 0, 0, 4.3),
(242, 'Rexona Men Deo Stick', 'rexona-men-deo-stick-50g', 25, 'Rexona', '48 hours protection deodorant stick for men.', 145.00, 135.00, 18.00, 100, 'pcs', '50 g', 'rexona-men-50g.jpg', '8901030756230', '2026-12-01', '2024-12-01', 1, 0, 0, 4.3),
(243, 'Dove Women Deo Roll-On', 'dove-women-deo-50ml', 25, 'Dove', 'Gentle moisturizing deodorant for women.', 165.00, 155.00, 18.00, 100, 'bottle', '50 ml', 'dove-deo-50ml.jpg', '8901030769247', '2026-12-01', '2024-12-01', 1, 0, 0, 4.4);

-- ============================================================
-- SEED: Admin User
-- ============================================================
-- Password: Admin@123 (bcrypt hash)
INSERT IGNORE INTO `admins` (`id`, `name`, `email`, `password`, `phone`, `role`) VALUES
(1, 'Rathi Admin', 'admin@rathitraders.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LPVBQXrIhCC', '9876543210', 'superadmin');

-- ============================================================
-- SEED: Coupons
-- ============================================================
INSERT IGNORE INTO `coupons` (`code`, `description`, `discount_type`, `discount_value`, `min_order_amount`, `max_discount`, `valid_from`, `valid_till`) VALUES
('WELCOME10', 'Welcome coupon - 10% off on first order', 'percent', 10.00, 200.00, 100.00, '2025-01-01', '2026-12-31'),
('SAVE50', 'Flat Rs.50 off on orders above Rs.500', 'flat', 50.00, 500.00, NULL, '2025-01-01', '2026-12-31'),
('RATHI20', '20% off on orders above Rs.1000', 'percent', 20.00, 1000.00, 200.00, '2025-01-01', '2026-12-31'),
('FESTIVAL15', '15% off during festival season', 'percent', 15.00, 500.00, 150.00, '2025-01-01', '2026-12-31'),
('NEWUSER', 'New user flat Rs.100 off', 'flat', 100.00, 300.00, NULL, '2025-01-01', '2026-12-31');

-- ============================================================
-- SEED: Offers
-- ============================================================
INSERT IGNORE INTO `offers` (`title`, `description`, `discount_percent`, `category_id`, `valid_from`, `valid_till`) VALUES
('Masala Madness', 'Up to 15% off on all masalas and spices', 15.00, 6, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)),
('Oil Bonanza', 'Save big on cooking oils and ghee', 10.00, 5, NOW(), DATE_ADD(NOW(), INTERVAL 15 DAY)),
('Personal Care Week', '20% off on all personal care products', 20.00, 25, NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY)),
('Bakery Blast', '12% off on biscuits and snacks', 12.00, 12, NOW(), DATE_ADD(NOW(), INTERVAL 20 DAY));
