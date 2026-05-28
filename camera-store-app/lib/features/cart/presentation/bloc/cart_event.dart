import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class CartLoadRequested extends CartEvent {
  const CartLoadRequested();
}

class CartItemAdded extends CartEvent {
  final String productId;
  final int quantity;

  const CartItemAdded({required this.productId, this.quantity = 1});

  @override
  List<Object?> get props => [productId, quantity];
}

class CartItemUpdated extends CartEvent {
  final String productId;
  final int quantity;

  const CartItemUpdated({required this.productId, required this.quantity});

  @override
  List<Object?> get props => [productId, quantity];
}

class CartItemRemoved extends CartEvent {
  final String productId;

  const CartItemRemoved({required this.productId});

  @override
  List<Object?> get props => [productId];
}
