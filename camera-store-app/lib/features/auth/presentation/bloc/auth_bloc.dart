import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthState()) {
    on<AuthCheckRequested>(_onCheckStatus);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthVerifyOtpRequested>(_onVerifyOtpRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthProfileUpdateRequested>(_onProfileUpdateRequested);
    on<AuthPasswordChangeRequested>(_onPasswordChangeRequested);
  }

  Future<void> _onCheckStatus(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authRepository.getProfile();
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ));
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Đã có lỗi xảy ra. Vui lòng thử lại.',
      ));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _authRepository.register(
        fullName: event.fullName,
        email: event.email,
        phone: event.phone,
        password: event.password,
      );
      emit(state.copyWith(status: AuthStatus.otpSent));
    } on Failure catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Đã có lỗi xảy ra. Vui lòng thử lại.',
      ));
    }
  }

  Future<void> _onVerifyOtpRequested(
    AuthVerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _authRepository.verifyOtp(
        email: event.email,
        otp: event.otp,
      );
      emit(state.copyWith(status: AuthStatus.registered));
    } on Failure catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Đã có lỗi xảy ra. Vui lòng thử lại.',
      ));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> _onProfileUpdateRequested(
    AuthProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final updatedUser = await _authRepository.updateProfile(
        fullName: event.fullName,
        phone: event.phone,
        address: event.address,
      );
      emit(state.copyWith(
        status: AuthStatus.profileUpdateSuccess,
        user: updatedUser,
      ));
      // Revert status to authenticated
      emit(state.copyWith(status: AuthStatus.authenticated));
    } on Failure catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: e.message));
      emit(state.copyWith(status: AuthStatus.authenticated));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Đã có lỗi xảy ra khi cập nhật hồ sơ.',
      ));
      emit(state.copyWith(status: AuthStatus.authenticated));
    }
  }

  Future<void> _onPasswordChangeRequested(
    AuthPasswordChangeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _authRepository.changePassword(
        oldPassword: event.oldPassword,
        newPassword: event.newPassword,
      );
      emit(state.copyWith(status: AuthStatus.passwordChangeSuccess));
      // Revert status to authenticated
      emit(state.copyWith(status: AuthStatus.authenticated));
    } on Failure catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: e.message));
      emit(state.copyWith(status: AuthStatus.authenticated));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Đã có lỗi xảy ra khi đổi mật khẩu.',
      ));
      emit(state.copyWith(status: AuthStatus.authenticated));
    }
  }
}
