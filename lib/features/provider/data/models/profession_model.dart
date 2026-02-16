import '../../domain/entities/profession_entity.dart';
import 'profession_hive_model.dart';

class ProfessionModel extends ProfessionEntity {
  const ProfessionModel({
    required super.id,
    required super.name,
    super.description,
    required super.active,
  });

  factory ProfessionModel.fromJson(Map<String, dynamic> json) {
    return ProfessionModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      active: json['active'] ?? true,
    );
  }

  ProfessionEntity toEntity() {
    return ProfessionEntity(
      id: id,
      name: name,
      description: description,
      active: active,
    );
  }

  ProfessionHiveModel toHiveModel() {
    return ProfessionHiveModel(
      id: id,
      name: name,
      description: description,
      active: active,
    );
  }

  factory ProfessionModel.fromHiveModel(ProfessionHiveModel hiveModel) {
    return ProfessionModel(
      id: hiveModel.id,
      name: hiveModel.name,
      description: hiveModel.description,
      active: hiveModel.active,
    );
  }
}
