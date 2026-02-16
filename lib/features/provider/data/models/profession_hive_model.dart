import 'package:hive/hive.dart';
import '../../../../core/constants/hive_table_constant.dart';

part 'profession_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.professionHiveModelTypeId)
class ProfessionHiveModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final bool active;

  ProfessionHiveModel({
    required this.id,
    required this.name,
    this.description,
    required this.active,
  });

  ProfessionHiveModel copyWith({
    String? id,
    String? name,
    String? description,
    bool? active,
  }) {
    return ProfessionHiveModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      active: active ?? this.active,
    );
  }
}
