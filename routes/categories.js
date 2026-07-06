const express = require('express');
const router = express.Router();
const { getCategories, getCategory, createCategory, updateCategory, deleteCategory } = require('../controllers/categoryController');
const adminAuth = require('../middleware/adminAuth');
const upload = require('../middleware/upload');

router.get('/', getCategories);
router.get('/:slug', getCategory);
router.post('/', adminAuth, upload.single('image'), createCategory);
router.put('/:id', adminAuth, upload.single('image'), updateCategory);
router.delete('/:id', adminAuth, deleteCategory);

module.exports = router;
