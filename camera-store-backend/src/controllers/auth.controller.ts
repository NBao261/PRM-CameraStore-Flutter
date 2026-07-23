import { Request, Response, NextFunction } from 'express';
import { authService } from '../services/auth.service';
import { ApiResponse } from '../utils/response';
import { IAuthRequest } from '../types';

// POST /api/auth/register
export const register = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const data = await authService.register(req.body);
    res.status(200).json({ success: true, message: data.message });
  } catch (error) {
    next(error);
  }
};

// POST /api/auth/verify-otp
export const verifyOtp = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { email, otp } = req.body;
    const data = await authService.verifyOtp(email, otp);
    res.status(201).json({ success: true, message: 'Đăng ký thành công', data });
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

// PUT /api/auth/change-password
export const changePassword = async (req: IAuthRequest, _res: Response, next: NextFunction): Promise<void> => {
  try {
    const data = await authService.changePassword(req.user!.id, req.body);
    ApiResponse.success(_res, data, data.message);
  } catch (error) {
    next(error);
  }
};

// POST /api/auth/forgot-password
export const forgotPassword = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const data = await authService.forgotPassword(req.body.email);
    res.status(200).json({ success: true, message: data.message });
  } catch (error) {
    next(error);
  }
};

// POST /api/auth/reset-password
export const resetPassword = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const data = await authService.resetPassword(req.body);
    res.status(200).json({ success: true, message: data.message });
  } catch (error) {
    next(error);
  }
};
