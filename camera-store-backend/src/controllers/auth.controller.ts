import { Request, Response, NextFunction } from 'express';
import { authService } from '../services/auth.service';
import { ApiResponse } from '../utils/response';
import { IAuthRequest } from '../types';

// POST /api/auth/register
export const register = async (req: Request, _res: Response, next: NextFunction): Promise<void> => {
  try {
    const data = await authService.register(req.body);
    ApiResponse.created(_res, data, 'Đăng ký thành công');
  } catch (error) {
    next(error);
  }
};

// POST /api/auth/login
export const login = async (req: Request, _res: Response, next: NextFunction): Promise<void> => {
  try {
    const data = await authService.login(req.body.email, req.body.password);
    ApiResponse.success(_res, data, 'Đăng nhập thành công');
  } catch (error) {
    next(error);
  }
};

// GET /api/auth/profile
export const getProfile = async (req: IAuthRequest, _res: Response, next: NextFunction): Promise<void> => {
  try {
    const data = await authService.getProfile(req.user!.id);
    ApiResponse.success(_res, data);
  } catch (error) {
    next(error);
  }
};

// PUT /api/auth/profile
export const updateProfile = async (req: IAuthRequest, _res: Response, next: NextFunction): Promise<void> => {
  try {
    const data = await authService.updateProfile(req.user!.id, req.body);
    ApiResponse.success(_res, data, 'Cập nhật thành công');
  } catch (error) {
    next(error);
  }
};
