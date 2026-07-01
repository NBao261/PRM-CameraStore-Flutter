import 'package:equatable/equatable.dart';

class StoreEntity extends Equatable {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String openingHours;
  final double latitude;
  final double longitude;

  const StoreEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.openingHours,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object> get props => [id, name, address, phone, openingHours, latitude, longitude];
}
