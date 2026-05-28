import 'package:equatable/equatable.dart';
import 'cart_item_entity.dart';

class CartEntity extends Equatable {
  final String id;
  final String userId;
  final List<CartItemEntity> items;
  final DateTime updatedAt;

  const CartEntity({
    required this.id,
    required this.userId,
    required this.items,
    required this.updatedAt,
  });

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalAmount {
    return items.fold(0, (sum, item) {
      final price = item.product.hasDiscount ? item.product.salePrice! : item.product.price;
      return sum + (price * item.quantity);
    });
  }

  @override
  List<Object?> get props => [id, userId, items, updatedAt];
}
