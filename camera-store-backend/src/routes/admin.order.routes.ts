import { Router } from 'express';
import { getAllOrders, updateOrderStatus, getDashboardStats } from '../controllers/admin.order.controller';
import authMiddleware from '../middlewares/auth';
import adminAuth from '../middlewares/adminAuth';

const router = Router();

router.use(authMiddleware, adminAuth);

router.get('/dashboard', getDashboardStats);
router.get('/', getAllOrders);
router.put('/:id/status', updateOrderStatus);

export default router;
