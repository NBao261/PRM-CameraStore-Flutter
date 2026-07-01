import 'package:equatable/equatable.dart';

abstract class AdminOrderEvent extends Equatable {
  const AdminOrderEvent();
  @override
  List<Object?> get props => [];
}

class AdminOrderLoadAll extends AdminOrderEvent {
  final String? status;
  const AdminOrderLoadAll({this.status});
  @override
  List<Object?> get props => [status];
}

class AdminOrderUpdateStatus extends AdminOrderEvent {
  final String orderId;
  final String newStatus;
  const AdminOrderUpdateStatus({required this.orderId, required this.newStatus});
  @override
  List<Object?> get props => [orderId, newStatus];
}

class AdminDashboardLoad extends AdminOrderEvent {
  const AdminDashboardLoad();
}
