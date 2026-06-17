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
    }
  ) {
    const cart = await Cart.findOne({ user: userId }).populate('items.product');

    if (!cart || cart.items.length === 0) {
      throw new ValidationError('Giỏ hàng đang trống');
    }

    const items = cart.items.map((item: any) => ({
      product: item.product._id,
      name: item.product.name,
      price: item.product.salePrice || item.product.price,
      quantity: item.quantity,
      imageUrl: item.product.images?.[0] || '',
    }));

    const subtotal = items.reduce((sum, item) => sum + item.price * item.quantity, 0);
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

    // Clear cart after successful order
    cart.items = [];
    await cart.save();

    // Create notification
    await Notification.create({
      user: userId,
      title: 'Đơn hàng mới',
      content: `Đơn hàng #${order._id} đã được tạo thành công`,
      type: 'order',
      relatedId: String(order._id),
      relatedType: 'order',
    });

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
}

export const orderService = new OrderService();
