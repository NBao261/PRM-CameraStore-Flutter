import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  });

  Future<UserEntity> login({
    required String email,
    required String password,
  });

  Future<UserEntity> getProfile();

  Future<void> logout();

  Future<bool> isLoggedIn();
}
