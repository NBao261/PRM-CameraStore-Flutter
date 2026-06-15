import '../../../../core/network/api_client.dart';
import '../../domain/entities/order_entity.dart';
import '../models/order_model.dart';

class OrderRemoteDataSource {
  final ApiClient apiClient;

  OrderRemoteDataSource(this.apiClient);

  Map<String, dynamic> _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }

  List<dynamic> _extractList(dynamic responseData) {
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      return responseData['data'] as List<dynamic>;
    }
    if (responseData is List) return responseData;
    return [];
  }

  Future<OrderEntity> createOrder({
    required ShippingInfo shippingInfo,
    required String paymentMethod,
  }) async {
    final response = await apiClient.dio.post('/orders', data: {
      'shippingInfo': {
        'fullName': shippingInfo.fullName,
        'phone': shippingInfo.phone,
        'address': shippingInfo.address,
        'note': shippingInfo.note,
      },
      'paymentMethod': paymentMethod,
    });
    return OrderModel.fromJson(_extractData(response.data));
  }

  Future<List<OrderEntity>> getOrders({String? status}) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;

    final response = await apiClient.dio.get(
      '/orders',
      queryParameters: queryParams,
    );
    return _extractList(response.data)
        .map((json) => OrderModel.fromJson(json))
        .toList();
  }

  Future<OrderEntity> getOrderById(String orderId) async {
    final response = await apiClient.dio.get('/orders/$orderId');
    return OrderModel.fromJson(_extractData(response.data));
  }
}
