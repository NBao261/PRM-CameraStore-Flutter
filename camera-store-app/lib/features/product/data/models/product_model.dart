import '../../domain/entities/product_entity.dart';

class ProductModel {
  static ProductEntity fromJson(Map<String, dynamic> json) {
    return ProductEntity(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      brandName: _extractPopulatedName(json['brand']),
      brandId: _extractPopulatedId(json['brand']),
      categoryName: _extractPopulatedName(json['category']),
      categoryId: _extractPopulatedId(json['category']),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      price: (json['price'] ?? 0).toDouble(),
      salePrice: json['salePrice'] != null
          ? (json['salePrice']).toDouble()
          : null,
      description: json['description'] ?? '',
      specs: _parseSpecs(json['specs']),
      stock: json['stock'] ?? 0,
      isActive: json['isActive'] ?? true,
      warranty: json['warranty'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  static ProductSpecs _parseSpecs(Map<String, dynamic>? specs) {
    if (specs == null) return const ProductSpecs();
    return ProductSpecs(
      megapixel: specs['megapixel'] ?? '',
      sensor: specs['sensor'] ?? '',
      isoRange: specs['isoRange'] ?? '',
      lensType: specs['lensType'] ?? '',
      video: specs['video'] ?? '',
      connectivity: specs['connectivity'] ?? '',
      battery: specs['battery'] ?? '',
      weight: specs['weight'] ?? '',
    );
  }

  static String? _extractPopulatedName(dynamic field) {
    if (field is Map<String, dynamic>) {
      return field['name'];
    }
    return null;
  }

  static String? _extractPopulatedId(dynamic field) {
    if (field is Map<String, dynamic>) {
      return field['_id']?.toString() ?? field['id']?.toString();
    }
    if (field is String) return field;
    return null;
  }
}

class CategoryModel {
  static CategoryEntity fromJson(Map<String, dynamic> json) {
    return CategoryEntity(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      slug: json['slug'],
    );
  }
}
