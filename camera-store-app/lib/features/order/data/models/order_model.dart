import '../../domain/entities/order_entity.dart';

class OrderModel {
  static OrderEntity fromJson(Map<String, dynamic> json) {
    return OrderEntity(
      id: json['_id'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItemEntity(
                productId: item['product'] is Map
                    ? item['product']['_id'] as String
                    : item['product'] as String,
                name: item['name'] as String,
                price: (item['price'] as num).toDouble(),
                quantity: item['quantity'] as int,
              ))
          .toList(),
      shippingInfo: ShippingInfo(
        fullName: json['shippingInfo']['fullName'] as String,
        phone: json['shippingInfo']['phone'] as String,
        address: json['shippingInfo']['address'] as String,
        note: json['shippingInfo']['note'] as String? ?? '',
      ),
      paymentMethod: json['paymentMethod'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      shippingFee: (json['shippingFee'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      status: _parseStatus(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static OrderStatus _parseStatus(String status) {
    switch (status) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'shipping':
        return OrderStatus.shipping;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}
