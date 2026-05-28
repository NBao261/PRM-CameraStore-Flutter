import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/product_model.dart';
import '../../domain/entities/product_entity.dart';

class ProductRemoteDataSource {
  final ApiClient _apiClient;

  ProductRemoteDataSource(this._apiClient);

  Future<List<ProductEntity>> getProducts({
    String? search,
    String? category,
    String? brand,
    double? minPrice,
    double? maxPrice,
  }) async {
    final queryParams = <String, dynamic>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (category != null && category.isNotEmpty) queryParams['category'] = category;
    if (brand != null && brand.isNotEmpty) queryParams['brand'] = brand;
    if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();

    final response = await _apiClient.dio.get(
      ApiEndpoints.products,
      queryParameters: queryParams,
    );

    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<ProductEntity> getProductById(String id) async {
    final response = await _apiClient.dio.get('${ApiEndpoints.products}/$id');
    final data = response.data['data'] ?? response.data;
    return ProductModel.fromJson(data);
  }

  Future<List<CategoryEntity>> getCategories() async {
    final response = await _apiClient.dio.get(ApiEndpoints.categories);
    final List<dynamic> data = response.data['data'] ?? response.data;
    return data.map((json) => CategoryModel.fromJson(json)).toList();
  }
}
