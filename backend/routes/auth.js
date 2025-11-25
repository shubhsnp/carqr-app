const express = require('express');
const { requestOTP, verifyOTP, emailLogin, logout, refreshToken } = require('../controllers/authController');

const router = express.Router();

router.post('/otp/request', requestOTP);
router.post('/otp/verify', verifyOTP);
router.post('/email/login', emailLogin);
router.post('/logout', logout);
router.post('/refresh', refreshToken);

module.exports = router;
