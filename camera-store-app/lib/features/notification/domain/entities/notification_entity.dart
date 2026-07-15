import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String content;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final String? relatedId;
  final String? relatedType;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.relatedId,
    this.relatedType,
  });

  @override
  List<Object?> get props => [id, title, content, type, isRead, createdAt, relatedId, relatedType];
}
