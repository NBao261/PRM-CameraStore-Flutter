class AppConfig {
  AppConfig._();

  // Đổi thành IP máy tính nếu test trên thiết bị thật
  // Dùng 10.0.2.2 cho Android Emulator
  static const String baseUrl = 'http://10.0.2.2:5000';
  static const String apiBaseUrl = '$baseUrl/api';
  static const String appName = 'Camera Store';

  /// Build full image URL from relative path stored in DB
  static String getImageUrl(String path) {
    if (path.startsWith('http')) return path; // already absolute
    return '$baseUrl$path';
  }
}
