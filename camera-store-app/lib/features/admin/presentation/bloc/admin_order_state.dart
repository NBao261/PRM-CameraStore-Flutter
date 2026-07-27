import 'package:equatable/equatable.dart';

enum AdminOrderStatus { initial, loading, loaded, updating, error }

class AdminOrderState extends Equatable {
  final AdminOrderStatus status;
  final List<Map<String, dynamic>> orders;
  final Map<String, dynamic>? dashboard;
  final String? errorMessage;
  final String? successMessage;
  final Map<String, dynamic>? updatedOrder;

  const AdminOrderState({
    this.status = AdminOrderStatus.initial,
    this.orders = const [],
    this.dashboard,
    this.errorMessage,
    this.successMessage,
    this.updatedOrder,
  });

  AdminOrderState copyWith({
    AdminOrderStatus? status,
    List<Map<String, dynamic>>? orders,
    Map<String, dynamic>? dashboard,
    String? errorMessage,
    String? successMessage,
    Map<String, dynamic>? updatedOrder,
    bool clearUpdatedOrder = false,
  }) {
    return AdminOrderState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      dashboard: dashboard ?? this.dashboard,
      errorMessage: errorMessage,
      successMessage: successMessage,
      updatedOrder: clearUpdatedOrder ? null : (updatedOrder ?? this.updatedOrder),
    );
  }

  @override
  List<Object?> get props => [status, orders, dashboard, errorMessage, successMessage, updatedOrder];
}
