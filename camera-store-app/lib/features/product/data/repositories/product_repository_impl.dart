import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ProductEntity>> getProducts({
    String? search,
    String? category,
    String? brand,
    double? minPrice,
    double? maxPrice,
    String? sort,
  }) async {
    try {
      return await _remoteDataSource.getProducts(
        search: search,
        category: category,
        brand: brand,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sort: sort,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ProductEntity> getProductById(String id) async {
    try {
      return await _remoteDataSource.getProductById(id);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<CategoryEntity>> getCategories() async {
    try {
      return await _remoteDataSource.getCategories();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<BrandEntity>> getBrands() async {
    try {
      return await _remoteDataSource.getBrands();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Failure _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }
    final message =
        e.response?.data?['message'] as String? ?? 'Đã có lỗi xảy ra';
    return ServerFailure(message);
  }
}
