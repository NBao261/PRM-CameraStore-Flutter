import { Router } from 'express';
import { createOrder, getOrders, getOrderById, cancelOrder, confirmReceived } from '../controllers/order.controller';
import authMiddleware from '../middlewares/auth';
import validate from '../middlewares/validate';
import { checkoutValidator } from '../validators/order.validator';

const router = Router();

router.use(authMiddleware);

router.post('/', checkoutValidator, validate, createOrder);
router.get('/', getOrders);
router.get('/:id', getOrderById);
router.put('/:id/cancel', cancelOrder);
router.put('/:id/confirm-received', confirmReceived);

export default router;
