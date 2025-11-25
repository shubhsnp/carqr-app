const validatePhone = (phone) => {
  // Indian phone format: 10 digits
  const phoneRegex = /^[6-9]\d{9}$/;
  return phoneRegex.test(phone);
};

const validateEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

const validateCarNumber = (carNumber) => {
  // Indian car format: MH01AB1234
  const carRegex = /^[A-Z]{2}\d{2}[A-Z]{2}\d{4}$/;
  return carRegex.test(carNumber);
};

const generateOTP = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

const generateUserId = () => {
  return 'user_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
};

const generateCarId = () => {
  return 'car_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
};

const generateQRId = () => {
  return 'qr_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
};

const generateScanId = () => {
  return 'scan_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
};

const generatePaymentId = () => {
  return 'pay_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
};

module.exports = {
  validatePhone,
  validateEmail,
  validateCarNumber,
  generateOTP,
  generateUserId,
  generateCarId,
  generateQRId,
  generateScanId,
  generatePaymentId
};
