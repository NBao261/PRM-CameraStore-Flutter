import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';

enum ProductStatus { initial, loading, loaded, error }

class ProductState extends Equatable {
  final ProductStatus status;
  final List<ProductEntity> products;
  final List<CategoryEntity> categories;
  final List<BrandEntity> brands;
  final String? errorMessage;
  final String? searchQuery;
  final String? selectedCategory;
  final String? selectedBrand;
  final double? minPrice;
  final double? maxPrice;
  final String? sortOption;

  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.categories = const [],
    this.brands = const [],
    this.errorMessage,
    this.searchQuery,
    this.selectedCategory,
    this.selectedBrand,
    this.minPrice,
    this.maxPrice,
    this.sortOption,
  });

  bool get hasActiveFilters =>
      (selectedCategory != null && selectedCategory!.isNotEmpty) ||
      (selectedBrand != null && selectedBrand!.isNotEmpty) ||
      minPrice != null ||
      maxPrice != null;

  ProductState copyWith({
    ProductStatus? status,
    List<ProductEntity>? products,
    List<CategoryEntity>? categories,
    List<BrandEntity>? brands,
    String? errorMessage,
    String? searchQuery,
    String? selectedCategory,
    String? selectedBrand,
    double? minPrice,
    double? maxPrice,
    bool clearCategory = false,
    bool clearBrand = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    String? sortOption,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      brands: brands ?? this.brands,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedBrand:
          clearBrand ? null : (selectedBrand ?? this.selectedBrand),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      sortOption: sortOption ?? this.sortOption,
    );
  }

  @override
  List<Object?> get props => [
        status, products, categories, brands, errorMessage,
        searchQuery, selectedCategory, selectedBrand, minPrice, maxPrice, sortOption,
      ];
}
