import { Router } from 'express';
import authMiddleware from '../middlewares/auth';
import { createReview, getProductReviews } from '../controllers/review.controller';

const router = Router();

// User creates a review (requires auth)
router.post('/', authMiddleware, createReview);

// Public: Get reviews for a product
router.get('/products/:id/reviews', getProductReviews);

export default router;
