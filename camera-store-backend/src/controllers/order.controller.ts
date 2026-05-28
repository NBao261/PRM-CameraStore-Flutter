import { Response, NextFunction } from 'express';
import { orderService } from '../services/order.service';
import { ApiResponse } from '../utils/response';
import { IAuthRequest } from '../types';

// POST /api/orders
export const createOrder = async (req: IAuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const data = await orderService.createOrder(req.user!.id, req.body);
    ApiResponse.created(res, data, 'Đặt hàng thành công');
  } catch (error) {
    next(error);
  }
};

// GET /api/orders
export const getOrders = async (req: IAuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const data = await orderService.getOrders(req.user!.id, req.query.status as string | undefined);
    ApiResponse.success(res, data);
  } catch (error) {
    next(error);
  }
};

// GET /api/orders/:id
export const getOrderById = async (req: IAuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const data = await orderService.getOrderById(req.user!.id, req.params.id as string);
    ApiResponse.success(res, data);
  } catch (error) {
    next(error);
  }
};
