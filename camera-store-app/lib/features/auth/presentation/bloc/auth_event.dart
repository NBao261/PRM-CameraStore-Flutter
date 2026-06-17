import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String phone;
  final String password;

  const AuthRegisterRequested({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [fullName, email, phone, password];
}

class AuthVerifyOtpRequested extends AuthEvent {
  final String email;
  final String otp;

  const AuthVerifyOtpRequested({
    required this.email,
    required this.otp,
  });

  @override
  List<Object> get props => [email, otp];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthProfileUpdateRequested extends AuthEvent {
  final String? fullName;
  final String? phone;
  final String? address;

  const AuthProfileUpdateRequested({
    this.fullName,
    this.phone,
    this.address,
  });

  @override
  List<Object?> get props => [fullName, phone, address];
}

class AuthPasswordChangeRequested extends AuthEvent {
  final String oldPassword;
  final String newPassword;

  const AuthPasswordChangeRequested({
    required this.oldPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [oldPassword, newPassword];
}
