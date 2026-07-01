import 'package:equatable/equatable.dart';

class ChatMessageEntity extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String content;
  final String conversationId;
  final DateTime createdAt;

  const ChatMessageEntity({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.content,
    required this.conversationId,
    required this.createdAt,
  });

  @override
  List<Object> get props => [id, senderId, senderName, senderRole, content, conversationId, createdAt];
}
