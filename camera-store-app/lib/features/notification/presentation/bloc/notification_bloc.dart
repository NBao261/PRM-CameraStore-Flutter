import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repository;

  NotificationBloc(this._repository) : super(const NotificationState()) {
    on<NotificationLoadRequested>(_onLoadRequested);
    on<NotificationMarkAsReadRequested>(_onMarkAsReadRequested);
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
}
