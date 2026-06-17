import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_entity.dart';

enum CartStatus { initial, loading, loaded, error }

class CartState extends Equatable {
  final CartStatus status;
  final CartEntity? cart;
  final String? errorMessage;
  /// Which product is currently being updated (for per-item loading indicator)
  final String? updatingProductId;
  /// Set of product IDs that are selected for checkout
  final Set<String> selectedItemIds;

  const CartState({
    this.status = CartStatus.initial,
    this.cart,
    this.errorMessage,
    this.updatingProductId,
    this.selectedItemIds = const {},
  });

  int get totalItems => cart?.totalItems ?? 0;
  double get totalAmount => cart?.totalAmount ?? 0;

  int get selectedTotalItems {
    if (cart == null) return 0;
    return cart!.items
        .where((item) => selectedItemIds.contains(item.product.id))
        .fold(0, (sum, item) => sum + item.quantity);
  }

  double get selectedTotalAmount {
    if (cart == null) return 0;
    return cart!.items
        .where((item) => selectedItemIds.contains(item.product.id))
        .fold(0, (sum, item) {
      final price = item.product.hasDiscount ? item.product.salePrice! : item.product.price;
      return sum + (price * item.quantity);
    });
  }

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
    String? updatingProductId,
    Set<String>? selectedItemIds,
    bool clearUpdating = false,
  }) {
    return CartState(
      status: status ?? this.status,
      cart: cart ?? this.cart,
      errorMessage: errorMessage ?? this.errorMessage,
      updatingProductId: clearUpdating ? null : (updatingProductId ?? this.updatingProductId),
      selectedItemIds: selectedItemIds ?? this.selectedItemIds,
    );
  }

  @override
  List<Object?> get props => [status, cart, errorMessage, updatingProductId, selectedItemIds];
}
