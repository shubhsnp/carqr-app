const express = require('express');
const { verifyToken } = require('../middleware/auth');
const { createPayment, verifyPayment } = require('../controllers/paymentController');

const router = express.Router();

router.post('/razorpay/create', verifyToken, createPayment);
router.post('/razorpay/verify', verifyToken, verifyPayment);

module.exports = router;
