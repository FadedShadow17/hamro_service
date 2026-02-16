import '../../domain/entities/availability_entity.dart';

class TimeSlotModel extends TimeSlotEntity {
  const TimeSlotModel({
    required super.start,
    required super.end,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      start: json['start'] ?? '',
      end: json['end'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
    };
  }

  TimeSlotEntity toEntity() {
    return TimeSlotEntity(
      start: start,
      end: end,
    );
  }
}

class DayAvailabilityModel extends DayAvailabilityEntity {
  const DayAvailabilityModel({
    required super.dayOfWeek,
    required super.timeSlots,
  });

  factory DayAvailabilityModel.fromJson(Map<String, dynamic> json) {
    final timeSlotsList = json['timeSlots'] as List? ?? [];
    return DayAvailabilityModel(
      dayOfWeek: json['dayOfWeek'] ?? 0,
      timeSlots: timeSlotsList
          .map((slot) => TimeSlotModel.fromJson(slot as Map<String, dynamic>) as TimeSlotEntity)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'timeSlots': timeSlots.map((slot) => (slot as TimeSlotModel).toJson()).toList(),
    };
  }

  DayAvailabilityEntity toEntity() {
    return DayAvailabilityEntity(
      dayOfWeek: dayOfWeek,
      timeSlots: timeSlots.map((slot) => TimeSlotEntity(start: slot.start, end: slot.end)).toList(),
    );
  }
}

class AvailabilityModel extends AvailabilityEntity {
  const AvailabilityModel({
    required super.weeklySchedule,
  });

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    final availability = json['availability'] ?? json;
    final scheduleList = availability['weeklySchedule'] as List? ?? [];
    
    return AvailabilityModel(
      weeklySchedule: scheduleList
          .map((day) => DayAvailabilityModel.fromJson(day as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weeklySchedule': weeklySchedule
          .map((day) => (day as DayAvailabilityModel).toJson())
          .toList(),
    };
  }

  AvailabilityEntity toEntity() {
    return AvailabilityEntity(
      weeklySchedule: weeklySchedule.map((day) {
        if (day is DayAvailabilityModel) {
          return day.toEntity();
        }
        return DayAvailabilityEntity(
          dayOfWeek: day.dayOfWeek,
          timeSlots: day.timeSlots.map((slot) => TimeSlotEntity(start: slot.start, end: slot.end)).toList(),
        );
      }).toList(),
    );
  }
}
