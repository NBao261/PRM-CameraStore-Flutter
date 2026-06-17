import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class OrderCreateRequested extends OrderEvent {
  final ShippingInfo shippingInfo;
  final String paymentMethod;
  final List<String>? productIds;

  const OrderCreateRequested({
    required this.shippingInfo,
    required this.paymentMethod,
    this.productIds,
  });

  @override
  List<Object?> get props => [shippingInfo, paymentMethod, productIds];
}

class OrdersLoadRequested extends OrderEvent {
  final String? status;
  const OrdersLoadRequested({this.status});

  @override
  List<Object?> get props => [status];
}

class OrderDetailLoadRequested extends OrderEvent {
  final String orderId;
  const OrderDetailLoadRequested(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
