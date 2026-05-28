import '../datasources/cart_remote_datasource.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl(this.remoteDataSource);

  @override
  Future<CartEntity> getCart() async {
    return await remoteDataSource.getCart();
  }

  @override
  Future<CartEntity> addToCart(String productId, int quantity) async {
    return await remoteDataSource.addToCart(productId, quantity);
  }

  @override
  Future<CartEntity> updateCartItem(String productId, int quantity) async {
    return await remoteDataSource.updateCartItem(productId, quantity);
  }

  @override
  Future<CartEntity> removeFromCart(String productId) async {
    return await remoteDataSource.removeFromCart(productId);
  }
}
