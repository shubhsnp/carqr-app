const pool = require('../config/database');
const { generateCarId } = require('../utils/validators');

// Save Car Information
const saveCar = async (req, res) => {
  let connection;
  try {
    const userId = req.user.userId;
    const { carNumber, carModel, customMessage, selectedTemplate, customFields } = req.body;

    if (!carNumber || !carModel) {
      return res.status(422).json({
        success: false,
        error: 'Car number and model are required',
        code: 'INVALID_REQUEST'
      });
    }

    const carId = generateCarId();
    connection = await pool.getConnection();

    await connection.beginTransaction();

    // Check if user already has a car
    const [existingCars] = await connection.execute(
      'SELECT id FROM cars WHERE "userId" = ?',
      [userId]
    );

    if (existingCars.length > 0) {
      // Update existing car
      await connection.execute(
        'UPDATE cars SET "carNumber" = ?, "carModel" = ?, "customMessage" = ?, "selectedTemplate" = ?, "customFields" = ?, "updatedAt" = NOW() WHERE "userId" = ?',
        [carNumber, carModel, customMessage || '', selectedTemplate || 'modern', JSON.stringify(customFields || {}), userId]
      );
    } else {
      // Create new car
      await connection.execute(
        'INSERT INTO cars (id, "userId", "carNumber", "carModel", "customMessage", "selectedTemplate", "customFields", "createdAt") VALUES (?, ?, ?, ?, ?, ?, ?, NOW())',
        [carId, userId, carNumber, carModel, customMessage || '', selectedTemplate || 'modern', JSON.stringify(customFields || {})]
      );
    }

    await connection.commit();

    const [cars] = await connection.execute(
      'SELECT * FROM cars WHERE "userId" = ?',
      [userId]
    );

    const car = cars[0];
    connection.release();

    let parsedCustomFields = {};
    try {
      parsedCustomFields = typeof car.customFields === 'string'
        ? JSON.parse(car.customFields || '{}')
        : (car.customFields || {});
    } catch (e) {
      parsedCustomFields = {};
    }

    return res.status(201).json({
      success: true,
      car: {
        id: car.id,
        userId: car.userId,
        carNumber: car.carNumber,
        carModel: car.carModel,
        customMessage: car.customMessage,
        selectedTemplate: car.selectedTemplate,
        customFields: parsedCustomFields,
        createdAt: car.createdAt
      }
    });
  } catch (error) {
    console.error('saveCar error:', error);
    if (connection) {
      try { await connection.rollback(); } catch (e) {}
      try { connection.release(); } catch (e) {}
    }
    return res.status(500).json({
      success: false,
      error: 'Server error',
      code: 'SERVER_ERROR'
    });
  }
};

// Get User's Car
const getUserCar = async (req, res) => {
  try {
    const userId = req.user.userId;

    const connection = await pool.getConnection();
    const [cars] = await connection.execute(
      'SELECT * FROM cars WHERE "userId" = ?',
      [userId]
    );
    connection.release();

    if (cars.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'No car information found',
        code: 'CAR_NOT_FOUND'
      });
    }

    const car = cars[0];

    return res.json({
      success: true,
      car: {
        id: car.id,
        userId: car.userId,
        carNumber: car.carNumber,
        carModel: car.carModel,
        customMessage: car.customMessage,
        selectedTemplate: car.selectedTemplate,
        customFields: JSON.parse(car.customFields || '{}'),
        createdAt: car.createdAt
      }
    });
  } catch (error) {
    console.error('getUserCar error:', error);
    return res.status(500).json({
      success: false,
      error: 'Server error',
      code: 'SERVER_ERROR'
    });
  }
};

// Get Car by QR Code
const getCarByQR = async (req, res) => {
  try {
    const { qrCode } = req.params;

    const connection = await pool.getConnection();
    const [cars] = await connection.execute(
      'SELECT c.*, u.id as "ownerId", u.email, u.phone FROM cars c JOIN users u ON c."userId" = u.id WHERE c.id = ? OR c."carNumber" = ?',
      [qrCode, qrCode]
    );
    connection.release();

    if (cars.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Car not found',
        code: 'CAR_NOT_FOUND'
      });
    }

    const car = cars[0];

    return res.json({
      success: true,
      car: {
        id: car.id,
        carNumber: car.carNumber,
        carModel: car.carModel,
        customMessage: car.customMessage,
        customFields: JSON.parse(car.customFields || '{}'),
        owner: {
          name: 'Car Owner',
          phone: car.phone,
          email: car.email
        },
        selectedTemplate: car.selectedTemplate
      }
    });
  } catch (error) {
    console.error('getCarByQR error:', error);
    return res.status(500).json({
      success: false,
      error: 'Server error',
      code: 'SERVER_ERROR'
    });
  }
};

// Update Car Information
const updateCar = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { carId } = req.params;
    const { carNumber, carModel, customMessage, selectedTemplate, customFields } = req.body;

    const connection = await pool.getConnection();

    // Verify ownership
    const [cars] = await connection.execute(
      'SELECT * FROM cars WHERE id = ? AND "userId" = ?',
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

    // Update car
    await connection.execute(
      'UPDATE cars SET "carNumber" = ?, "carModel" = ?, "customMessage" = ?, "selectedTemplate" = ?, "customFields" = ?, "updatedAt" = NOW() WHERE id = ?',
      [
        carNumber || cars[0].carNumber,
        carModel || cars[0].carModel,
        customMessage !== undefined ? customMessage : cars[0].customMessage,
        selectedTemplate || cars[0].selectedTemplate,
        customFields ? JSON.stringify(customFields) : cars[0].customFields,
        carId
      ]
    );

    const [updatedCars] = await connection.execute(
      'SELECT * FROM cars WHERE id = ?',
      [carId]
    );
    connection.release();

    const car = updatedCars[0];

    return res.json({
      success: true,
      car: {
        id: car.id,
        carNumber: car.carNumber,
        carModel: car.carModel,
        customMessage: car.customMessage,
        selectedTemplate: car.selectedTemplate,
        customFields: JSON.parse(car.customFields || '{}'),
        updatedAt: car.updatedAt
      }
    });
  } catch (error) {
    console.error('updateCar error:', error);
    return res.status(500).json({
      success: false,
      error: 'Server error',
      code: 'SERVER_ERROR'
    });
  }
};

module.exports = {
  saveCar,
  getUserCar,
  getCarByQR,
  updateCar
};
