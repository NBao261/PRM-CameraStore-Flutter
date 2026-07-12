import '../../domain/entities/order_entity.dart';

class OrderModel {
  static OrderEntity fromJson(Map<String, dynamic> json) {
    // If the backend returns { order, payUrl }, extract order details
    final orderData = json.containsKey('order') ? json['order'] : json;
    final payUrl = json.containsKey('payUrl') ? json['payUrl'] as String? : null;

    return OrderEntity(
      id: orderData['_id'] as String,
      items: (orderData['items'] as List<dynamic>)
          .map((item) => OrderItemEntity(
                productId: item['product'] is Map
                    ? item['product']['_id'] as String
                    : item['product'] as String,
                name: item['name'] as String,
                price: (item['price'] as num).toDouble(),
                quantity: item['quantity'] as int,
                imageUrl: item['imageUrl'] as String? ?? '',
              ))
          .toList(),
      shippingInfo: ShippingInfo(
        fullName: orderData['shippingInfo']['fullName'] as String,
        phone: orderData['shippingInfo']['phone'] as String,
        address: orderData['shippingInfo']['address'] as String,
        note: orderData['shippingInfo']['note'] as String? ?? '',
      ),
      paymentMethod: orderData['paymentMethod'] as String,
      subtotal: (orderData['subtotal'] as num).toDouble(),
      shippingFee: (orderData['shippingFee'] as num).toDouble(),
      total: (orderData['total'] as num).toDouble(),
      status: _parseStatus(orderData['status'] as String),
      createdAt: DateTime.parse(orderData['createdAt'] as String),
      payUrl: payUrl,
      couponCode: orderData['couponCode'] as String?,
      discountAmount: (orderData['discountAmount'] as num?)?.toDouble() ?? 0,
      statusHistory: ((orderData['statusHistory'] as List?) ?? [])
          .map((h) {
            final map = h as Map<String, dynamic>;
            return StatusHistoryEntry(
              status: _parseStatus(map['status'] as String? ?? 'pending'),
              changedAt: DateTime.tryParse(
                      map['changedAt'] as String? ?? '') ??
                  DateTime.now(),
            );
          })
          .toList(),
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
