const express = require('express');
const router = express.Router();
const { getCart, addToCart, updateCart, removeFromCart, clearCart } = require('../controllers/cartController');
const auth = require('../middleware/auth');

router.get('/', auth, getCart);
router.post('/add', auth, addToCart);
router.put('/:id', auth, updateCart);
router.delete('/clear', auth, clearCart);
router.delete('/:id', auth, removeFromCart);

module.exports = router;
