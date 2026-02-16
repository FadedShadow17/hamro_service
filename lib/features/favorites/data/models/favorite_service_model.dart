import '../../domain/entities/favorite_service.dart';

class FavoriteServiceModel extends FavoriteService {
  const FavoriteServiceModel({
    required super.id,
    required super.serviceId,
    required super.addedAt,
  });

  factory FavoriteServiceModel.fromJson(Map<String, dynamic> json) {
    return FavoriteServiceModel(
      id: json['id'] ?? '',
      serviceId: json['serviceId'] ?? '',
      addedAt: DateTime.parse(json['addedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  FavoriteService toEntity() {
    return FavoriteService(
      id: id,
      serviceId: serviceId,
      addedAt: addedAt,
    );
  }
}
