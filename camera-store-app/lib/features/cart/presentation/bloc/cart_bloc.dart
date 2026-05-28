import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/cart_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository cartRepository;

  CartBloc({required this.cartRepository}) : super(const CartState()) {
    on<CartLoadRequested>(_onCartLoadRequested);
    on<CartItemAdded>(_onCartItemAdded);
    on<CartItemUpdated>(_onCartItemUpdated);
    on<CartItemRemoved>(_onCartItemRemoved);
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

  Future<void> _onCartLoadRequested(
    CartLoadRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(status: CartStatus.loading));
    try {
      final cart = await cartRepository.getCart();
      emit(state.copyWith(status: CartStatus.loaded, cart: cart));
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: _parseError(e),
      ));
    }
  }

  Future<void> _onCartItemAdded(
    CartItemAdded event,
    Emitter<CartState> emit,
  ) async {
    try {
      final cart = await cartRepository.addToCart(event.productId, event.quantity);
      emit(state.copyWith(status: CartStatus.loaded, cart: cart));
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: _parseError(e),
      ));
    }
  }

  Future<void> _onCartItemUpdated(
    CartItemUpdated event,
    Emitter<CartState> emit,
  ) async {
    try {
      final cart = await cartRepository.updateCartItem(event.productId, event.quantity);
      emit(state.copyWith(status: CartStatus.loaded, cart: cart));
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: _parseError(e),
      ));
    }
  }

  Future<void> _onCartItemRemoved(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    try {
      final cart = await cartRepository.removeFromCart(event.productId);
      emit(state.copyWith(status: CartStatus.loaded, cart: cart));
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: _parseError(e),
      ));
    }
  }
}
