import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/app_config.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  String? _currentUserId;
  
  // Stream controller to broadcast new notifications
  final _notificationController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get notificationStream => _notificationController.stream;

  // Stream controller to broadcast new chat messages
  final _chatMessageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get chatMessageStream => _chatMessageController.stream;

  void connect(String userId) {
    if (_socket != null && _socket!.connected) return;

    _currentUserId = userId;

    // Use the ApiClient base URL but change from http to ws (or just use http url, socket.io handles it)
    final url = AppConfig.apiBaseUrl.replaceAll('/api', '');

    _socket = IO.io(url, IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build()
    );

    _socket?.connect();

    _socket?.onConnect((_) {
      print('🟢 Socket connected');
      // Join the user's room
      _socket?.emit('join_user', userId);
      // Auto-join the user's chat conversation
      joinConversation('conv_$userId');
    });

    _socket?.on('new_notification', (data) {
      if (data is Map<String, dynamic>) {
        _notificationController.add(data);
      }
    });

    _socket?.on('new_message', (data) {
      if (data is Map<String, dynamic>) {
        _chatMessageController.add(data);
      }
    });

    _socket?.onDisconnect((_) {
      print('🔴 Socket disconnected');
    });
  }

  void joinConversation(String conversationId) {
    _socket?.emit('join_conversation', conversationId);
  }

  void joinAdminRoom() {
    _socket?.emit('join_admin');
  }

  void sendChatMessage({
    required String content,
    required String conversationId,
    String senderRole = 'user',
  }) {
    if (_currentUserId == null) return;
    _socket?.emit('send_message', {
      'senderId': _currentUserId,
      'content': content,
      'senderRole': senderRole,
      'conversationId': conversationId,
    });
  }

  void emitTyping({
    required String conversationId,
    required bool isTyping,
  }) {
    if (_currentUserId == null) return;
    _socket?.emit('typing', {
      'conversationId': conversationId,
      'userId': _currentUserId,
      'isTyping': isTyping,
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _currentUserId = null;
  }

  void dispose() {
    disconnect();
    _notificationController.close();
    _chatMessageController.close();
  }
}
