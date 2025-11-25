const pool = require('../config/database');
const { generateScanId } = require('../utils/validators');

// Log Scan Activity
const logScan = async (req, res) => {
  try {
    const { carId, scannerPhone, scannerEmail, notes } = req.body;

    if (!carId || !scannerPhone || !scannerEmail) {
      return res.status(422).json({
        success: false,
        error: 'Missing required fields: carId, scannerPhone, scannerEmail',
        code: 'INVALID_REQUEST'
      });
    }

    const scanId = generateScanId();
    const connection = await pool.getConnection();

    await connection.execute(
      'INSERT INTO scans (id, carId, scannerPhone, scannerEmail, notes, timestamp) VALUES (?, ?, ?, ?, ?, NOW())',
      [scanId, carId, scannerPhone, scannerEmail, notes || null]
    );

    connection.release();

    return res.status(201).json({
      success: true,
      activity: {
        id: scanId,
        carId,
        scannerPhone,
        scannerEmail,
        timestamp: new Date(),
        notes: notes || null
      }
    });
  } catch (error) {
    console.error('logScan error:', error);
    return res.status(500).json({
      success: false,
      error: 'Server error',
      code: 'SERVER_ERROR'
    });
  }
};

// Get Scan History for a Car
const getScanHistory = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { carId } = req.params;
    const { limit = 50, offset = 0, from, to } = req.query;

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

    // Build query
    let query = 'SELECT * FROM scans WHERE carId = ?';
    let params = [carId];

    if (from) {
      query += ' AND timestamp >= ?';
      params.push(new Date(from));
    }

    if (to) {
      query += ' AND timestamp <= ?';
      params.push(new Date(to));
    }

    query += ' ORDER BY timestamp DESC LIMIT ? OFFSET ?';
    params.push(parseInt(limit), parseInt(offset));

    const [scans] = await connection.execute(query, params);

    // Get total count
    let countQuery = 'SELECT COUNT(*) as total FROM scans WHERE carId = ?';
    let countParams = [carId];

    if (from) {
      countQuery += ' AND timestamp >= ?';
      countParams.push(new Date(from));
    }

    if (to) {
      countQuery += ' AND timestamp <= ?';
      countParams.push(new Date(to));
    }

    const [totalResult] = await connection.execute(countQuery, countParams);
    connection.release();

    return res.json({
      success: true,
      scans: scans.map(scan => ({
        id: scan.id,
        carId: scan.carId,
        scannerPhone: scan.scannerPhone,
        scannerEmail: scan.scannerEmail,
        timestamp: scan.timestamp,
        notes: scan.notes
      })),
      pagination: {
        total: totalResult[0].total,
        limit: parseInt(limit),
        offset: parseInt(offset)
      }
    });
  } catch (error) {
    console.error('getScanHistory error:', error);
    return res.status(500).json({
      success: false,
      error: 'Server error',
      code: 'SERVER_ERROR'
    });
  }
};

module.exports = {
  logScan,
  getScanHistory
};
