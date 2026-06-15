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
    on<ProductSortChanged>(_onSortChanged);
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
        brand: event.brand ?? state.selectedBrand,
        minPrice: event.minPrice ?? state.minPrice,
        maxPrice: event.maxPrice ?? state.maxPrice,
        sort: event.sort ?? state.sortOption,
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
        brand: state.selectedBrand,
        minPrice: state.minPrice,
        maxPrice: state.maxPrice,
        sort: state.sortOption,
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
      selectedBrand: event.brand,
      clearBrand: event.brand == null,
      minPrice: event.minPrice,
      clearMinPrice: event.minPrice == null,
      maxPrice: event.maxPrice,
      clearMaxPrice: event.maxPrice == null,
      sortOption: event.sort,
    ));
    try {
      final products = await _repository.getProducts(
        search: state.searchQuery,
        category: event.category,
        brand: event.brand,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
        sort: event.sort ?? state.sortOption,
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

  Future<void> _onSortChanged(
    ProductSortChanged event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(
      status: ProductStatus.loading,
      sortOption: event.sortOption,
    ));
    try {
      final products = await _repository.getProducts(
        search: state.searchQuery,
        category: state.selectedCategory,
        brand: state.selectedBrand,
        minPrice: state.minPrice,
        maxPrice: state.maxPrice,
        sort: event.sortOption,
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
      final brands = await _repository.getBrands();
      emit(state.copyWith(categories: categories, brands: brands));
    } catch (_) {
      // Silently fail - categories are optional for filtering
    }
  }
}
