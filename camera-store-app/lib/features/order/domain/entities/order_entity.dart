import 'package:equatable/equatable.dart';

enum OrderStatus { pending, confirmed, shipping, delivered, cancelled }

class ShippingInfo extends Equatable {
  final String fullName;
  final String phone;
  final String address;
  final String note;

  const ShippingInfo({
    required this.fullName,
    required this.phone,
    required this.address,
    this.note = '',
  });

  @override
  List<Object?> get props => [fullName, phone, address, note];
}

class OrderItemEntity extends Equatable {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;

  const OrderItemEntity({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl = '',
  });

  double get lineTotal => price * quantity;

  @override
  List<Object?> get props => [productId, name, price, quantity, imageUrl];
}

class OrderEntity extends Equatable {
  final String id;
  final List<OrderItemEntity> items;
  final ShippingInfo shippingInfo;
  final String paymentMethod;
  final double subtotal;
  final double shippingFee;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final String? payUrl; // Added for MoMo payment

  const OrderEntity({
    required this.id,
    required this.items,
    required this.shippingInfo,
    required this.paymentMethod,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    required this.status,
    required this.createdAt,
    this.payUrl,
  });

  String get statusLabel {
    switch (status) {
      case OrderStatus.pending:
        return 'Chờ xác nhận';
      case OrderStatus.confirmed:
        return 'Đã xác nhận';
      case OrderStatus.shipping:
        return 'Đang giao hàng';
      case OrderStatus.delivered:
        return 'Đã giao';
      case OrderStatus.cancelled:
        return 'Đã hủy';
    }
  }

  @override
  List<Object?> get props => [
        id, items, shippingInfo, paymentMethod,
        subtotal, shippingFee, total, status, createdAt,
      ];
}
