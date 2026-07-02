import 'package:bloc_test/bloc_test.dart';
import 'package:camera_store_app/features/cart/domain/entities/cart_entity.dart';
import 'package:camera_store_app/features/cart/domain/entities/cart_item_entity.dart';
import 'package:camera_store_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:camera_store_app/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:camera_store_app/features/cart/presentation/bloc/cart_event.dart';
import 'package:camera_store_app/features/cart/presentation/bloc/cart_state.dart';
import 'package:camera_store_app/features/product/domain/entities/product_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  late CartBloc cartBloc;
  late MockCartRepository mockRepository;

  setUp(() {
    mockRepository = MockCartRepository();
    cartBloc = CartBloc(cartRepository: mockRepository);
  });

  tearDown(() {
    cartBloc.close();
  });

  // ── Test data ──────────────────────────────────────────
  const tProduct1 = ProductEntity(
    id: 'p1',
    name: 'Canon EOS R5',
    price: 89000000,
    stock: 10,
  );

  const tProduct2 = ProductEntity(
    id: 'p2',
    name: 'Sony A7 IV',
    price: 55000000,
    salePrice: 50000000,
    stock: 5,
  );

  final tCart = CartEntity(
    id: 'cart1',
    userId: 'user1',
    items: const [
      CartItemEntity(product: tProduct1, quantity: 2),
      CartItemEntity(product: tProduct2, quantity: 1),
    ],
    updatedAt: DateTime(2025, 1, 1),
  );

  final tEmptyCart = CartEntity(
    id: 'cart1',
    userId: 'user1',
    items: const [],
    updatedAt: DateTime(2025, 1, 1),
  );

  group('CartBloc', () {
    test('initial state is correct', () {
      expect(cartBloc.state, const CartState());
      expect(cartBloc.state.status, CartStatus.initial);
      expect(cartBloc.state.cart, isNull);
      expect(cartBloc.state.totalItems, 0);
      expect(cartBloc.state.totalAmount, 0);
    });

    // ── CartLoadRequested ────────────────────────────────
    group('CartLoadRequested', () {
      blocTest<CartBloc, CartState>(
        'emits [loading, loaded] with selected items when getCart succeeds',
        build: () {
          when(() => mockRepository.getCart())
              .thenAnswer((_) async => tCart);
          return CartBloc(cartRepository: mockRepository);
        },
        act: (bloc) => bloc.add(const CartLoadRequested()),
        expect: () => [
          const CartState(status: CartStatus.loading),
          CartState(
            status: CartStatus.loaded,
            cart: tCart,
            selectedItemIds: {'p1', 'p2'}, // All items selected by default
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.getCart()).called(1);
        },
      );

      blocTest<CartBloc, CartState>(
        'emits [loading, error] when getCart fails',
        build: () {
          when(() => mockRepository.getCart())
              .thenThrow(Exception('Connection refused'));
          return CartBloc(cartRepository: mockRepository);
        },
        act: (bloc) => bloc.add(const CartLoadRequested()),
        expect: () => [
          const CartState(status: CartStatus.loading),
          isA<CartState>()
              .having((s) => s.status, 'status', CartStatus.error)
              .having((s) => s.errorMessage, 'errorMessage', isNotNull),
        ],
      );
    });

    // ── CartItemAdded ────────────────────────────────────
    group('CartItemAdded', () {
      blocTest<CartBloc, CartState>(
        'emits [updating, loaded] when addToCart succeeds',
        build: () {
          when(() => mockRepository.addToCart('p1', 1))
              .thenAnswer((_) async => tCart);
          return CartBloc(cartRepository: mockRepository);
        },
        act: (bloc) =>
            bloc.add(const CartItemAdded(productId: 'p1', quantity: 1)),
        expect: () => [
          isA<CartState>()
              .having((s) => s.updatingProductId, 'updatingProductId', 'p1'),
          isA<CartState>()
              .having((s) => s.status, 'status', CartStatus.loaded)
              .having((s) => s.cart, 'cart', tCart)
              .having((s) => s.updatingProductId, 'updatingProductId', isNull),
        ],
      );
    });

    // ── CartItemRemoved ──────────────────────────────────
    group('CartItemRemoved', () {
      blocTest<CartBloc, CartState>(
        'optimistically removes item, then emits loaded on API success',
        seed: () => CartState(
          status: CartStatus.loaded,
          cart: tCart,
          selectedItemIds: {'p1', 'p2'},
        ),
        build: () {
          when(() => mockRepository.removeFromCart('p1'))
              .thenAnswer((_) async => CartEntity(
                    id: 'cart1',
                    userId: 'user1',
                    items: const [CartItemEntity(product: tProduct2, quantity: 1)],
                    updatedAt: DateTime(2025, 1, 1),
                  ));
          return CartBloc(cartRepository: mockRepository);
        },
        act: (bloc) =>
            bloc.add(const CartItemRemoved(productId: 'p1')),
        expect: () => [
          // First: optimistic removal
          isA<CartState>()
              .having(
                  (s) => s.cart?.items.length, 'items.length after optimistic', 1)
              .having((s) => s.selectedItemIds, 'selectedItemIds', {'p2'}),
          // Then: server response
          isA<CartState>()
              .having((s) => s.status, 'status', CartStatus.loaded)
              .having((s) => s.updatingProductId, 'updatingProductId', isNull),
        ],
      );
    });

    // ── CartItemSelectionToggled ──────────────────────────
    group('CartItemSelectionToggled', () {
      blocTest<CartBloc, CartState>(
        'adds productId to selectedItemIds when selected',
        seed: () => CartState(
          status: CartStatus.loaded,
          cart: tCart,
          selectedItemIds: {'p1'},
        ),
        build: () => CartBloc(cartRepository: mockRepository),
        act: (bloc) => bloc.add(
          const CartItemSelectionToggled(productId: 'p2', isSelected: true),
        ),
        expect: () => [
          isA<CartState>()
              .having((s) => s.selectedItemIds, 'selectedItemIds', {'p1', 'p2'}),
        ],
      );

      blocTest<CartBloc, CartState>(
        'removes productId from selectedItemIds when deselected',
        seed: () => CartState(
          status: CartStatus.loaded,
          cart: tCart,
          selectedItemIds: {'p1', 'p2'},
        ),
        build: () => CartBloc(cartRepository: mockRepository),
        act: (bloc) => bloc.add(
          const CartItemSelectionToggled(productId: 'p1', isSelected: false),
        ),
        expect: () => [
          isA<CartState>()
              .having((s) => s.selectedItemIds, 'selectedItemIds', {'p2'}),
        ],
      );
    });

    // ── CartEntity computed properties ───────────────────
    group('CartEntity computed properties', () {
      test('totalItems sums all quantities', () {
        expect(tCart.totalItems, 3); // 2 + 1
      });

      test('totalAmount calculates with sale price when applicable', () {
        // product1: no sale, 89000000 * 2 = 178000000
        // product2: sale 50000000 * 1 = 50000000
        expect(tCart.totalAmount, 228000000);
      });

      test('empty cart has 0 total', () {
        expect(tEmptyCart.totalItems, 0);
        expect(tEmptyCart.totalAmount, 0);
      });
    });

    // ── CartState computed properties ────────────────────
    group('CartState computed properties', () {
      test('selectedTotalItems counts only selected items', () {
        final state = CartState(
          status: CartStatus.loaded,
          cart: tCart,
          selectedItemIds: {'p1'}, // only product1 selected
        );
        expect(state.selectedTotalItems, 2); // quantity of p1
      });

      test('getQuantityForProduct returns correct quantity', () {
        final state = CartState(
          status: CartStatus.loaded,
          cart: tCart,
        );
        expect(state.getQuantityForProduct('p1'), 2);
        expect(state.getQuantityForProduct('p2'), 1);
        expect(state.getQuantityForProduct('nonexistent'), 0);
      });

      test('getQuantityForProduct returns 0 when cart is null', () {
        const state = CartState();
        expect(state.getQuantityForProduct('p1'), 0);
      });
    });
  });
}
