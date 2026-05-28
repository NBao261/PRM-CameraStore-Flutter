import { Response, NextFunction } from 'express';
import { cartService } from '../services/cart.service';
import { ApiResponse } from '../utils/response';
import { IAuthRequest } from '../types';

// GET /api/cart
export const getCart = async (req: IAuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const data = await cartService.getCart(req.user!.id);
    ApiResponse.success(res, data);
  } catch (error) {
    next(error);
  }
};

// POST /api/cart
export const addToCart = async (req: IAuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const data = await cartService.addToCart(req.user!.id, req.body.productId, req.body.quantity);
    ApiResponse.success(res, data, 'Đã thêm vào giỏ hàng');
  } catch (error) {
    next(error);
  }
};

// PUT /api/cart/:id
export const updateCartItem = async (req: IAuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const data = await cartService.updateCartItem(req.user!.id, req.params.id as string, req.body.quantity);
    ApiResponse.success(res, data, 'Đã cập nhật giỏ hàng');
  } catch (error) {
    next(error);
  }
};

// DELETE /api/cart/:id
export const removeFromCart = async (req: IAuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const data = await cartService.removeFromCart(req.user!.id, req.params.id as string);
    ApiResponse.success(res, data, 'Đã xóa khỏi giỏ hàng');
  } catch (error) {
    next(error);
  }
};
