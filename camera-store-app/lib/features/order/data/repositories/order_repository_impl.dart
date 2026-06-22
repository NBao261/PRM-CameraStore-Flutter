import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;

  OrderRepositoryImpl(this._remoteDataSource);

  @override
  Future<OrderEntity> createOrder({
    required ShippingInfo shippingInfo,
    required String paymentMethod,
    List<String>? productIds,
  }) {
    return _remoteDataSource.createOrder(
      shippingInfo: shippingInfo,
      paymentMethod: paymentMethod,
      productIds: productIds,
    );
  }

  @override
  Future<List<OrderEntity>> getOrders({String? status}) {
    return _remoteDataSource.getOrders(status: status);
  }

  @override
  Future<OrderEntity> getOrderById(String orderId) {
    return _remoteDataSource.getOrderById(orderId);
  }
}
