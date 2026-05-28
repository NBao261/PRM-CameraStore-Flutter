import { Request, Response, NextFunction } from 'express';
import { productService } from '../services/product.service';
import { ApiResponse } from '../utils/response';

// GET /api/products
export const getProducts = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const data = await productService.getProducts(req.query as any);
    ApiResponse.success(res, data);
  } catch (error) {
    next(error);
  }
};

// GET /api/products/:id
export const getProductById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const data = await productService.getProductById(req.params.id as string);
    ApiResponse.success(res, data);
  } catch (error) {
    next(error);
  }
};
