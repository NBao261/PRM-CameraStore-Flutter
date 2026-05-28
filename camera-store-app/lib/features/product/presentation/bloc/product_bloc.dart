import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _repository;

  ProductBloc(this._repository) : super(const ProductState()) {
    on<ProductLoadRequested>(_onLoadRequested);
    on<ProductSearchChanged>(_onSearchChanged);
    on<ProductFilterApplied>(_onFilterApplied);
    on<CategoriesLoadRequested>(_onCategoriesLoad);
  }

  Future<void> _onLoadRequested(
    ProductLoadRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));
    try {
      final products = await _repository.getProducts(
        search: event.search ?? state.searchQuery,
        category: event.category ?? state.selectedCategory,
        brand: event.brand,
        minPrice: event.minPrice ?? state.minPrice,
        maxPrice: event.maxPrice ?? state.maxPrice,
      );
      emit(state.copyWith(
        status: ProductStatus.loaded,
        products: products,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: 'Đã có lỗi xảy ra khi tải sản phẩm',
      ));
    }
  }

  Future<void> _onSearchChanged(
    ProductSearchChanged event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(
      status: ProductStatus.loading,
      searchQuery: event.query,
    ));
    try {
      final products = await _repository.getProducts(
        search: event.query.isEmpty ? null : event.query,
        category: state.selectedCategory,
        minPrice: state.minPrice,
        maxPrice: state.maxPrice,
      );
      emit(state.copyWith(
        status: ProductStatus.loaded,
        products: products,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: 'Đã có lỗi xảy ra',
      ));
    }
  }

  Future<void> _onFilterApplied(
    ProductFilterApplied event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(
      status: ProductStatus.loading,
      selectedCategory: event.category,
      clearCategory: event.category == null,
      minPrice: event.minPrice,
      clearMinPrice: event.minPrice == null,
      maxPrice: event.maxPrice,
      clearMaxPrice: event.maxPrice == null,
    ));
    try {
      final products = await _repository.getProducts(
        search: state.searchQuery,
        category: event.category,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
      );
      emit(state.copyWith(
        status: ProductStatus.loaded,
        products: products,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        errorMessage: 'Đã có lỗi xảy ra',
      ));
    }
  }

  Future<void> _onCategoriesLoad(
    CategoriesLoadRequested event,
    Emitter<ProductState> emit,
  ) async {
    try {
      final categories = await _repository.getCategories();
      emit(state.copyWith(categories: categories));
    } catch (_) {
      // Silently fail - categories are optional for filtering
    }
  }
}
