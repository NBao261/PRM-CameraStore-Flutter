import '../../domain/entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts({
    String? search,
    String? category,
    String? brand,
    double? minPrice,
    double? maxPrice,
  });

  Future<ProductEntity> getProductById(String id);

  Future<List<CategoryEntity>> getCategories();
}
