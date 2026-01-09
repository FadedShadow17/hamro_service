import 'package:equatable/equatable.dart';

class TimeSlot extends Equatable {
  final String id;
  final String time; // e.g., "10:00 AM"
  final bool isAvailable;

  const TimeSlot({
    required this.id,
    required this.time,
    this.isAvailable = true,
  });

  @override
  List<Object?> get props => [id, time, isAvailable];
}
