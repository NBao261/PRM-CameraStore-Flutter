import '../../domain/entities/cart_entity.dart';

abstract class CartRepository {
  Future<CartEntity> getCart();
  Future<CartEntity> addToCart(String productId, int quantity);
  Future<CartEntity> updateCartItem(String productId, int quantity);
  Future<CartEntity> removeFromCart(String productId);
}
