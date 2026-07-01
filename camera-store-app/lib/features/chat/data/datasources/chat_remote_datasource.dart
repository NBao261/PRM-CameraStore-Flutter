import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/chat_message_model.dart';

class ChatRemoteDataSource {
  final ApiClient _apiClient;

  ChatRemoteDataSource(this._apiClient);

  Future<List<ChatMessageModel>> getChatHistory() async {
    final response = await _apiClient.dio.get(ApiEndpoints.chatHistory);
    final data = response.data['data'];

    // Handle paginated response
    final List messages = data is Map ? (data['messages'] ?? []) : (data ?? []);
    return messages.map((json) => ChatMessageModel.fromJson(json)).toList();
  }

  Future<ChatMessageModel> sendMessage(String content) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.chat,
      data: {'content': content},
    );
    return ChatMessageModel.fromJson(response.data['data']);
  }
}
