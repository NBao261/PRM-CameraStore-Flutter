import Order from '../models/Order';
import Cart from '../models/Cart';
import Notification from '../models/Notification';
import { NotFoundError, ValidationError } from '../utils/errors';

export class OrderService {
  async createOrder(
    userId: string,
    data: {
      shippingInfo: { fullName: string; phone: string; address: string; note?: string };
      paymentMethod: 'cod' | 'bank_transfer' | 'e_wallet';
      productIds?: string[];
    }
  ) {
    const cart = await Cart.findOne({ user: userId }).populate('items.product');

    if (!cart || cart.items.length === 0) {
      throw new ValidationError('Giỏ hàng đang trống');
    }

    let itemsToProcess = cart.items;
    if (data.productIds && data.productIds.length > 0) {
      itemsToProcess = cart.items.filter((item: any) =>
        data.productIds!.includes(String(item.product._id))
      );
      if (itemsToProcess.length === 0) {
        throw new ValidationError('Không tìm thấy sản phẩm được chọn trong giỏ hàng');
      }
    }

    const items = itemsToProcess.map((item: any) => ({
      product: item.product._id,
      name: item.product.name,
      price: item.product.salePrice || item.product.price,
      quantity: item.quantity,
      imageUrl: item.product.images?.[0] || '',
    }));

    const subtotal = items.reduce((sum: number, item: any) => sum + item.price * item.quantity, 0);
    const shippingFee = 0;
    const total = subtotal + shippingFee;

    const order = await Order.create({
      user: userId,
      items,
      shippingInfo: data.shippingInfo,
      paymentMethod: data.paymentMethod,
      subtotal,
      shippingFee,
      total,
      status: 'pending',
      statusHistory: [{ status: 'pending', changedAt: new Date() }],
    });

    // Remove purchased items from cart
    if (data.productIds && data.productIds.length > 0) {
      cart.items = cart.items.filter((item: any) =>
        !data.productIds!.includes(String(item.product._id))
      );
    } else {
      cart.items = [];
    }
    await cart.save();

    const productName = items.length === 1
      ? items[0].name
      : `${items[0].name} và ${items.length - 1} sản phẩm khác`;

    // Create notification
    const notification = await Notification.create({
      user: userId,
      title: 'Đơn hàng mới',
      content: `Đơn hàng với sản phẩm ${productName} đã được tạo thành công`,
      type: 'order',
      relatedId: String(order._id),
      relatedType: 'order',
    });

    try {
      const { getIO } = await import('../socket');
      getIO().to(`user_${userId}`).emit('new_notification', notification);
    } catch (err) {
      console.error('Socket emit error:', err);
    }

    let payUrl: string | undefined;

    if (data.paymentMethod === 'e_wallet') {
      try {
        const { momoService } = await import('./momo.service');
        payUrl = await momoService.createPaymentUrl({
          orderId: String(order._id),
          amount: total,
          orderInfo: `Thanh toán đơn hàng #${order._id} tại Camera Store`,
        });
      } catch (error) {
        console.error('MoMo integration error:', error);
        // We still return the order, but frontend will see error when fetching payUrl.
        // Or we can throw error, but order is already created. Let's just pass error message.
      }
    }

    return { order, payUrl };
  }

  async getOrders(userId: string, status?: string) {
    const filter: any = { user: userId };
    if (status) filter.status = status;

    return Order.find(filter).sort({ createdAt: -1 });
  }

  async getOrderById(userId: string, orderId: string) {
    const order = await Order.findOne({ _id: orderId, user: userId }).populate('items.product');

    if (!order) {
      throw new NotFoundError('Không tìm thấy đơn hàng');
    }
    return order;
  }

  async cancelOrder(userId: string, orderId: string) {
    const order = await Order.findOne({ _id: orderId, user: userId });

    if (!order) {
      throw new NotFoundError('Không tìm thấy đơn hàng');
    }

    if (order.status !== 'pending') {
      throw new ValidationError('Chỉ có thể huỷ đơn hàng khi đang ở trạng thái chờ xác nhận');
    }

    order.status = 'cancelled';
    order.statusHistory.push({ status: 'cancelled', changedAt: new Date() });
    await order.save();

    // Create notification
    const notification = await Notification.create({
      user: userId,
      title: 'Đã huỷ đơn hàng',
      content: `Đơn hàng #${order._id.toString().substring(0, 8)} đã được huỷ thành công.`,
      type: 'order',
      relatedId: String(order._id),
      relatedType: 'order',
    });

    try {
      const { getIO } = await import('../socket');
      getIO().to(`user_${userId}`).emit('new_notification', notification);
    } catch (err) {
      console.error('Socket emit error:', err);
    }

    return order;
  }
}

export const orderService = new OrderService();
