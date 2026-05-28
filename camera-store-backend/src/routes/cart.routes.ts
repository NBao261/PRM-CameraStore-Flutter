import { Router } from 'express';
import { body, param } from 'express-validator';
import { getCart, addToCart, updateCartItem, removeFromCart } from '../controllers/cart.controller';
import authMiddleware from '../middlewares/auth';
import validate from '../middlewares/validate';

const router = Router();

router.use(authMiddleware);

// GET /api/cart - Lấy giỏ hàng
router.get('/', getCart);

// POST /api/cart - Thêm sản phẩm vào giỏ
router.post(
  '/',
  [
    body('productId')
      .notEmpty().withMessage('productId là bắt buộc')
      .isMongoId().withMessage('productId không hợp lệ'),
    body('quantity')
      .optional()
      .isInt({ min: 1 }).withMessage('Số lượng phải là số nguyên >= 1'),
  ],
  validate,
  addToCart
);

// PUT /api/cart/:id - Cập nhật số lượng
router.put(
  '/:id',
  [
    param('id')
      .isMongoId().withMessage('Product ID không hợp lệ'),
    body('quantity')
      .notEmpty().withMessage('quantity là bắt buộc')
      .isInt({ min: 0 }).withMessage('Số lượng phải là số nguyên >= 0'),
  ],
  validate,
  updateCartItem
);

// DELETE /api/cart/:id - Xóa sản phẩm khỏi giỏ
router.delete(
  '/:id',
  [
    param('id')
      .isMongoId().withMessage('Product ID không hợp lệ'),
  ],
  validate,
  removeFromCart
);

export default router;
