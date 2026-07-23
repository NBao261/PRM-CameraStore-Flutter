import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  });

  Future<void> verifyOtp({
    required String email,
    required String otp,
  });

  Future<UserEntity> login({
    required String email,
    required String password,
  });

  Future<UserEntity> getProfile();

  Future<UserEntity> updateProfile({
    String? fullName,
    String? phone,
    String? address,
  });

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<void> logout();

  Future<bool> isLoggedIn();

  Future<void> forgotPassword(String email);

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });
}
