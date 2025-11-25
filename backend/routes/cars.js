const express = require('express');
const { verifyToken } = require('../middleware/auth');
const { saveCar, getUserCar, getCarByQR, updateCar } = require('../controllers/carController');

const router = express.Router();

router.post('/', verifyToken, saveCar);
router.get('/me', verifyToken, getUserCar);
router.get('/qr/:qrCode', getCarByQR); // Public endpoint
router.put('/:carId', verifyToken, updateCar);

module.exports = router;
