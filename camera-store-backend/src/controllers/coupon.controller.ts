import { Response, NextFunction } from 'express';
import Coupon from '../models/Coupon';
import { IAuthRequest } from '../types';
import { ValidationError, NotFoundError } from '../utils/errors';

/**
 * POST /api/coupons/apply
 * User applies a coupon code. Returns the discount amount.
 */
export const applyCoupon = async (req: IAuthRequest, res: Response, next: NextFunction) => {
  try {
    const { code, subtotal } = req.body;

    if (!code) {
      throw new ValidationError('Vui lòng nhập mã khuyến mãi');
    }

    if (!subtotal || subtotal <= 0) {
      throw new ValidationError('Tổng tiền đơn hàng không hợp lệ');
    }

    const coupon = await Coupon.findOne({ code: code.toUpperCase(), isActive: true });

    if (!coupon) {
      throw new NotFoundError('Mã khuyến mãi không tồn tại hoặc đã bị vô hiệu hóa');
    }

    // Check expiration
    if (new Date() > coupon.expiresAt) {
      throw new ValidationError('Mã khuyến mãi đã hết hạn');
    }

    // Check usage limit
    if (coupon.usedCount >= coupon.usageLimit) {
      throw new ValidationError('Mã khuyến mãi đã hết lượt sử dụng');
    }

    // Check minimum order amount
    if (subtotal < coupon.minOrderAmount) {
      throw new ValidationError(
        `Đơn hàng tối thiểu ${coupon.minOrderAmount.toLocaleString('vi-VN')}đ để áp dụng mã này`
      );
    }

    // Calculate discount
    let discountAmount: number;
    if (coupon.type === 'percent') {
      discountAmount = Math.round((subtotal * coupon.value) / 100);
      if (coupon.maxDiscount && discountAmount > coupon.maxDiscount) {
        discountAmount = coupon.maxDiscount;
      }
    } else {
      // fixed
      discountAmount = coupon.value;
    }

    // Discount cannot exceed subtotal
    if (discountAmount > subtotal) {
      discountAmount = subtotal;
    }

    res.json({
      success: true,
      data: {
        code: coupon.code,
        type: coupon.type,
        value: coupon.value,
        discountAmount,
        maxDiscount: coupon.maxDiscount,
      },
    });
  } catch (error) {
    next(error);
  }
};
