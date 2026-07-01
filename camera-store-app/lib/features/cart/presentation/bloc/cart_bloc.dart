import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/entities/cart_entity.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository cartRepository;

  CartBloc({required this.cartRepository}) : super(const CartState()) {
    on<CartLoadRequested>(_onCartLoadRequested);
    on<CartItemAdded>(_onCartItemAdded);
    on<CartItemUpdated>(_onCartItemUpdated);
    on<CartItemRemoved>(_onCartItemRemoved);
    on<CartClearedAll>(_onCartClearedAll);
    on<CartItemSelectionToggled>(_onCartItemSelectionToggled);
    on<CartAllItemsSelectionToggled>(_onCartAllItemsSelectionToggled);
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
      final allItemIds = cart.items.map((e) => e.product.id).toSet();
      emit(state.copyWith(
        status: CartStatus.loaded,
        cart: cart,
        clearUpdating: true,
        selectedItemIds: allItemIds,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: _parseError(e),
        clearUpdating: true,
      ));
    }
  }

  Future<void> _onCartItemAdded(
    CartItemAdded event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(updatingProductId: event.productId));
    try {
      final cart = await cartRepository.addToCart(event.productId, event.quantity);
      final newSelected = Set<String>.from(state.selectedItemIds)..add(event.productId);
      emit(state.copyWith(
        status: CartStatus.loaded,
        cart: cart,
        clearUpdating: true,
        selectedItemIds: newSelected,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: _parseError(e),
        clearUpdating: true,
      ));
    }
  }

  Future<void> _onCartItemUpdated(
    CartItemUpdated event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(updatingProductId: event.productId));
    try {
      final cart = await cartRepository.updateCartItem(event.productId, event.quantity);
      emit(state.copyWith(status: CartStatus.loaded, cart: cart, clearUpdating: true));
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: _parseError(e),
        clearUpdating: true,
      ));
    }
  }

  Future<void> _onCartItemRemoved(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    // Optimistic update to immediately remove item from UI and prevent Dismissible error
    final currentCart = state.cart;
    if (currentCart != null) {
      final newItems = currentCart.items.where((e) => e.product.id != event.productId).toList();
      final optimisticCart = CartEntity(
        id: currentCart.id,
        userId: currentCart.userId,
        items: newItems,
        updatedAt: currentCart.updatedAt,
      );
      final newSelected = Set<String>.from(state.selectedItemIds)..remove(event.productId);
      
      emit(state.copyWith(
        cart: optimisticCart,
        selectedItemIds: newSelected,
        updatingProductId: event.productId,
      ));
    } else {
      emit(state.copyWith(updatingProductId: event.productId));
    }

    try {
      final cart = await cartRepository.removeFromCart(event.productId);
      final newSelected = Set<String>.from(state.selectedItemIds)..remove(event.productId);
      emit(state.copyWith(
        status: CartStatus.loaded,
        cart: cart,
        clearUpdating: true,
        selectedItemIds: newSelected,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: _parseError(e),
        clearUpdating: true,
      ));
      // Reload cart to get true state if delete failed
      add(const CartLoadRequested());
    }
  }

  Future<void> _onCartClearedAll(
    CartClearedAll event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(status: CartStatus.loading));
    try {
      // Remove all items sequentially
      final items = List.of(state.cart?.items ?? []);
      for (final item in items) {
        await cartRepository.removeFromCart(item.product.id);
      }
      final cart = await cartRepository.getCart();
      emit(state.copyWith(
        status: CartStatus.loaded,
        cart: cart,
        clearUpdating: true,
        selectedItemIds: {},
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: _parseError(e),
        clearUpdating: true,
      ));
    }
  }

  void _onCartItemSelectionToggled(
    CartItemSelectionToggled event,
    Emitter<CartState> emit,
  ) {
    final newSelected = Set<String>.from(state.selectedItemIds);
    if (event.isSelected) {
      newSelected.add(event.productId);
    } else {
      newSelected.remove(event.productId);
    }
    emit(state.copyWith(selectedItemIds: newSelected));
  }

  void _onCartAllItemsSelectionToggled(
    CartAllItemsSelectionToggled event,
    Emitter<CartState> emit,
  ) {
    if (state.cart == null) return;
    
    if (event.isSelected) {
      final allItemIds = state.cart!.items.map((e) => e.product.id).toSet();
      emit(state.copyWith(selectedItemIds: allItemIds));
    } else {
      emit(state.copyWith(selectedItemIds: {}));
    }
  }
}
