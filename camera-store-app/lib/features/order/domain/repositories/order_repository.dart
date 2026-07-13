import '../entities/order_entity.dart';

abstract class OrderRepository {
  /// Create a new order from current cart
  Future<OrderEntity> createOrder({
    required ShippingInfo shippingInfo,
    required String paymentMethod,
    List<String>? productIds,
    String? couponCode,
  });

  /// Get list of orders, optionally filtered by status
  Future<List<OrderEntity>> getOrders({String? status});

  /// Get a single order by ID
  Future<OrderEntity> getOrderById(String orderId);

  /// Cancel an order
  Future<OrderEntity> cancelOrder(String orderId);
}
