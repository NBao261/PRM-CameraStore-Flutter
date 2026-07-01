import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message_entity.dart';

enum ChatStatus { initial, loading, loaded, sending, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final List<ChatMessageEntity> messages;
  final String? errorMessage;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.errorMessage,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessageEntity>? messages,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, messages, errorMessage];
}
