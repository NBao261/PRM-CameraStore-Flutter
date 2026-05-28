import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? avatar;
  final String? address;
  final String role;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.avatar,
    this.address,
    this.role = 'user',
  });

  @override
  List<Object?> get props => [id, fullName, email, phone, avatar, address, role];
}
