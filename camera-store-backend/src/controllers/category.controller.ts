import { Request, Response, NextFunction } from 'express';
import Category from '../models/Category';
import Brand from '../models/Brand';
import { ApiResponse } from '../utils/response';

// GET /api/categories
export const getCategories = async (_req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const categories = await Category.find();
    ApiResponse.success(res, categories);
  } catch (error) {
    next(error);
  }
};

// GET /api/brands
export const getBrands = async (_req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const brands = await Brand.find();
    ApiResponse.success(res, brands);
  } catch (error) {
    next(error);
  }
};
