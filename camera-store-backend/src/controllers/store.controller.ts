import { Request, Response, NextFunction } from 'express';
import StoreLocation from '../models/StoreLocation';
import { ApiResponse } from '../utils/response';

// GET /api/stores
export const getStores = async (_req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const stores = await StoreLocation.find();
    ApiResponse.success(res, stores);
  } catch (error) {
    next(error);
  }
};
