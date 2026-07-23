import { Router } from 'express';
import { register, login, getProfile, updateProfile, verifyOtp, changePassword, forgotPassword, resetPassword } from '../controllers/auth.controller';
import authMiddleware from '../middlewares/auth';
import validate from '../middlewares/validate';
import { registerValidator, loginValidator, updateProfileValidator, verifyOtpValidator, changePasswordValidator, forgotPasswordValidator, resetPasswordValidator } from '../validators/auth.validator';

const router = Router();

router.post('/register', registerValidator, validate, register);
router.post('/verify-otp', verifyOtpValidator, validate, verifyOtp);
router.post('/login', loginValidator, validate, login);
router.get('/profile', authMiddleware, getProfile);
router.put('/profile', authMiddleware, updateProfileValidator, validate, updateProfile);
router.put('/change-password', authMiddleware, changePasswordValidator, validate, changePassword);
router.post('/forgot-password', forgotPasswordValidator, validate, forgotPassword);
router.post('/reset-password', resetPasswordValidator, validate, resetPassword);

export default router;
