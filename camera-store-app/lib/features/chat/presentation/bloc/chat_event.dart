import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatLoadHistory extends ChatEvent {
  const ChatLoadHistory();
}

class ChatSendMessage extends ChatEvent {
  final String content;

  const ChatSendMessage({required this.content});

  @override
  List<Object?> get props => [content];
}

class ChatNewMessageReceived extends ChatEvent {
  final Map<String, dynamic> messageData;

  const ChatNewMessageReceived({required this.messageData});

  @override
  List<Object?> get props => [messageData];
}

class ChatMarkAsRead extends ChatEvent {}
