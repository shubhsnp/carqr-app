const pool = require('../config/database');
const redis = require('../config/redis');
const bcrypt = require('bcryptjs');
const { generateToken, generateRefreshToken } = require('../middleware/auth');
const { validatePhone, validateEmail, generateOTP, generateUserId } = require('../utils/validators');

// Request OTP
const requestOTP = async (req, res) => {
  try {
    const { phone } = req.body;

    if (!phone || !validatePhone(phone)) {
      return res.status(422).json({
        success: false,
        error: 'Invalid phone number format',
        code: 'INVALID_PHONE'
      });
    }

    const otp = generateOTP();
    const sessionId = 'session_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);

    // Store OTP in Redis with 5-minute expiry
    await redis.setEx(`otp:${phone}`, 300, otp);
    await redis.setEx(`session:${sessionId}`, 300, phone);

    // In production, send OTP via Twilio SMS
    console.log(`[DEV] OTP for ${phone}: ${otp}`);

    return res.json({
      success: true,
      message: 'OTP sent to your phone',
      expiresIn: 300,
      sessionId
    });
  } catch (error) {
    console.error('requestOTP error:', error);
    return res.status(500).json({
      success: false,
      error: 'Server error',
      code: 'SERVER_ERROR'
    });
  }
};

// Verify OTP & Register/Login
const verifyOTP = async (req, res) => {
  try {
    const { phone, otp, email, sessionId } = req.body;

    if (!phone || !otp || !sessionId) {
      return res.status(422).json({
        success: false,
        error: 'Missing required fields',
        code: 'INVALID_REQUEST'
      });
    }

    // Verify session
    const sessionPhone = await redis.get(`session:${sessionId}`);
    if (!sessionPhone || sessionPhone !== phone) {
      return res.status(401).json({
        success: false,
        error: 'Invalid session',
        code: 'INVALID_SESSION'
      });
    }

    // Verify OTP
    const storedOTP = await redis.get(`otp:${phone}`);
    if (!storedOTP || storedOTP !== otp) {
      return res.status(401).json({
        success: false,
        error: 'Invalid or expired OTP',
        code: 'INVALID_OTP'
      });
    }

    // Generate email if not provided
    const userEmail = email && validateEmail(email) ? email : `user_${phone}@carqr.app`;

    // Check if user exists
    const connection = await pool.getConnection();
    const [existingUser] = await connection.execute(
      'SELECT * FROM users WHERE phone = ?',
      [phone]
    );

    let user;
    if (existingUser.length > 0) {
      // User exists - update email if provided
      if (email && validateEmail(email)) {
        await connection.execute(
          'UPDATE users SET email = ? WHERE phone = ?',
          [userEmail, phone]
        );
      }
      user = existingUser[0];
    } else {
      // Create new user
      const userId = generateUserId();
      await connection.execute(
        'INSERT INTO users (id, email, phone, isPremium, plan, hasCarInfo, selectedTemplate, createdAt) VALUES (?, ?, ?, ?, ?, ?, ?, NOW())',
        [userId, userEmail, phone, false, 'basic', false, 'modern']
      );
      
      user = {
        id: userId,
        email: userEmail,
        phone,
        isPremium: false,
        plan: 'basic',
        hasCarInfo: false,
        selectedTemplate: 'modern',
        createdAt: new Date()
      };
    }

    connection.release();

    // Clear OTP and session
    await redis.del(`otp:${phone}`);
    await redis.del(`session:${sessionId}`);

    // Generate tokens
    const token = generateToken(user.id, user.email);
    const refreshToken = generateRefreshToken(user.id);

    return res.json({
      success: true,
      user: {
        id: user.id,
        email: user.email,
        phone: user.phone,
        isPremium: user.isPremium,
        plan: user.plan,
        hasCarInfo: user.hasCarInfo,
        selectedTemplate: user.selectedTemplate,
        premiumExpiryDate: user.premiumExpiryDate,
        createdAt: user.createdAt
      },
      token,
      refreshToken
    });
  } catch (error) {
    console.error('verifyOTP error:', error);
    return res.status(500).json({
      success: false,
      error: 'Server error',
      code: 'SERVER_ERROR'
    });
  }
};

// Email Login
const emailLogin = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email || !validateEmail(email)) {
      return res.status(422).json({
        success: false,
        error: 'Invalid email format',
        code: 'INVALID_EMAIL'
      });
    }

    const connection = await pool.getConnection();
    const [users] = await connection.execute(
      'SELECT * FROM users WHERE email = ?',
      [email]
    );
    connection.release();

    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'User not found',
        code: 'USER_NOT_FOUND'
      });
    }

    const user = users[0];
    const token = generateToken(user.id, user.email);
    const refreshToken = generateRefreshToken(user.id);

    return res.json({
      success: true,
      user: {
        id: user.id,
        email: user.email,
        phone: user.phone,
        isPremium: user.isPremium,
        plan: user.plan,
        hasCarInfo: user.hasCarInfo,
        selectedTemplate: user.selectedTemplate,
        premiumExpiryDate: user.premiumExpiryDate,
        createdAt: user.createdAt
      },
      token,
      refreshToken
    });
  } catch (error) {
    console.error('emailLogin error:', error);
    return res.status(500).json({
      success: false,
      error: 'Server error',
      code: 'SERVER_ERROR'
    });
  }
};

// Logout
const logout = async (req, res) => {
  try {
    // In production, invalidate token in blacklist
    return res.json({
      success: true,
      message: 'Logged out successfully'
    });
  } catch (error) {
    console.error('logout error:', error);
    return res.status(500).json({
      success: false,
      error: 'Server error',
      code: 'SERVER_ERROR'
    });
  }
};

// Refresh Token
const refreshToken = async (req, res) => {
  try {
    const { refreshToken: token } = req.body;

    if (!token) {
      return res.status(401).json({
        success: false,
        error: 'No refresh token provided',
        code: 'UNAUTHORIZED'
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const connection = await pool.getConnection();
    const [users] = await connection.execute(
      'SELECT * FROM users WHERE id = ?',
      [decoded.userId]
    );
    connection.release();

    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'User not found',
        code: 'USER_NOT_FOUND'
      });
    }

    const user = users[0];
    const newToken = generateToken(user.id, user.email);
    const newRefreshToken = generateRefreshToken(user.id);

    return res.json({
      success: true,
      token: newToken,
      refreshToken: newRefreshToken
    });
  } catch (error) {
    console.error('refreshToken error:', error);
    return res.status(401).json({
      success: false,
      error: 'Invalid refresh token',
      code: 'UNAUTHORIZED'
    });
  }
};

module.exports = {
  requestOTP,
  verifyOTP,
  emailLogin,
  logout,
  refreshToken
};
