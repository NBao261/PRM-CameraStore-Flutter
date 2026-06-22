import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/socket_service.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repository;
  StreamSubscription? _socketSubscription;

  NotificationBloc(this._repository) : super(const NotificationState()) {
    on<NotificationLoadRequested>(_onLoadRequested);
    on<NotificationMarkAsReadRequested>(_onMarkAsReadRequested);
    on<NotificationMarkAllAsReadRequested>(_onMarkAllAsReadRequested);

    _socketSubscription = SocketService().notificationStream.listen((_) {
      add(NotificationLoadRequested());
    });
  }

  @override
  Future<void> close() {
    _socketSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadRequested(
    NotificationLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: NotificationStatus.loading));
    try {
      final notifications = await _repository.getNotifications();
      emit(state.copyWith(
        status: NotificationStatus.loaded,
        notifications: notifications,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(status: NotificationStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.error,
        errorMessage: 'Đã có lỗi xảy ra khi tải thông báo',
      ));
    }
  }

  Future<void> _onMarkAsReadRequested(
    NotificationMarkAsReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _repository.markAsRead(event.id);
      add(NotificationLoadRequested());
    } on Failure catch (e) {
      emit(state.copyWith(status: NotificationStatus.error, errorMessage: e.message));
    }
  }

  Future<void> _onMarkAllAsReadRequested(
    NotificationMarkAllAsReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _repository.markAllAsRead();
      add(NotificationLoadRequested());
    } on Failure catch (e) {
      emit(state.copyWith(status: NotificationStatus.error, errorMessage: e.message));
    }
  }
}
