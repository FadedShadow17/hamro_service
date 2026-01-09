import '../../domain/entities/service_option.dart';
import '../../domain/entities/time_slot.dart';

abstract class BookingLocalDataSource {
  Future<List<ServiceOption>> getServiceOptions(String serviceId);
  Future<List<TimeSlot>> getAvailableTimeSlots(DateTime date);
}

class BookingLocalDataSourceImpl implements BookingLocalDataSource {
  @override
  Future<List<ServiceOption>> getServiceOptions(String serviceId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return const [
      ServiceOption(
        id: 'deep_cleaning',
        name: 'Deep cleaning',
        price: 120.0,
        duration: '3 hours',
      ),
      ServiceOption(
        id: 'kitchen_only',
        name: 'Kitchen only',
        price: 80.0,
        duration: '2 hours',
      ),
      ServiceOption(
        id: 'full_apartment',
        name: 'Full apartment',
        price: 200.0,
        duration: '5 hours',
      ),
    ];
  }

  @override
  Future<List<TimeSlot>> getAvailableTimeSlots(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    return const [
      TimeSlot(id: '10:00', time: '10:00 AM', isAvailable: true),
      TimeSlot(id: '11:00', time: '11:00 AM', isAvailable: true),
      TimeSlot(id: '12:00', time: '12:00 PM', isAvailable: true),
      TimeSlot(id: '13:00', time: '1:00 PM', isAvailable: true),
      TimeSlot(id: '14:00', time: '2:00 PM', isAvailable: true),
      TimeSlot(id: '15:00', time: '3:00 PM', isAvailable: true),
      TimeSlot(id: '16:00', time: '4:00 PM', isAvailable: true),
      TimeSlot(id: '17:00', time: '5:00 PM', isAvailable: true),
    ];
  }
}
