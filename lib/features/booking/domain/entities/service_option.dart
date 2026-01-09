import 'package:equatable/equatable.dart';

class ServiceOption extends Equatable {
  final String id;
  final String name;
  final double price;
  final String duration; // e.g., "3 hours"

  const ServiceOption({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
  });

  @override
  List<Object?> get props => [id, name, price, duration];
}
