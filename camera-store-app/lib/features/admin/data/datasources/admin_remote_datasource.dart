import '../../../../core/network/api_client.dart';

class AdminRemoteDataSource {
  final ApiClient _apiClient;

  AdminRemoteDataSource(this._apiClient);

  // ── Dashboard ──────────────────────────────────────
  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _apiClient.dio.get('/admin/orders/dashboard');
    return response.data['data'] as Map<String, dynamic>;
  }

  // ── Orders ─────────────────────────────────────────
  Future<Map<String, dynamic>> getAllOrders({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    String url = '/admin/orders?page=$page&limit=$limit';
    if (status != null && status != 'all') url += '&status=$status';
    final response = await _apiClient.dio.get(url);
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateOrderStatus(String orderId, String status) async {
    final response = await _apiClient.dio.put(
      '/admin/orders/$orderId/status',
      data: {'status': status},
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  // ── Chat ───────────────────────────────────────────
  Future<List<dynamic>> getConversations() async {
    final response = await _apiClient.dio.get('/admin/chat/conversations');
    return response.data['data'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> getConversationMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _apiClient.dio.get(
      '/admin/chat/conversations/$conversationId?page=$page&limit=$limit',
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> sendAdminMessage(
    String conversationId,
    String content,
  ) async {
    final response = await _apiClient.dio.post(
      '/admin/chat/conversations/$conversationId',
      data: {'content': content},
    );
    return response.data['data'] as Map<String, dynamic>;
  }
}
