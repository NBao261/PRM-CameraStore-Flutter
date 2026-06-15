import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/order_repository.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;

  OrderBloc({required this.orderRepository}) : super(const OrderState()) {
    on<OrderCreateRequested>(_onOrderCreateRequested);
    on<OrdersLoadRequested>(_onOrdersLoadRequested);
    on<OrderDetailLoadRequested>(_onOrderDetailLoadRequested);
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
      );
      emit(state.copyWith(
        status: OrderBlocStatus.created,
        createdOrder: order,
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
}
