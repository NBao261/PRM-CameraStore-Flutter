import '../../domain/entities/chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.senderId,
    required super.senderName,
    required super.senderRole,
    required super.content,
    required super.conversationId,
    required super.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    // sender can be a populated object or just an ID string
    final sender = json['sender'];
    String senderId;
    String senderName;

    if (sender is Map<String, dynamic>) {
      senderId = sender['_id'] ?? '';
      senderName = sender['fullName'] ?? 'Hỗ trợ';
    } else {
      senderId = sender?.toString() ?? '';
      senderName = 'Người dùng';
    }

    return ChatMessageModel(
      id: json['_id'] ?? '',
      senderId: senderId,
      senderName: senderName,
      senderRole: json['senderRole'] ?? 'user',
      content: json['content'] ?? '',
      conversationId: json['conversationId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
