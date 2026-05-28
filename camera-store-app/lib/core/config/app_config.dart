class AppConfig {
  AppConfig._();

  // Đổi thành IP máy tính nếu test trên thiết bị thật
  // Dùng 10.0.2.2 cho Android Emulator
  static const String apiBaseUrl = 'http://10.0.2.2:5000/api';
  static const String appName = 'Camera Store';
}
