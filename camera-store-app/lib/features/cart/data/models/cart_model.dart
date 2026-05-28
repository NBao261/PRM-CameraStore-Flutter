import '../../domain/entities/cart_entity.dart';
import 'cart_item_model.dart';

class CartModel extends CartEntity {
  const CartModel({
    required super.id,
    required super.userId,
    required super.items,
    required super.updatedAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['_id'] ?? '',
      userId: json['user'] is Map ? json['user']['_id'] ?? '' : json['user'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => CartItemModel.fromJson(item))
              .toList() ??
          [],
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }
}
