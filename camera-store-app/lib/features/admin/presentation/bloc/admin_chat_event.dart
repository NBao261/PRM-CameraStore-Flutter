import 'package:equatable/equatable.dart';

abstract class AdminChatEvent extends Equatable {
  const AdminChatEvent();
  @override
  List<Object?> get props => [];
}

class AdminChatLoadConversations extends AdminChatEvent {
  const AdminChatLoadConversations();
}

class AdminChatLoadMessages extends AdminChatEvent {
  final String conversationId;
  const AdminChatLoadMessages({required this.conversationId});
  @override
  List<Object?> get props => [conversationId];
}

class AdminChatSendMessage extends AdminChatEvent {
  final String conversationId;
  final String content;
  const AdminChatSendMessage({
    required this.conversationId,
    required this.content,
  });
  @override
  List<Object?> get props => [conversationId, content];
}
