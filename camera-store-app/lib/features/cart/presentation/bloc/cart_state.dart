import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_entity.dart';

enum CartStatus { initial, loading, loaded, error }

class CartState extends Equatable {
  final CartStatus status;
  final CartEntity? cart;
  final String? errorMessage;

  const CartState({
    this.status = CartStatus.initial,
    this.cart,
    this.errorMessage,
  });

  int get totalItems => cart?.totalItems ?? 0;
  double get totalAmount => cart?.totalAmount ?? 0;

  /// Get current quantity of a specific product in the cart
  int getQuantityForProduct(String productId) {
    if (cart == null) return 0;
    final item = cart!.items.where((i) => i.product.id == productId);
    if (item.isEmpty) return 0;
    return item.first.quantity;
  }

  CartState copyWith({
    CartStatus? status,
    CartEntity? cart,
    String? errorMessage,
  }) {
    return CartState(
      status: status ?? this.status,
      cart: cart ?? this.cart,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, cart, errorMessage];
}
