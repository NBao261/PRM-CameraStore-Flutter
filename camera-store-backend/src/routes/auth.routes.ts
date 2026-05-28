import { Router } from 'express';
import { register, login, getProfile, updateProfile } from '../controllers/auth.controller';
import authMiddleware from '../middlewares/auth';
import validate from '../middlewares/validate';
import { registerValidator, loginValidator, updateProfileValidator } from '../validators/auth.validator';

const router = Router();

router.post('/register', registerValidator, validate, register);
router.post('/login', loginValidator, validate, login);
router.get('/profile', authMiddleware, getProfile);
router.put('/profile', authMiddleware, updateProfileValidator, validate, updateProfile);

export default router;
