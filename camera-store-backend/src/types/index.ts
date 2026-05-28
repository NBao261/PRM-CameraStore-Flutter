import { Request, Response, NextFunction } from 'express';

export interface IApiResponse<T = any> {
  success: boolean;
  message: string;
  data?: T;
  errors?: any[];
}

// Extend Express Request to include user info from JWT
export interface IAuthRequest extends Request {
  user?: {
    id: string;
    email: string;
    role: string;
  };
}

// Async handler wrapper to avoid repetitive try-catch
export type AsyncHandler = (
  req: Request,
  res: Response,
  next: NextFunction
) => Promise<any>;

export const asyncHandler =
  (fn: AsyncHandler) =>
  (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
