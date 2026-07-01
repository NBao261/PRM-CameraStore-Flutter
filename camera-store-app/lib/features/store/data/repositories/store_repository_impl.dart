import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/store_entity.dart';
import '../../domain/repositories/store_repository.dart';
import '../datasources/store_remote_datasource.dart';

class StoreRepositoryImpl implements StoreRepository {
  final StoreRemoteDataSource _remoteDataSource;

  StoreRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<StoreEntity>> getStores() async {
    try {
      return await _remoteDataSource.getStores();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure();
      }
      final message = e.response?.data?['message'] as String? ?? 'Đã có lỗi xảy ra';
      throw ServerFailure(message);
    }
  }
}
