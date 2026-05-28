import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource(this._apiClient);

  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    await _apiClient.dio.post(
      ApiEndpoints.register,
      data: {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );
  }

  /// Returns { token, user } from API
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data['data'];
    return {
      'token': data['token'] as String,
      'user': UserModel.fromJson(data['user']),
    };
  }

  Future<UserModel> getProfile() async {
    final response = await _apiClient.dio.get(ApiEndpoints.profile);
    return UserModel.fromJson(response.data['data']);
  }
}
