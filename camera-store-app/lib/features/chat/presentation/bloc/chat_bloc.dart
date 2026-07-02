import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/socket_service.dart';
import '../../data/models/chat_message_model.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository;
  final FlutterSecureStorage _storage;
  StreamSubscription? _chatSubscription;

  static const _lastReadKey = 'chat_last_read_at';

  ChatBloc(this._repository, {FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(),
        super(const ChatState()) {
    on<ChatLoadHistory>(_onLoadHistory);
    on<ChatSendMessage>(_onSendMessage);
    on<ChatNewMessageReceived>(_onNewMessageReceived);
    on<ChatMarkAsRead>(_onMarkAsRead);

    // Listen to real-time chat messages from socket
    _chatSubscription = SocketService().chatMessageStream.listen((data) {
      add(ChatNewMessageReceived(messageData: data));
    });
  }

  @override
  Future<void> close() {
    _chatSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadHistory(
    ChatLoadHistory event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      final messages = await _repository.getChatHistory();

      // Count unread: admin messages received after lastReadAt
      final lastReadStr = await _storage.read(key: _lastReadKey);
      DateTime? lastReadAt;
      if (lastReadStr != null) {
        lastReadAt = DateTime.tryParse(lastReadStr);
      }

      int unreadCount = 0;
      for (final msg in messages) {
        if (msg.senderRole != 'user') {
          if (lastReadAt == null || msg.createdAt.isAfter(lastReadAt)) {
            unreadCount++;
          }
        }
      }

      emit(state.copyWith(
        status: ChatStatus.loaded,
        messages: messages,
        unreadCount: unreadCount,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(status: ChatStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: 'Đã có lỗi xảy ra khi tải tin nhắn',
      ));
    }
  }

  Future<void> _onSendMessage(
    ChatSendMessage event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(status: ChatStatus.sending));
    try {
      final message = await _repository.sendMessage(event.content);

      // Check if the message already exists (from socket) to avoid duplicates
      final exists = state.messages.any((m) => m.id == message.id);
      final updatedMessages = exists
          ? state.messages
          : [...state.messages, message];

      emit(state.copyWith(
        status: ChatStatus.loaded,
        messages: updatedMessages,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(status: ChatStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: 'Không thể gửi tin nhắn. Vui lòng thử lại.',
      ));
    }
  }

  void _onNewMessageReceived(
    ChatNewMessageReceived event,
    Emitter<ChatState> emit,
  ) {
    try {
      final newMessage = ChatMessageModel.fromJson(event.messageData);

      int newUnreadCount = state.unreadCount;
      if (newMessage.senderRole != 'user') {
        newUnreadCount += 1;
      }

      // Avoid duplicates
      final exists = state.messages.any((m) => m.id == newMessage.id);
      if (!exists) {
        emit(state.copyWith(
          unreadCount: newUnreadCount,
          messages: [...state.messages, newMessage],
        ));
      } else {
        emit(state.copyWith(unreadCount: newUnreadCount));
      }
    } catch (_) {
      // Ignore malformed socket data
    }
  }

  Future<void> _onMarkAsRead(
    ChatMarkAsRead event,
    Emitter<ChatState> emit,
  ) async {
    // Persist the current time as lastReadAt so unread count survives restarts
    await _storage.write(
      key: _lastReadKey,
      value: DateTime.now().toIso8601String(),
    );
    emit(state.copyWith(unreadCount: 0));
  }
}
