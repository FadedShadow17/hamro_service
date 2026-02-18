import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamro_service/core/error/failures.dart';
import 'package:hamro_service/features/booking/domain/entities/service_option.dart';
import 'package:hamro_service/features/booking/domain/entities/time_slot.dart';
import 'package:hamro_service/features/booking/domain/repositories/booking_repository.dart';
import 'package:hamro_service/features/booking/presentation/providers/booking_provider.dart';
import 'package:hamro_service/features/services/domain/entities/service_item.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([BookingRepository])
import 'booking_provider_test.mocks.dart';

void main() {
  late BookingNotifier notifier;
  late MockBookingRepository mockRepository;

  setUp(() {
    mockRepository = MockBookingRepository();
  });

  final testServiceItem = ServiceItem(
    id: 'service1',
    title: 'Test Service',
    priceRs: 1000.0,
    rating: 4.5,
    reviewsCount: 100,
    categoryTag: 'Cleaning',
  );

  final testServiceOptions = [
    const ServiceOption(
      id: 'option1',
      name: 'Basic',
      price: 500.0,
      duration: '2 hours',
    ),
    const ServiceOption(
      id: 'option2',
      name: 'Premium',
      price: 1000.0,
      duration: '4 hours',
    ),
  ];

  final testTimeSlots = [
    const TimeSlot(id: '10:00', time: '10:00 AM', isAvailable: true),
    const TimeSlot(id: '11:00', time: '11:00 AM', isAvailable: true),
    const TimeSlot(id: '13:00', time: '1:00 PM', isAvailable: true),
  ];

  group('BookingNotifier', () {
    test('should initialize with empty state', () {
      final container = ProviderContainer(
        overrides: [
          bookingRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      
      final state = container.read(bookingProvider);
      expect(state.service, isNull);
      expect(state.serviceOptions, isEmpty);
      expect(state.selectedDate, isNull);
      container.dispose();
    });

    test('should initialize service and load service options', () async {
      when(mockRepository.getServiceOptions(any, any))
          .thenAnswer((_) async => testServiceOptions);

      final container = ProviderContainer(
        overrides: [
          bookingRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      
      await container.read(bookingProvider.notifier).initialize(testServiceItem);

      final state = container.read(bookingProvider);
      expect(state.service, testServiceItem);
      expect(state.serviceOptions, testServiceOptions);
      verify(mockRepository.getServiceOptions('service1', 'Cleaning')).called(1);
      container.dispose();
    });

    test('should select date and load time slots', () async {
      final testDate = DateTime(2024, 1, 15);
      when(mockRepository.getAvailableTimeSlots(any))
          .thenAnswer((_) async => testTimeSlots);

      final container = ProviderContainer(
        overrides: [
          bookingRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      
      await container.read(bookingProvider.notifier).selectDate(testDate);

      final state = container.read(bookingProvider);
      expect(state.selectedDate, testDate);
      expect(state.availableTimeSlots, testTimeSlots);
      verify(mockRepository.getAvailableTimeSlots(testDate)).called(1);
      container.dispose();
    });

    test('should select service option', () {
      final container = ProviderContainer(
        overrides: [
          bookingRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      
      container.read(bookingProvider.notifier).selectServiceOption(testServiceOptions.first);

      final state = container.read(bookingProvider);
      expect(state.selectedServiceOption, testServiceOptions.first);
      container.dispose();
    });

    test('should select time slot', () {
      final container = ProviderContainer(
        overrides: [
          bookingRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      
      container.read(bookingProvider.notifier).selectTimeSlot(testTimeSlots.first);

      final state = container.read(bookingProvider);
      expect(state.selectedTimeSlot, testTimeSlots.first);
      container.dispose();
    });
  });
}
