import '../entities/service_option.dart';
import '../entities/time_slot.dart';

abstract class BookingRepository {
  Future<List<ServiceOption>> getServiceOptions(String serviceId);
  Future<List<TimeSlot>> getAvailableTimeSlots(DateTime date);
}
