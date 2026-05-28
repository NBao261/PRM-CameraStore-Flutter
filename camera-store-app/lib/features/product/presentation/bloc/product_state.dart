import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';

enum ProductStatus { initial, loading, loaded, error }

class ProductState extends Equatable {
  final ProductStatus status;
  final List<ProductEntity> products;
  final List<CategoryEntity> categories;
  final String? errorMessage;
  final String? searchQuery;
  final String? selectedCategory;
  final double? minPrice;
  final double? maxPrice;

  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.categories = const [],
    this.errorMessage,
    this.searchQuery,
    this.selectedCategory,
    this.minPrice,
    this.maxPrice,
  });

  bool get hasActiveFilters =>
      (selectedCategory != null && selectedCategory!.isNotEmpty) ||
      minPrice != null ||
      maxPrice != null;

  ProductState copyWith({
    ProductStatus? status,
    List<ProductEntity>? products,
    List<CategoryEntity>? categories,
    String? errorMessage,
    String? searchQuery,
    String? selectedCategory,
    double? minPrice,
    double? maxPrice,
    bool clearCategory = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
    );
  }

  @override
  List<Object?> get props => [
        status, products, categories, errorMessage,
        searchQuery, selectedCategory, minPrice, maxPrice,
      ];
}
