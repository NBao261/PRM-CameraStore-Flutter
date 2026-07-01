import '../../domain/entities/store_entity.dart';

class StoreModel extends StoreEntity {
  const StoreModel({
    required super.id,
    required super.name,
    required super.address,
    required super.phone,
    required super.openingHours,
    required super.latitude,
    required super.longitude,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      openingHours: json['openingHours'] ?? '8:00 – 21:00',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }
}
