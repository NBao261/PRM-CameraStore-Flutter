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
        'confirmPassword': password,
      },
    );
  }

  Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    await _apiClient.dio.post(
      ApiEndpoints.verifyOtp,
      data: {
        'email': email,
        'otp': otp,
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

  Future<UserModel> updateProfile({
    String? fullName,
    String? phone,
    String? address,
  }) async {
    final response = await _apiClient.dio.put(
      ApiEndpoints.profile,
      data: {
        if (fullName != null) 'fullName': fullName,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
      },
    );
    return UserModel.fromJson(response.data['data']);
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _apiClient.dio.put(
      ApiEndpoints.changePassword,
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );
  }
}
