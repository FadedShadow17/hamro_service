import '../../domain/repositories/booking_repository.dart';
import '../../domain/entities/service_option.dart';
import '../../domain/entities/time_slot.dart';
import '../datasources/booking_local_datasource.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingLocalDataSource datasource;

  BookingRepositoryImpl({required this.datasource});

  @override
  Future<List<ServiceOption>> getServiceOptions(String serviceId) {
    return datasource.getServiceOptions(serviceId);
  }

  @override
  Future<List<TimeSlot>> getAvailableTimeSlots(DateTime date) {
    return datasource.getAvailableTimeSlots(date);
  }
}
