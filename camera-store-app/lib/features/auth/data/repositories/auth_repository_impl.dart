import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._remoteDataSource, this._apiClient);

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      await _remoteDataSource.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      // Save token to secure storage
      await _apiClient.saveToken(result['token'] as String);

      return result['user'] as UserEntity;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserEntity> getProfile() async {
    try {
      return await _remoteDataSource.getProfile();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> logout() async {
    await _apiClient.deleteToken();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _apiClient.hasToken();
  }

  Failure _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }

    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;
    String message = responseData?['message'] as String? ?? 'Đã có lỗi xảy ra';

    if (responseData?['errors'] != null && responseData?['errors'] is List) {
      final errors = responseData?['errors'] as List;
      if (errors.isNotEmpty && errors.first['msg'] != null) {
        message = errors.first['msg'] as String;
      }
    }

    if (statusCode == 401) {
      return UnauthorizedFailure(message);
    }
    if (statusCode == 409) {
      return ServerFailure(message);
    }

    return ServerFailure(message);
  }
}
