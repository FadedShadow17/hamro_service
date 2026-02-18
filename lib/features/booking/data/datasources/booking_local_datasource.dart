import '../../domain/entities/service_option.dart';
import '../../domain/entities/time_slot.dart';

abstract class BookingLocalDataSource {
  Future<List<ServiceOption>> getServiceOptions(String serviceId, String categoryTag);
  Future<List<TimeSlot>> getAvailableTimeSlots(DateTime date);
}

class BookingLocalDataSourceImpl implements BookingLocalDataSource {
  @override
  Future<List<ServiceOption>> getServiceOptions(String serviceId, String categoryTag) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final category = categoryTag.toLowerCase();
    
    if (category.contains('cleaning') || category.contains('clean')) {
      return const [
        ServiceOption(
          id: 'basic_clean',
          name: 'Basic Clean',
          price: 5000.0,
          duration: '2 hours',
        ),
        ServiceOption(
          id: 'deep_clean',
          name: 'Deep Clean',
          price: 5000.0,
          duration: '4 hours',
        ),
        ServiceOption(
          id: 'premium_clean',
          name: 'Premium Clean',
          price: 5000.0,
          duration: '6 hours',
        ),
      ];
    } else if (category.contains('plumbing') || category.contains('plumber')) {
      return const [
        ServiceOption(
          id: 'quick_fix',
          name: 'Quick Fix',
          price: 5000.0,
          duration: '1 hour',
        ),
        ServiceOption(
          id: 'standard',
          name: 'Standard',
          price: 5000.0,
          duration: '2 hours',
        ),
        ServiceOption(
          id: 'complete',
          name: 'Complete',
          price: 5000.0,
          duration: '4 hours',
        ),
      ];
    } else if (category.contains('electrical') || category.contains('electric')) {
      return const [
        ServiceOption(
          id: 'basic',
          name: 'Basic',
          price: 5000.0,
          duration: '1 hour',
        ),
        ServiceOption(
          id: 'standard',
          name: 'Standard',
          price: 5000.0,
          duration: '2 hours',
        ),
        ServiceOption(
          id: 'full_service',
          name: 'Full Service',
          price: 5000.0,
          duration: '4 hours',
        ),
      ];
    } else if (category.contains('carpentry') || category.contains('carpenter')) {
      return const [
        ServiceOption(
          id: 'basic',
          name: 'Basic',
          price: 5000.0,
          duration: '2 hours',
        ),
        ServiceOption(
          id: 'standard',
          name: 'Standard',
          price: 5000.0,
          duration: '4 hours',
        ),
        ServiceOption(
          id: 'complete',
          name: 'Complete',
          price: 5000.0,
          duration: '6 hours',
        ),
      ];
    } else if (category.contains('painting') || category.contains('paint')) {
      return const [
        ServiceOption(
          id: 'single_room',
          name: 'Single Room',
          price: 5000.0,
          duration: '1 day',
        ),
        ServiceOption(
          id: 'multiple_rooms',
          name: 'Multiple Rooms',
          price: 5000.0,
          duration: '3 days',
        ),
        ServiceOption(
          id: 'full_house',
          name: 'Full House',
          price: 5000.0,
          duration: '7 days',
        ),
      ];
    } else {
      return const [
        ServiceOption(
          id: 'basic',
          name: 'Basic',
          price: 5000.0,
          duration: '1 hour',
        ),
        ServiceOption(
          id: 'standard',
          name: 'Standard',
          price: 5000.0,
          duration: '2 hours',
        ),
        ServiceOption(
          id: 'premium',
          name: 'Premium',
          price: 5000.0,
          duration: '4 hours',
        ),
      ];
    }
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
