import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/app_config.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  
  // Stream controller to broadcast new notifications
  final _notificationController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get notificationStream => _notificationController.stream;

  void connect(String userId) {
    if (_socket != null && _socket!.connected) return;

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
    });

    _socket?.on('new_notification', (data) {
      if (data is Map<String, dynamic>) {
        _notificationController.add(data);
      }
    });

    _socket?.onDisconnect((_) {
      print('🔴 Socket disconnected');
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _notificationController.close();
  }
}
