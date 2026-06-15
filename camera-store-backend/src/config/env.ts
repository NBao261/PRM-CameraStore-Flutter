import dotenv from 'dotenv';

dotenv.config();

export default {
  port: parseInt(process.env.PORT || '5000', 10),
  mongodbUri: process.env.MONGODB_URI || 'mongodb://localhost:27017/camera_store',
  jwtSecret: process.env.JWT_SECRET || 'default_secret',
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '7d',
  smtpUser: process.env.SMTP_USER || '',
  smtpPass: process.env.SMTP_PASS || '',
  momo: {
    partnerCode: process.env.MOMO_PARTNER_CODE || '',
    accessKey: process.env.MOMO_ACCESS_KEY || '',
    secretKey: process.env.MOMO_SECRET_KEY || '',
    apiUrl: process.env.MOMO_API_URL || 'https://test-payment.momo.vn',
    returnUrl: process.env.MOMO_RETURN_URL || 'https://camera-store.local/payment-result',
    ipnUrl: process.env.MOMO_IPN_URL || 'https://camera-store.local/api/payment/momo/ipn',
  }
};
