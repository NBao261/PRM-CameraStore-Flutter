import { Response, NextFunction } from 'express';
import Order from '../models/Order';
import User from '../models/User';
import Notification from '../models/Notification';
import Product from '../models/Product';
import { ApiResponse } from '../utils/response';
import { NotFoundError, ValidationError } from '../utils/errors';
import { IAuthRequest } from '../types';

// GET /api/admin/orders?status=pending&page=1&limit=20
export const getAllOrders = async (req: IAuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const skip = (page - 1) * limit;
    const status = req.query.status as string | undefined;

    const filter: any = {};
    if (status && status !== 'all') filter.status = status;

    const total = await Order.countDocuments(filter);
    const orders = await Order.find(filter)
      .populate('user', 'fullName email phone avatar')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    ApiResponse.success(res, {
      orders,
      pagination: { page, limit, total, totalPages: Math.ceil(total / limit) },
    });
  } catch (error) {
    next(error);
  }
};

// PUT /api/admin/orders/:id/status
export const updateOrderStatus = async (req: IAuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    const validTransitions: Record<string, string[]> = {
      pending:   ['confirmed', 'cancelled'],
      confirmed: ['shipping', 'cancelled'],
      shipping:  ['delivered'],
      delivered: [],
      cancelled: [],
    };

    const order = await Order.findById(id);
    if (!order) throw new NotFoundError('Không tìm thấy đơn hàng');

    const allowed = validTransitions[order.status] || [];
    if (!allowed.includes(status)) {
      throw new ValidationError(
        `Không thể chuyển trạng thái từ "${order.status}" sang "${status}"`
      );
    }

    order.status = status;
    order.statusHistory.push({ status, changedAt: new Date() });

    // Auto-update payment status
    if (status === 'delivered' && order.paymentMethod === 'cod') {
      order.paymentStatus = 'paid';
    }

    // Restore stock if cancelled
    if (status === 'cancelled') {
      for (const item of order.items) {
        await Product.updateOne(
          { _id: item.product },
          { $inc: { stock: item.quantity } }
        );
      }
    }

    await order.save();

    // Notify the customer
    const statusLabels: Record<string, string> = {
      confirmed: 'đã được xác nhận',
      shipping:  'đang được giao',
      delivered: 'đã giao thành công',
      cancelled: 'đã bị hủy bởi cửa hàng',
    };

    const notification = await Notification.create({
      user: order.user,
      title: 'Cập nhật đơn hàng',
      content: `Đơn hàng #${order._id.toString().substring(0, 8)} ${statusLabels[status] || status}.`,
      type: 'order',
      relatedId: String(order._id),
      relatedType: 'order',
    });

    try {
      const { getIO } = await import('../socket');
      const io = getIO();
      io.to(`user_${order.user}`).emit('new_notification', notification);
      
      // Emit real-time status update
      io.to(`user_${order.user}`).emit('order_status_updated', order);
      io.to('admin_room').emit('order_status_updated', order);
    } catch (err) {
      console.error('Socket emit error:', err);
    }

    const updated = await Order.findById(id).populate('user', 'fullName email phone avatar');
    ApiResponse.success(res, updated, 'Cập nhật trạng thái thành công');
  } catch (error) {
    next(error);
  }
};

// GET /api/admin/dashboard
export const getDashboardStats = async (req: IAuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const [
      totalOrders,
      pendingOrders,
      todayOrders,
      totalCustomers,
      revenueResult,
    ] = await Promise.all([
      Order.countDocuments(),
      Order.countDocuments({ status: 'pending' }),
      Order.countDocuments({ createdAt: { $gte: today } }),
      User.countDocuments({ role: 'user' }),
      Order.aggregate([
        { $match: { status: { $in: ['confirmed', 'shipping', 'delivered'] } } },
        { $group: { _id: null, total: { $sum: '$total' } } },
      ]),
    ]);

    const totalRevenue = revenueResult.length > 0 ? revenueResult[0].total : 0;

    // Recent orders (5 latest)
    const recentOrders = await Order.find()
      .populate('user', 'fullName email avatar')
      .sort({ createdAt: -1 })
      .limit(5);

    ApiResponse.success(res, {
      totalOrders,
      pendingOrders,
      todayOrders,
      totalCustomers,
      totalRevenue,
      recentOrders,
    });
  } catch (error) {
    next(error);
  }
};
