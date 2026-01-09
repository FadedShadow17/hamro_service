import '../../domain/entities/time_slot.dart';

class TimeSlotModel extends TimeSlot {
  const TimeSlotModel({
    required super.id,
    required super.time,
    super.isAvailable = true,
  });

  factory TimeSlotModel.fromEntity(TimeSlot entity) {
    return TimeSlotModel(
      id: entity.id,
      time: entity.time,
      isAvailable: entity.isAvailable,
    );
  }
}
