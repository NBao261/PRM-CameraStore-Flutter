import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/socket_service.dart';
import '../../data/models/chat_message_model.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository;
  StreamSubscription? _chatSubscription;

  ChatBloc(this._repository) : super(const ChatState()) {
    on<ChatLoadHistory>(_onLoadHistory);
    on<ChatSendMessage>(_onSendMessage);
    on<ChatNewMessageReceived>(_onNewMessageReceived);
    on<ChatMarkAsRead>((event, emit) {
      emit(state.copyWith(unreadCount: 0));
    });

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
      emit(state.copyWith(
        status: ChatStatus.loaded,
        messages: messages,
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
}
