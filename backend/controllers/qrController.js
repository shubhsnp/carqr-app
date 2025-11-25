const pool = require('../config/database');
const QRCode = require('qrcode');
const { generateQRId } = require('../utils/validators');

// Generate QR Code
const generateQR = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { carId, size = '3x3', format = 'pdf' } = req.body;

    if (!carId) {
      return res.status(422).json({
        success: false,
        error: 'carId is required',
        code: 'INVALID_REQUEST'
      });
    }

    const validSizes = ['3x3', '4x4'];
    const validFormats = ['pdf', 'svg', 'png'];

    if (!validSizes.includes(size) || !validFormats.includes(format)) {
      return res.status(422).json({
        success: false,
        error: 'Invalid size or format',
        code: 'INVALID_REQUEST'
      });
    }

    const connection = await pool.getConnection();

    // Verify car ownership
    const [cars] = await connection.execute(
      'SELECT * FROM cars WHERE id = ? AND userId = ?',
      [carId, userId]
    );

    if (cars.length === 0) {
      connection.release();
      return res.status(404).json({
        success: false,
        error: 'Car not found',
        code: 'CAR_NOT_FOUND'
      });
    }

    const qrId = generateQRId();
    const qrValue = `https://carqr.app/cars/${carId}`;

    // Save QR to database
    await connection.execute(
      'INSERT INTO qr_codes (id, carId, size, format, qrValue, createdAt) VALUES (?, ?, ?, ?, ?, NOW())',
      [qrId, carId, size, format, qrValue]
    );

    connection.release();

    // Generate QR code data URL
    let qrDataUrl;
    try {
      qrDataUrl = await QRCode.toDataURL(qrValue, {
        width: format === 'pdf' ? 500 : 300,
        margin: 10,
        color: {
          dark: '#000000',
          light: '#FFFFFF'
        }
      });
    } catch (error) {
      console.error('QR generation error:', error);
      qrDataUrl = null;
    }

    return res.status(200).json({
      success: true,
      qr: {
        id: qrId,
        carId,
        size,
        format,
        qrValue,
        qrDataUrl, // Base64 encoded image
        downloadUrl: `https://cdn.carqr.app/qr/${qrId}.${format}`,
        createdAt: new Date()
      }
    });
  } catch (error) {
    console.error('generateQR error:', error);
    return res.status(500).json({
      success: false,
      error: 'Server error',
      code: 'SERVER_ERROR'
    });
  }
};

// Get QR Code Data
const getQRCode = async (req, res) => {
  try {
    const { qrId } = req.params;

    const connection = await pool.getConnection();
    const [qrs] = await connection.execute(
      'SELECT * FROM qr_codes WHERE id = ?',
      [qrId]
    );
    connection.release();

    if (qrs.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'QR code not found',
        code: 'QR_NOT_FOUND'
      });
    }

    const qr = qrs[0];

    return res.json({
      success: true,
      qr: {
        id: qr.id,
        carId: qr.carId,
        size: qr.size,
        format: qr.format,
        qrValue: qr.qrValue,
        downloadUrl: `https://cdn.carqr.app/qr/${qr.id}.${qr.format}`,
        createdAt: qr.createdAt
      }
    });
  } catch (error) {
    console.error('getQRCode error:', error);
    return res.status(500).json({
      success: false,
      error: 'Server error',
      code: 'SERVER_ERROR'
    });
  }
};

module.exports = {
  generateQR,
  getQRCode
};
