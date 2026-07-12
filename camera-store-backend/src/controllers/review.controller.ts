import { Response, NextFunction } from 'express';
import Review from '../models/Review';
import Order from '../models/Order';
import Product from '../models/Product';
import { IAuthRequest } from '../types';
import { ValidationError, NotFoundError, ConflictError } from '../utils/errors';

/**
 * POST /api/reviews
 * User creates a review for a product in a delivered order.
 */
export const createReview = async (req: IAuthRequest, res: Response, next: NextFunction) => {
  try {
    const userId = req.user!.id;
    const { productId, orderId, rating, comment } = req.body;

    if (!productId || !orderId) {
      throw new ValidationError('Thiếu thông tin sản phẩm hoặc đơn hàng');
    }

    if (!rating || rating < 1 || rating > 5) {
      throw new ValidationError('Đánh giá phải từ 1 đến 5 sao');
    }

    // Check order exists, belongs to user, and is delivered
    const order = await Order.findOne({ _id: orderId, user: userId });

    if (!order) {
      throw new NotFoundError('Không tìm thấy đơn hàng');
    }

    if (order.status !== 'delivered') {
      throw new ValidationError('Chỉ có thể đánh giá khi đơn hàng đã được giao');
    }

    // Check product is in this order
    const productInOrder = order.items.some(
      (item: any) => String(item.product) === productId
    );

    if (!productInOrder) {
      throw new ValidationError('Sản phẩm không có trong đơn hàng này');
    }

    // Check duplicate review
    const existingReview = await Review.findOne({
      user: userId,
      product: productId,
      order: orderId,
    });

    if (existingReview) {
      throw new ConflictError('Bạn đã đánh giá sản phẩm này trong đơn hàng này rồi');
    }

    // Create review
    const review = await Review.create({
      user: userId,
      product: productId,
      order: orderId,
      rating: Math.round(rating),
      comment: comment || '',
    });

    // Recalculate product average rating
    const reviews = await Review.find({ product: productId });
    const totalRating = reviews.reduce((sum, r) => sum + r.rating, 0);
    const averageRating = Math.round((totalRating / reviews.length) * 10) / 10;

    await Product.updateOne(
      { _id: productId },
      { averageRating, reviewCount: reviews.length }
    );

    res.status(201).json({
      success: true,
      data: review,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/products/:id/reviews
 * Public: Get all reviews for a product.
 */
export const getProductReviews = async (req: IAuthRequest, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;

    const reviews = await Review.find({ product: id })
      .populate('user', 'name avatar')
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      data: reviews,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * GET /api/reviews/order/:orderId
 * Returns reviews the current user has made for a specific order.
 */
export const getOrderReviews = async (req: IAuthRequest, res: Response, next: NextFunction) => {
  try {
    const userId = req.user!.id;
    const { orderId } = req.params;

    const reviews = await Review.find({ user: userId, order: orderId })
      .select('product rating comment createdAt')
      .lean();

    res.json({
      success: true,
      data: reviews,
    });
  } catch (error) {
    next(error);
  }
};
