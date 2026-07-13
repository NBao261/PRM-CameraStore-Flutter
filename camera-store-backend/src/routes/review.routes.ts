import { Router } from 'express';
import authMiddleware from '../middlewares/auth';
import { createReview, getProductReviews, getOrderReviews } from '../controllers/review.controller';

const router = Router();

// User creates a review (requires auth)
router.post('/', authMiddleware, createReview);

// User: Get reviews the user has made for a specific order
router.get('/order/:orderId', authMiddleware, getOrderReviews);

// Public: Get reviews for a product
router.get('/products/:id/reviews', getProductReviews);

export default router;
