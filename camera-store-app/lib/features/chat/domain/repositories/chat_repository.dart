import '../entities/chat_message_entity.dart';

abstract class ChatRepository {
  Future<List<ChatMessageEntity>> getChatHistory();
  Future<ChatMessageEntity> sendMessage(String content);
}
