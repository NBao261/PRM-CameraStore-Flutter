import { Router } from 'express';
import authMiddleware from '../middlewares/auth';
import { applyCoupon } from '../controllers/coupon.controller';

const router = Router();

// User applies a coupon code at checkout
router.post('/apply', authMiddleware, applyCoupon);

export default router;
