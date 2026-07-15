import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  AppConfig._();

  // Đổi thành IP máy tính nếu test trên thiết bị thật
  // Dùng 10.0.2.2 cho Android Emulator, localhost cho Web
  static const String baseUrl = kIsWeb ? 'http://localhost:5000' : 'http://10.0.2.2:5000';
  static const String apiBaseUrl = '$baseUrl/api';
  static const String appName = 'Camera Store';

  /// Build full image URL from relative path stored in DB
  static String getImageUrl(String path) {
    if (path.startsWith('http')) return path; // already absolute
    return '$baseUrl$path';
  }
}
