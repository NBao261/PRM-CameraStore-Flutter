import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';

enum OrderBlocStatus { initial, loading, created, loaded, error }

class OrderState extends Equatable {
  final OrderBlocStatus status;
  final List<OrderEntity> orders;
  final OrderEntity? currentOrder;
  final OrderEntity? createdOrder;
  final String? errorMessage;

  const OrderState({
    this.status = OrderBlocStatus.initial,
    this.orders = const [],
    this.currentOrder,
    this.createdOrder,
    this.errorMessage,
  });

  OrderState copyWith({
    OrderBlocStatus? status,
    List<OrderEntity>? orders,
    OrderEntity? currentOrder,
    OrderEntity? createdOrder,
    String? errorMessage,
  }) {
    return OrderState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      currentOrder: currentOrder ?? this.currentOrder,
      createdOrder: createdOrder ?? this.createdOrder,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, orders, currentOrder, createdOrder, errorMessage];
}
