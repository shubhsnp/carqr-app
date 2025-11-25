const pool = require('../config/database');
const crypto = require('crypto');
const Razorpay = require('razorpay');
const { generatePaymentId } = require('../utils/validators');

const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET
});

// Create Razorpay Payment Order
const createPayment = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { amount = 49900, currency = 'INR', planDuration = 365 } = req.body;

    // Amount must be in paise (multiply by 100 if in rupees)
    const finalAmount = amount; // Assuming already in paise

    const options = {
      amount: finalAmount,
      currency,
      receipt: `receipt_${userId}_${Date.now()}`,
      notes: {
        userId,
        planDuration
      }
    };

    const order = await razorpay.orders.create(options);

    const connection = await pool.getConnection();
    
    // Store payment record
    const paymentId = generatePaymentId();
    await connection.execute(
      'INSERT INTO payments (id, userId, orderId, amount, currency, status, planDuration, createdAt) VALUES (?, ?, ?, ?, ?, ?, ?, NOW())',
      [paymentId, userId, order.id, amount, currency, 'pending', planDuration]
    );

    connection.release();

    return res.json({
      success: true,
      payment: {
        id: paymentId,
        orderId: order.id,
        amount,
        currency,
        key: process.env.RAZORPAY_KEY_ID,
        customerId: userId
      }
    });
  } catch (error) {
    console.error('createPayment error:', error);
    return res.status(500).json({
      success: false,
      error: 'Failed to create payment',
      code: 'PAYMENT_ERROR'
    });
  }
};

// Verify Razorpay Payment
const verifyPayment = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { paymentId, orderId, signature } = req.body;

    if (!paymentId || !orderId || !signature) {
      return res.status(422).json({
        success: false,
        error: 'Missing payment details',
        code: 'INVALID_REQUEST'
      });
    }

    // Verify signature
    const body = orderId + '|' + paymentId;
    const expectedSignature = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
      .update(body)
      .digest('hex');

    if (expectedSignature !== signature) {
      return res.status(400).json({
        success: false,
        error: 'Payment verification failed',
        code: 'INVALID_SIGNATURE'
      });
    }

    const connection = await pool.getConnection();

    try {
      await connection.beginTransaction();

      // Get payment record
      const [payments] = await connection.execute(
        'SELECT * FROM payments WHERE userId = ? AND orderId = ?',
        [userId, orderId]
      );

      if (payments.length === 0) {
        await connection.rollback();
        connection.release();
        return res.status(404).json({
          success: false,
          error: 'Payment not found',
          code: 'PAYMENT_NOT_FOUND'
        });
      }

      const payment = payments[0];
      const planDuration = payment.planDuration;

      // Update payment status
      await connection.execute(
        'UPDATE payments SET status = ?, verifiedAt = NOW() WHERE id = ?',
        ['completed', payment.id]
      );

      // Calculate premium expiry date
      const expiryDate = new Date();
      expiryDate.setDate(expiryDate.getDate() + planDuration);

      // Upgrade user to premium
      await connection.execute(
        'UPDATE users SET isPremium = ?, plan = ?, premiumExpiryDate = ?, updatedAt = NOW() WHERE id = ?',
        [true, 'premium', expiryDate, userId]
      );

      await connection.commit();

      const [updatedUsers] = await connection.execute(
        'SELECT * FROM users WHERE id = ?',
        [userId]
      );

      connection.release();

      const user = updatedUsers[0];

      return res.json({
        success: true,
        payment: {
          id: payment.id,
          userId,
          status: 'completed',
          amount: payment.amount,
          planDuration,
          premiumExpiryDate: expiryDate,
          verifiedAt: new Date()
        }
      });
    } catch (error) {
      await connection.rollback();
      connection.release();
      throw error;
    }
  } catch (error) {
    console.error('verifyPayment error:', error);
    return res.status(500).json({
      success: false,
      error: 'Server error',
      code: 'SERVER_ERROR'
    });
  }
};

module.exports = {
  createPayment,
  verifyPayment
};
