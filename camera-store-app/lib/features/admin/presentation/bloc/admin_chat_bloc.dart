import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/admin_repository.dart';
import 'admin_chat_event.dart';
import 'admin_chat_state.dart';

class AdminChatBloc extends Bloc<AdminChatEvent, AdminChatState> {
  final AdminRepository _repository;

  AdminChatBloc(this._repository) : super(const AdminChatState()) {
    on<AdminChatLoadConversations>(_onLoadConversations);
    on<AdminChatLoadMessages>(_onLoadMessages);
    on<AdminChatSendMessage>(_onSendMessage);
  }

  Future<void> _onLoadConversations(
    AdminChatLoadConversations event,
    Emitter<AdminChatState> emit,
  ) async {
    emit(state.copyWith(status: AdminChatStatus.loading));
    try {
      final data = await _repository.getConversations();
      final conversations = data
          .map((c) => Map<String, dynamic>.from(c as Map))
          .toList();
      emit(state.copyWith(
        status: AdminChatStatus.loaded,
        conversations: conversations,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AdminChatStatus.error,
        errorMessage: 'Không thể tải danh sách hội thoại',
      ));
    }
  }

  Future<void> _onLoadMessages(
    AdminChatLoadMessages event,
    Emitter<AdminChatState> emit,
  ) async {
    emit(state.copyWith(
      status: AdminChatStatus.loading,
      currentConversationId: event.conversationId,
    ));
    try {
      final data = await _repository.getConversationMessages(event.conversationId);
      final messages = (data['messages'] as List)
          .map((m) => Map<String, dynamic>.from(m as Map))
          .toList();
      emit(state.copyWith(
        status: AdminChatStatus.loaded,
        messages: messages,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AdminChatStatus.error,
        errorMessage: 'Không thể tải tin nhắn',
      ));
    }
  }

  Future<void> _onSendMessage(
    AdminChatSendMessage event,
    Emitter<AdminChatState> emit,
  ) async {
    emit(state.copyWith(status: AdminChatStatus.sending));
    try {
      final msgData = await _repository.sendAdminMessage(
        event.conversationId,
        event.content,
      );
      final updatedMessages = List<Map<String, dynamic>>.from(state.messages)
        ..add(Map<String, dynamic>.from(msgData));
      emit(state.copyWith(
        status: AdminChatStatus.loaded,
        messages: updatedMessages,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AdminChatStatus.error,
        errorMessage: 'Không thể gửi tin nhắn',
      ));
    }
  }
}
