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

  const ProductLoadRequested({
    this.search,
    this.category,
    this.brand,
    this.minPrice,
    this.maxPrice,
  });

  @override
  List<Object?> get props => [search, category, brand, minPrice, maxPrice];
}

class ProductSearchChanged extends ProductEvent {
  final String query;
  const ProductSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class ProductFilterApplied extends ProductEvent {
  final String? category;
  final double? minPrice;
  final double? maxPrice;

  const ProductFilterApplied({
    this.category,
    this.minPrice,
    this.maxPrice,
  });

  @override
  List<Object?> get props => [category, minPrice, maxPrice];
}

class CategoriesLoadRequested extends ProductEvent {}
