import { Router } from 'express';
import { register, login, getProfile, updateProfile, verifyOtp, changePassword } from '../controllers/auth.controller';
import authMiddleware from '../middlewares/auth';
import validate from '../middlewares/validate';
import { registerValidator, loginValidator, updateProfileValidator, verifyOtpValidator, changePasswordValidator } from '../validators/auth.validator';

const router = Router();

router.post('/register', registerValidator, validate, register);
router.post('/verify-otp', verifyOtpValidator, validate, verifyOtp);
router.post('/login', loginValidator, validate, login);
router.get('/profile', authMiddleware, getProfile);
router.put('/profile', authMiddleware, updateProfileValidator, validate, updateProfile);
router.put('/change-password', authMiddleware, changePasswordValidator, validate, changePassword);

export default router;
