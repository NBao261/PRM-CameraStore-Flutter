import 'package:equatable/equatable.dart';

class ProductSpecs extends Equatable {
  final String megapixel;
  final String sensor;
  final String isoRange;
  final String lensType;
  final String video;
  final String connectivity;
  final String battery;
  final String weight;

  const ProductSpecs({
    this.megapixel = '',
    this.sensor = '',
    this.isoRange = '',
    this.lensType = '',
    this.video = '',
    this.connectivity = '',
    this.battery = '',
    this.weight = '',
  });

  @override
  List<Object?> get props => [
        megapixel, sensor, isoRange, lensType,
        video, connectivity, battery, weight,
      ];
}

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String? brandName;
  final String? brandId;
  final String? categoryName;
  final String? categoryId;
  final List<String> images;
  final double price;
  final double? salePrice;
  final String description;
  final ProductSpecs specs;
  final int stock;
  final bool isActive;
  final String? warranty;
  final DateTime? createdAt;

  const ProductEntity({
    required this.id,
    required this.name,
    this.brandName,
    this.brandId,
    this.categoryName,
    this.categoryId,
    this.images = const [],
    required this.price,
    this.salePrice,
    this.description = '',
    this.specs = const ProductSpecs(),
    this.stock = 0,
    this.isActive = true,
    this.warranty,
    this.createdAt,
  });

  bool get inStock => stock > 0;

  String get displayPrice {
    if (salePrice != null && salePrice! > 0 && salePrice! < price) {
      return _formatCurrency(salePrice!);
    }
    return _formatCurrency(price);
  }

  String get originalPrice => _formatCurrency(price);

  bool get hasDiscount => salePrice != null && salePrice! > 0 && salePrice! < price;

  String get firstImage => images.isNotEmpty ? images.first : '';

  static String _formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return '${formatted}đ';
  }

  @override
  List<Object?> get props => [id, name, price, stock];
}

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String? slug;

  const CategoryEntity({
    required this.id,
    required this.name,
    this.slug,
  });

  @override
  List<Object?> get props => [id, name];
}

class BrandEntity extends Equatable {
  final String id;
  final String name;
  final String? slug;

  const BrandEntity({
    required this.id,
    required this.name,
    this.slug,
  });

  @override
  List<Object?> get props => [id, name];
}
