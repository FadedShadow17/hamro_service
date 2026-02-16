import 'package:equatable/equatable.dart';

class ProfessionEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final bool active;

  const ProfessionEntity({
    required this.id,
    required this.name,
    this.description,
    required this.active,
  });

  @override
  List<Object?> get props => [id, name, description, active];
}
