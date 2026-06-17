import { Response, NextFunction } from 'express';
import Notification from '../models/Notification';
import { ApiResponse } from '../utils/response';
import { NotFoundError } from '../utils/errors';
import { IAuthRequest } from '../types';

// GET /api/notifications
export const getNotifications = async (req: IAuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const notifications = await Notification.find({ user: req.user!.id }).sort({ createdAt: -1 });
    ApiResponse.success(res, notifications);
  } catch (error) {
    next(error);
  }
};

// PUT /api/notifications/:id/read
export const markAsRead = async (req: IAuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const notification = await Notification.findOneAndUpdate(
      { _id: req.params.id, user: req.user!.id },
      { isRead: true },
      { new: true }
    );
    if (!notification) {
      throw new NotFoundError('Không tìm thấy thông báo');
    }
    ApiResponse.success(res, notification);
  } catch (error) {
    next(error);
  }
};

// PUT /api/notifications/read-all
export const markAllAsRead = async (req: IAuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    await Notification.updateMany(
      { user: req.user!.id, isRead: false },
      { isRead: true }
    );
    ApiResponse.success(res, { message: 'Đã đánh dấu tất cả là đã đọc' });
  } catch (error) {
    next(error);
  }
};
