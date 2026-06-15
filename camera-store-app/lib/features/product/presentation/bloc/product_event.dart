import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class ProductLoadRequested extends ProductEvent {
  final String? search;
  final String? category;
  final String? brand;
  final double? minPrice;
  final double? maxPrice;
  final String? sort;

  const ProductLoadRequested({
    this.search,
    this.category,
    this.brand,
    this.minPrice,
    this.maxPrice,
    this.sort,
  });

  @override
  List<Object?> get props => [search, category, brand, minPrice, maxPrice, sort];
}

class ProductSearchChanged extends ProductEvent {
  final String query;
  const ProductSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class ProductSortChanged extends ProductEvent {
  final String sortOption;
  const ProductSortChanged(this.sortOption);

  @override
  List<Object?> get props => [sortOption];
}

class ProductFilterApplied extends ProductEvent {
  final String? category;
  final String? brand;
  final double? minPrice;
  final double? maxPrice;
  final String? sort;

  const ProductFilterApplied({
    this.category,
    this.brand,
    this.minPrice,
    this.maxPrice,
    this.sort,
  });

  @override
  List<Object?> get props => [category, brand, minPrice, maxPrice, sort];
}

class CategoriesLoadRequested extends ProductEvent {}
