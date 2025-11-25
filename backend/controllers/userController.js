const pool = require('../config/database');

// Get User Profile
const getUserProfile = async (req, res) => {
  try {
    const userId = req.user.userId;

    const connection = await pool.getConnection();
    const [users] = await connection.execute(
      'SELECT * FROM users WHERE id = ?',
      [userId]
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
      }
    });
  } catch (error) {
    console.error('getUserProfile error:', error);
    return res.status(500).json({
      success: false,
      error: 'Server error',
      code: 'SERVER_ERROR'
    });
  }
};

// Update User Template
const updateTemplate = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { templateId } = req.body;

    const validTemplates = ['modern', 'classic', 'minimal'];
    if (!templateId || !validTemplates.includes(templateId)) {
      return res.status(422).json({
        success: false,
        error: 'Invalid template ID',
        code: 'INVALID_TEMPLATE'
      });
    }

    const connection = await pool.getConnection();
    await connection.execute(
      'UPDATE users SET selectedTemplate = ?, updatedAt = NOW() WHERE id = ?',
      [templateId, userId]
    );

    const [updatedUsers] = await connection.execute(
      'SELECT id, selectedTemplate, updatedAt FROM users WHERE id = ?',
      [userId]
    );
    connection.release();

    if (updatedUsers.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'User not found',
        code: 'USER_NOT_FOUND'
      });
    }

    return res.json({
      success: true,
      user: updatedUsers[0]
    });
  } catch (error) {
    console.error('updateTemplate error:', error);
    return res.status(500).json({
      success: false,
      error: 'Server error',
      code: 'SERVER_ERROR'
    });
  }
};

// Upgrade to Premium
const upgradeToPremium = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { paymentId, planDuration = 365, isTest } = req.body;

    const connection = await pool.getConnection();

    // Calculate expiry date
    const expiryDate = new Date();
    expiryDate.setDate(expiryDate.getDate() + planDuration);

    // Update user
    await connection.execute(
      'UPDATE users SET isPremium = ?, plan = ?, premiumExpiryDate = ?, updatedAt = NOW() WHERE id = ?',
      [true, 'premium', expiryDate, userId]
    );

    const [updatedUsers] = await connection.execute(
      'SELECT id, isPremium, plan, premiumExpiryDate, updatedAt FROM users WHERE id = ?',
      [userId]
    );
    connection.release();

    return res.json({
      success: true,
      user: updatedUsers[0]
    });
  } catch (error) {
    console.error('upgradeToPremium error:', error);
    return res.status(500).json({
      success: false,
      error: 'Server error',
      code: 'SERVER_ERROR'
    });
  }
};

module.exports = {
  getUserProfile,
  updateTemplate,
  upgradeToPremium
};
