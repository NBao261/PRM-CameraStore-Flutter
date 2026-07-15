import Order from '../models/Order';
import User from '../models/User';
import Cart from '../models/Cart';
import Notification from '../models/Notification';
import Product from '../models/Product';
import Coupon from '../models/Coupon';
import { NotFoundError, ValidationError } from '../utils/errors';

export class OrderService {
  async createOrder(
    userId: string,
    data: {
      shippingInfo: { fullName: string; phone: string; address: string; note?: string };
      paymentMethod: 'cod' | 'bank_transfer' | 'e_wallet';
      productIds?: string[];
      couponCode?: string;
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

    for (const item of itemsToProcess as any[]) {
      if (item.product.stock < item.quantity) {
        throw new ValidationError(`Sản phẩm ${item.product.name} không đủ số lượng (còn ${item.product.stock})`);
      }
    }

    const items = itemsToProcess.map((item: any) => ({
      product: item.product._id,
      name: item.product.name,
      price: item.product.salePrice || item.product.price,
      quantity: item.quantity,
      imageUrl: item.product.images?.[0] || '',
    }));

    for (const item of items) {
      await Product.updateOne(
        { _id: item.product },
        { $inc: { stock: -item.quantity } }
      );
    }

    const subtotal = items.reduce((sum: number, item: any) => sum + item.price * item.quantity, 0);
    const shippingFee = 0;

    // ── Coupon discount ─────────────────────────────────
    let discountAmount = 0;
    let couponCode: string | undefined;

    if (data.couponCode) {
      const coupon = await Coupon.findOne({ code: data.couponCode.toUpperCase(), isActive: true });

      if (coupon && new Date() <= coupon.expiresAt && coupon.usedCount < coupon.usageLimit && subtotal >= coupon.minOrderAmount) {
        if (coupon.type === 'percent') {
          discountAmount = Math.round((subtotal * coupon.value) / 100);
          if (coupon.maxDiscount && discountAmount > coupon.maxDiscount) {
            discountAmount = coupon.maxDiscount;
          }
        } else {
          discountAmount = coupon.value;
        }
        if (discountAmount > subtotal) discountAmount = subtotal;

        couponCode = coupon.code;
        coupon.usedCount += 1;
        await coupon.save();
      }
    }

    const total = subtotal + shippingFee - discountAmount;

    const order = await Order.create({
      user: userId,
      items,
      shippingInfo: data.shippingInfo,
      paymentMethod: data.paymentMethod,
      couponCode: couponCode || null,
      discountAmount,
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

    // Create admin notifications
    const admins = await User.find({ role: 'admin' });
    const adminNotifs = admins.map(admin => ({
      user: admin._id,
      title: 'Đơn hàng mới',
      content: `Có đơn hàng mới #${order._id.toString().substring(0, 8)} vừa được đặt.`,
      type: 'order',
      relatedId: String(order._id),
      relatedType: 'order',
    }));
    
    if (adminNotifs.length > 0) {
      await Notification.insertMany(adminNotifs);
    }

    try {
      const { getIO } = await import('../socket');
      const io = getIO();
      io.to(`user_${userId}`).emit('new_notification', notification);
      
      admins.forEach(admin => {
        io.to(`user_${admin._id}`).emit('new_notification', adminNotifs[0]);
      });

      // Emit real-time new order to admin
      io.to('admin_room').emit('new_order', order);
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

    for (const item of order.items) {
      await Product.updateOne(
        { _id: item.product },
        { $inc: { stock: item.quantity } }
      );
    }

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
      const io = getIO();
      io.to(`user_${userId}`).emit('new_notification', notification);
      
      const admins = await User.find({ role: 'admin' });
      const adminNotifs = admins.map(admin => ({
        user: admin._id,
        title: 'Khách hàng huỷ đơn',
        content: `Đơn hàng #${order._id.toString().substring(0, 8)} đã bị huỷ bởi người dùng.`,
        type: 'order',
        relatedId: String(order._id),
        relatedType: 'order',
      }));
      
      if (adminNotifs.length > 0) {
        await Notification.insertMany(adminNotifs);
      }

      admins.forEach(admin => {
        io.to(`user_${admin._id}`).emit('new_notification', adminNotifs[0]);
      });
      
      // Emit real-time status update
      io.to(`user_${userId}`).emit('order_status_updated', order);
      io.to('admin_room').emit('order_status_updated', order);
    } catch (err) {
      console.error('Socket emit error:', err);
    }

    return order;
  }

  async confirmReceived(userId: string, orderId: string) {
    const order = await Order.findOne({ _id: orderId, user: userId });

    if (!order) throw new NotFoundError('Không tìm thấy đơn hàng');

    if (order.status !== 'shipping') {
      throw new ValidationError('Chỉ có thể xác nhận đã nhận hàng khi đơn đang được giao');
    }

    order.status = 'delivered';
    order.statusHistory.push({ status: 'delivered', changedAt: new Date() });

    // Auto-mark COD as paid on user confirmation
    if (order.paymentMethod === 'cod') {
      order.paymentStatus = 'paid';
    }

    await order.save();

    // Notify user
    const notification = await Notification.create({
      user: userId,
      title: 'Nhận hàng thành công',
      content: `Đơn hàng #${order._id.toString().substring(0, 8)} đã được xác nhận giao thành công. Cảm ơn bạn!`,
      type: 'order',
      relatedId: String(order._id),
      relatedType: 'order',
    });

    try {
      const { getIO } = await import('../socket');
      const io = getIO();
      io.to(`user_${userId}`).emit('new_notification', notification);
      
      const admins = await User.find({ role: 'admin' });
      const adminNotifs = admins.map(admin => ({
        user: admin._id,
        title: 'Đơn hàng hoàn tất',
        content: `Đơn hàng #${order._id.toString().substring(0, 8)} đã được khách hàng xác nhận nhận hàng.`,
        type: 'order',
        relatedId: String(order._id),
        relatedType: 'order',
      }));
      
      if (adminNotifs.length > 0) {
        await Notification.insertMany(adminNotifs);
      }

      admins.forEach(admin => {
        io.to(`user_${admin._id}`).emit('new_notification', adminNotifs[0]);
      });
      
      // Emit real-time status update
      io.to(`user_${userId}`).emit('order_status_updated', order);
      io.to('admin_room').emit('order_status_updated', order);
    } catch (err) {
      console.error('Socket emit error:', err);
    }

    return order;
  }
}

export const orderService = new OrderService();
