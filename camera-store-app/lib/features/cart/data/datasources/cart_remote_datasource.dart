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

  @override
  Future<CartModel> getCart() async {
    final response = await apiClient.dio.get('/api/cart');
    return CartModel.fromJson(response.data['data']);
  }

  @override
  Future<CartModel> addToCart(String productId, int quantity) async {
    final response = await apiClient.dio.post('/api/cart', data: {
      'productId': productId,
      'quantity': quantity,
    });
    return CartModel.fromJson(response.data['data']);
  }

  @override
  Future<CartModel> updateCartItem(String productId, int quantity) async {
    final response = await apiClient.dio.put('/api/cart/$productId', data: {
      'quantity': quantity,
    });
    return CartModel.fromJson(response.data['data']);
  }

  @override
  Future<CartModel> removeFromCart(String productId) async {
    final response = await apiClient.dio.delete('/api/cart/$productId');
    return CartModel.fromJson(response.data['data']);
  }
}
