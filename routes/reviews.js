const express = require('express');
const router = express.Router();
const { getReviews, addReview, adminGetReviews, toggleReview } = require('../controllers/reviewController');
const auth = require('../middleware/auth');
const adminAuth = require('../middleware/adminAuth');

router.get('/product/:product_id', getReviews);
router.post('/', auth, addReview);
router.get('/admin/all', adminAuth, adminGetReviews);
router.put('/admin/:id/toggle', adminAuth, toggleReview);

module.exports = router;
