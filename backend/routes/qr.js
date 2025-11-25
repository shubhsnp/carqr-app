const express = require('express');
const { verifyToken } = require('../middleware/auth');
const { generateQR, getQRCode } = require('../controllers/qrController');

const router = express.Router();

router.post('/generate', verifyToken, generateQR);
router.get('/:qrId', getQRCode);

module.exports = router;
