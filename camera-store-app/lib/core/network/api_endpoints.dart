class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String register = '/auth/register';
  static const String verifyOtp = '/auth/verify-otp';
  static const String login = '/auth/login';
  static const String profile = '/auth/profile';

  // Products
  static const String products = '/products';

  // Categories
  static const String categories = '/categories';

  // Cart
  static const String cart = '/cart';

  // Orders
  static const String orders = '/orders';

  // Notifications
  static const String notifications = '/notifications';

  // Stores
  static const String stores = '/stores';

  // Chat
  static const String chat = '/chat';
  static const String chatHistory = '/chat/history';
}
