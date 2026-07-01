import 'package:equatable/equatable.dart';

enum AdminChatStatus { initial, loading, loaded, sending, error }

class AdminChatState extends Equatable {
  final AdminChatStatus status;
  final List<Map<String, dynamic>> conversations;
  final List<Map<String, dynamic>> messages;
  final String? currentConversationId;
  final String? errorMessage;

  const AdminChatState({
    this.status = AdminChatStatus.initial,
    this.conversations = const [],
    this.messages = const [],
    this.currentConversationId,
    this.errorMessage,
  });

  AdminChatState copyWith({
    AdminChatStatus? status,
    List<Map<String, dynamic>>? conversations,
    List<Map<String, dynamic>>? messages,
    String? currentConversationId,
    String? errorMessage,
  }) {
    return AdminChatState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      currentConversationId: currentConversationId ?? this.currentConversationId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, conversations, messages, currentConversationId, errorMessage];
}
