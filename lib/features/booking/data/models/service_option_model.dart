import '../../domain/entities/service_option.dart';

class ServiceOptionModel extends ServiceOption {
  const ServiceOptionModel({
    required super.id,
    required super.name,
    required super.price,
    required super.duration,
  });

  factory ServiceOptionModel.fromEntity(ServiceOption entity) {
    return ServiceOptionModel(
      id: entity.id,
      name: entity.name,
      price: entity.price,
      duration: entity.duration,
    );
  }
}
