import '../../domain/entities/service_category.dart';

class ServiceCategoryModel extends ServiceCategory {
  const ServiceCategoryModel({
    required super.id,
    required super.name,
    required super.iconKey,
  });

  factory ServiceCategoryModel.fromEntity(ServiceCategory category) {
    return ServiceCategoryModel(
      id: category.id,
      name: category.name,
      iconKey: category.iconKey,
    );
  }

  ServiceCategory toEntity() {
    return ServiceCategory(
      id: id,
      name: name,
      iconKey: iconKey,
    );
  }
}
