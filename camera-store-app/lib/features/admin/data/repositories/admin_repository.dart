import '../datasources/admin_remote_datasource.dart';

class AdminRepository {
  final AdminRemoteDataSource _dataSource;

  AdminRepository(this._dataSource);

  // ── Dashboard ──────────────────────────────────────
  Future<Map<String, dynamic>> getDashboardStats() =>
      _dataSource.getDashboardStats();

  // ── Orders ─────────────────────────────────────────
  Future<Map<String, dynamic>> getAllOrders({
    String? status,
    int page = 1,
    int limit = 20,
  }) =>
      _dataSource.getAllOrders(status: status, page: page, limit: limit);

  Future<Map<String, dynamic>> updateOrderStatus(String orderId, String status) =>
      _dataSource.updateOrderStatus(orderId, status);

  // ── Chat ───────────────────────────────────────────
  Future<List<dynamic>> getConversations() =>
      _dataSource.getConversations();

  Future<Map<String, dynamic>> getConversationMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) =>
      _dataSource.getConversationMessages(conversationId, page: page, limit: limit);

  Future<Map<String, dynamic>> sendAdminMessage(
    String conversationId,
    String content,
  ) =>
      _dataSource.sendAdminMessage(conversationId, content);
}
