import '../../../../core/network/api_client.dart';
import '../models/cart_model.dart';

abstract class CartRemoteDataSource {
  Future<CartModel> getCart();
  Future<CartModel> addToCart(String productId, int quantity);
  Future<CartModel> updateCartItem(String productId, int quantity);
  Future<CartModel> removeFromCart(String productId);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final ApiClient apiClient;

  CartRemoteDataSourceImpl(this.apiClient);

  CartModel _parseResponse(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('data') && responseData['data'] != null) {
        return CartModel.fromJson(responseData['data']);
      }
      if (responseData.containsKey('_id')) {
        return CartModel.fromJson(responseData);
      }
    }
    throw Exception('Unexpected response format');
  }

  @override
  Future<CartModel> getCart() async {
    final response = await apiClient.dio.get('/cart');
    return _parseResponse(response.data);
  }

  @override
  Future<CartModel> addToCart(String productId, int quantity) async {
    final response = await apiClient.dio.post('/cart', data: {
      'productId': productId,
      'quantity': quantity,
    });
    return _parseResponse(response.data);
  }

  @override
  Future<CartModel> updateCartItem(String productId, int quantity) async {
    final response = await apiClient.dio.put('/cart/$productId', data: {
      'quantity': quantity,
    });
    return _parseResponse(response.data);
  }

  @override
  Future<CartModel> removeFromCart(String productId) async {
    final response = await apiClient.dio.delete('/cart/$productId');
    return _parseResponse(response.data);
  }
}
