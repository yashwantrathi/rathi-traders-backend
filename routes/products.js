const express = require('express');
const router = express.Router();
const { getProducts, getProduct, getFeaturedProducts, getBestsellers, getBrands, searchSuggestions, createProduct, updateProduct, deleteProduct } = require('../controllers/productController');
const auth = require('../middleware/auth');
const adminAuth = require('../middleware/adminAuth');
const upload = require('../middleware/upload');

router.get('/', getProducts);
router.get('/featured', getFeaturedProducts);
router.get('/bestsellers', getBestsellers);
router.get('/brands', getBrands);
router.get('/search', searchSuggestions);
router.get('/:id', getProduct);
router.post('/', adminAuth, upload.single('image'), createProduct);
router.put('/:id', adminAuth, upload.single('image'), updateProduct);
router.delete('/:id', adminAuth, deleteProduct);

module.exports = router;
