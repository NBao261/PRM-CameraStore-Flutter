import 'package:bloc_test/bloc_test.dart';
import 'package:camera_store_app/core/errors/failures.dart';
import 'package:camera_store_app/features/product/domain/entities/product_entity.dart';
import 'package:camera_store_app/features/product/domain/repositories/product_repository.dart';
import 'package:camera_store_app/features/product/presentation/bloc/product_bloc.dart';
import 'package:camera_store_app/features/product/presentation/bloc/product_event.dart';
import 'package:camera_store_app/features/product/presentation/bloc/product_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late ProductBloc productBloc;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    productBloc = ProductBloc(mockRepository);
  });

  tearDown(() {
    productBloc.close();
  });

  // ── Test data ──────────────────────────────────────────
  final tProducts = [
    const ProductEntity(
      id: '1',
      name: 'Canon EOS R5',
      price: 89000000,
      stock: 10,
    ),
    const ProductEntity(
      id: '2',
      name: 'Sony A7 IV',
      price: 55000000,
      stock: 5,
    ),
  ];

  final tCategories = [
    const CategoryEntity(id: 'c1', name: 'Mirrorless'),
    const CategoryEntity(id: 'c2', name: 'DSLR'),
  ];

  final tBrands = [
    const BrandEntity(id: 'b1', name: 'Canon'),
    const BrandEntity(id: 'b2', name: 'Sony'),
  ];

  group('ProductBloc', () {
    test('initial state is correct', () {
      expect(productBloc.state, const ProductState());
      expect(productBloc.state.status, ProductStatus.initial);
      expect(productBloc.state.products, isEmpty);
    });

    // ── ProductLoadRequested ─────────────────────────────
    group('ProductLoadRequested', () {
      blocTest<ProductBloc, ProductState>(
        'emits [loading, loaded] when getProducts succeeds',
        build: () {
          when(() => mockRepository.getProducts(
                search: any(named: 'search'),
                category: any(named: 'category'),
                brand: any(named: 'brand'),
                minPrice: any(named: 'minPrice'),
                maxPrice: any(named: 'maxPrice'),
                sort: any(named: 'sort'),
              )).thenAnswer((_) async => tProducts);
          return ProductBloc(mockRepository);
        },
        act: (bloc) => bloc.add(const ProductLoadRequested()),
        expect: () => [
          const ProductState(status: ProductStatus.loading),
          ProductState(status: ProductStatus.loaded, products: tProducts),
        ],
        verify: (_) {
          verify(() => mockRepository.getProducts(
                search: any(named: 'search'),
                category: any(named: 'category'),
                brand: any(named: 'brand'),
                minPrice: any(named: 'minPrice'),
                maxPrice: any(named: 'maxPrice'),
                sort: any(named: 'sort'),
              )).called(1);
        },
      );

      blocTest<ProductBloc, ProductState>(
        'emits [loading, error] when getProducts throws ServerFailure',
        build: () {
          when(() => mockRepository.getProducts(
                search: any(named: 'search'),
                category: any(named: 'category'),
                brand: any(named: 'brand'),
                minPrice: any(named: 'minPrice'),
                maxPrice: any(named: 'maxPrice'),
                sort: any(named: 'sort'),
              )).thenThrow(const ServerFailure('Lỗi server'));
          return ProductBloc(mockRepository);
        },
        act: (bloc) => bloc.add(const ProductLoadRequested()),
        expect: () => [
          const ProductState(status: ProductStatus.loading),
          const ProductState(
            status: ProductStatus.error,
            errorMessage: 'Lỗi server',
          ),
        ],
      );

      blocTest<ProductBloc, ProductState>(
        'emits [loading, error] with generic message when getProducts throws unknown error',
        build: () {
          when(() => mockRepository.getProducts(
                search: any(named: 'search'),
                category: any(named: 'category'),
                brand: any(named: 'brand'),
                minPrice: any(named: 'minPrice'),
                maxPrice: any(named: 'maxPrice'),
                sort: any(named: 'sort'),
              )).thenThrow(Exception('random error'));
          return ProductBloc(mockRepository);
        },
        act: (bloc) => bloc.add(const ProductLoadRequested()),
        expect: () => [
          const ProductState(status: ProductStatus.loading),
          const ProductState(
            status: ProductStatus.error,
            errorMessage: 'Đã có lỗi xảy ra khi tải sản phẩm',
          ),
        ],
      );
    });

    // ── ProductSearchChanged ─────────────────────────────
    group('ProductSearchChanged', () {
      blocTest<ProductBloc, ProductState>(
        'emits [loading, loaded] when search succeeds',
        build: () {
          when(() => mockRepository.getProducts(
                search: any(named: 'search'),
                category: any(named: 'category'),
                brand: any(named: 'brand'),
                minPrice: any(named: 'minPrice'),
                maxPrice: any(named: 'maxPrice'),
                sort: any(named: 'sort'),
              )).thenAnswer((_) async => [tProducts.first]);
          return ProductBloc(mockRepository);
        },
        act: (bloc) => bloc.add(const ProductSearchChanged('Canon')),
        expect: () => [
          const ProductState(
            status: ProductStatus.loading,
            searchQuery: 'Canon',
          ),
          ProductState(
            status: ProductStatus.loaded,
            searchQuery: 'Canon',
            products: [tProducts.first],
          ),
        ],
      );
    });

    // ── CategoriesLoadRequested ──────────────────────────
    group('CategoriesLoadRequested', () {
      blocTest<ProductBloc, ProductState>(
        'emits state with categories and brands when load succeeds',
        build: () {
          when(() => mockRepository.getCategories())
              .thenAnswer((_) async => tCategories);
          when(() => mockRepository.getBrands())
              .thenAnswer((_) async => tBrands);
          return ProductBloc(mockRepository);
        },
        act: (bloc) => bloc.add(CategoriesLoadRequested()),
        expect: () => [
          ProductState(categories: tCategories, brands: tBrands),
        ],
      );

      blocTest<ProductBloc, ProductState>(
        'emits nothing when categories load fails (silent)',
        build: () {
          when(() => mockRepository.getCategories())
              .thenThrow(Exception('error'));
          return ProductBloc(mockRepository);
        },
        act: (bloc) => bloc.add(CategoriesLoadRequested()),
        expect: () => [],
      );
    });
  });
}
