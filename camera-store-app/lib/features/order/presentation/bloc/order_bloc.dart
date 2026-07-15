import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/socket_service.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;
  StreamSubscription? _orderStatusSubscription;

  OrderBloc({required this.orderRepository}) : super(const OrderState()) {
    on<OrderCreateRequested>(_onOrderCreateRequested);
    on<OrdersLoadRequested>(_onOrdersLoadRequested);
    on<OrderDetailLoadRequested>(_onOrderDetailLoadRequested);
    on<OrderCancelRequested>(_onOrderCancelRequested);

    _orderStatusSubscription = SocketService().orderStatusStream.listen((data) {
      add(const OrdersLoadRequested());
      if (state.currentOrder != null && state.currentOrder!.id == data['_id']) {
        add(OrderDetailLoadRequested(data['_id']));
      }
    });
  }

  @override
  Future<void> close() {
    _orderStatusSubscription?.cancel();
    return super.close();
  }

  String _parseError(dynamic e) {
    if (e is DioException) {
      if (e.response?.data is Map) {
        return e.response?.data['message'] ?? 'Lỗi kết nối server';
      }
      return 'Lỗi kết nối server (${e.response?.statusCode ?? "timeout"})';
    }
    return e.toString();
  }

  Future<void> _onOrderCreateRequested(
    OrderCreateRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(status: OrderBlocStatus.loading));
    try {
      final order = await orderRepository.createOrder(
        shippingInfo: event.shippingInfo,
        paymentMethod: event.paymentMethod,
        productIds: event.productIds,
        couponCode: event.couponCode,
      );
      final updatedOrders = List<OrderEntity>.from(state.orders)..insert(0, order);
      emit(state.copyWith(
        status: OrderBlocStatus.created,
        createdOrder: order,
        orders: updatedOrders,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrderBlocStatus.error,
        errorMessage: _parseError(e),
      ));
    }
  }

  Future<void> _onOrdersLoadRequested(
    OrdersLoadRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(status: OrderBlocStatus.loading));
    try {
      final orders = await orderRepository.getOrders(status: event.status);
      emit(state.copyWith(
        status: OrderBlocStatus.loaded,
        orders: orders,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrderBlocStatus.error,
        errorMessage: _parseError(e),
      ));
    }
  }

  Future<void> _onOrderDetailLoadRequested(
    OrderDetailLoadRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(status: OrderBlocStatus.loading));
    try {
      final order = await orderRepository.getOrderById(event.orderId);
      emit(state.copyWith(
        status: OrderBlocStatus.loaded,
        currentOrder: order,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrderBlocStatus.error,
        errorMessage: _parseError(e),
      ));
    }
  }

  Future<void> _onOrderCancelRequested(
    OrderCancelRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(status: OrderBlocStatus.loading));
    try {
      final order = await orderRepository.cancelOrder(event.orderId);
      emit(state.copyWith(
        status: OrderBlocStatus.loaded,
        currentOrder: order,
      ));
      
      // Reload orders list after cancellation to update the list
      add(const OrdersLoadRequested());
    } catch (e) {
      emit(state.copyWith(
        status: OrderBlocStatus.error,
        errorMessage: _parseError(e),
      ));
    }
  }
}
