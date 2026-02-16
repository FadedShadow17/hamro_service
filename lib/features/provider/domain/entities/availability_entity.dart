import 'package:equatable/equatable.dart';

class TimeSlotEntity extends Equatable {
  final String start;
  final String end;

  const TimeSlotEntity({
    required this.start,
    required this.end,
  });

  @override
  List<Object?> get props => [start, end];
}

class DayAvailabilityEntity extends Equatable {
  final int dayOfWeek;
  final List<TimeSlotEntity> timeSlots;

  const DayAvailabilityEntity({
    required this.dayOfWeek,
    required this.timeSlots,
  });

  @override
  List<Object?> get props => [dayOfWeek, timeSlots];
}

class AvailabilityEntity extends Equatable {
  final List<DayAvailabilityEntity> weeklySchedule;

  const AvailabilityEntity({
    required this.weeklySchedule,
  });

  @override
  List<Object?> get props => [weeklySchedule];
}
