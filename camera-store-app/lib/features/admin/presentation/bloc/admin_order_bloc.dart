import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/socket_service.dart';
import '../../data/repositories/admin_repository.dart';
import 'admin_order_event.dart';
import 'admin_order_state.dart';

class AdminOrderBloc extends Bloc<AdminOrderEvent, AdminOrderState> {
  final AdminRepository _repository;
  StreamSubscription? _newOrderSubscription;
  StreamSubscription? _orderStatusSubscription;

  AdminOrderBloc(this._repository) : super(const AdminOrderState()) {
    on<AdminDashboardLoad>(_onDashboardLoad);
    on<AdminOrderLoadAll>(_onLoadAll);
    on<AdminOrderUpdateStatus>(_onUpdateStatus);

    _newOrderSubscription = SocketService().newOrderStream.listen((_) {
      add(const AdminOrderLoadAll());
      add(const AdminDashboardLoad());
    });

    _orderStatusSubscription = SocketService().orderStatusStream.listen((_) {
      add(const AdminOrderLoadAll());
      add(const AdminDashboardLoad());
    });
  }

  @override
  Future<void> close() {
    _newOrderSubscription?.cancel();
    _orderStatusSubscription?.cancel();
    return super.close();
  }

  Future<void> _onDashboardLoad(
    AdminDashboardLoad event,
    Emitter<AdminOrderState> emit,
  ) async {
    emit(state.copyWith(status: AdminOrderStatus.loading));
    try {
      final data = await _repository.getDashboardStats();
      emit(state.copyWith(
        status: AdminOrderStatus.loaded,
        dashboard: data,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AdminOrderStatus.error,
        errorMessage: 'Không thể tải thống kê: $e',
      ));
    }
  }

  Future<void> _onLoadAll(
    AdminOrderLoadAll event,
    Emitter<AdminOrderState> emit,
  ) async {
    emit(state.copyWith(status: AdminOrderStatus.loading));
    try {
      final data = await _repository.getAllOrders(status: event.status);
      final orders = (data['orders'] as List)
          .map((o) => Map<String, dynamic>.from(o as Map))
          .toList();
      emit(state.copyWith(
        status: AdminOrderStatus.loaded,
        orders: orders,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AdminOrderStatus.error,
        errorMessage: 'Không thể tải đơn hàng: $e',
      ));
    }
  }

  Future<void> _onUpdateStatus(
    AdminOrderUpdateStatus event,
    Emitter<AdminOrderState> emit,
  ) async {
    emit(state.copyWith(status: AdminOrderStatus.updating));
    try {
      await _repository.updateOrderStatus(event.orderId, event.newStatus);
      emit(state.copyWith(
        status: AdminOrderStatus.loaded,
        successMessage: 'Cập nhật trạng thái thành công',
      ));
      // Reload orders
      add(const AdminOrderLoadAll());
    } catch (e) {
      emit(state.copyWith(
        status: AdminOrderStatus.error,
        errorMessage: 'Không thể cập nhật: $e',
      ));
    }
  }
}
