const express = require('express');
const { verifyToken } = require('../middleware/auth');
const { getUserProfile, updateTemplate, upgradeToPremium } = require('../controllers/userController');

const router = express.Router();

router.get('/me', verifyToken, getUserProfile);
router.put('/me/template', verifyToken, updateTemplate);
router.post('/me/upgrade-premium', verifyToken, upgradeToPremium);

module.exports = router;
