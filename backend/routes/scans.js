const express = require('express');
const { logScan, getScanHistory } = require('../controllers/scanController');
const { verifyToken } = require('../middleware/auth');

const router = express.Router();

router.post('/', logScan); // Public endpoint for logging scans
router.get('/:carId/scans', verifyToken, getScanHistory);

module.exports = router;
