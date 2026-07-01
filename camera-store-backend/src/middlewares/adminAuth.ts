import { Response, NextFunction } from 'express';
import { IAuthRequest } from '../types';
import { ForbiddenError } from '../utils/errors';

const adminAuth = (req: IAuthRequest, _res: Response, next: NextFunction): void => {
  if (!req.user || req.user.role !== 'admin') {
    return next(new ForbiddenError('Bạn không có quyền truy cập chức năng này'));
  }
  next();
};

export default adminAuth;
