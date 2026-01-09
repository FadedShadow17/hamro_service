import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/service_option.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../../services/domain/entities/service_item.dart';
import '../../data/datasources/booking_local_datasource.dart';
import '../../data/repositories/booking_repository_impl.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final datasource = BookingLocalDataSourceImpl();
  return BookingRepositoryImpl(datasource: datasource);
});

class BookingState {
  final ServiceItem? service;
  final List<ServiceOption> serviceOptions;
  final ServiceOption? selectedServiceOption;
  final DateTime? selectedDate;
  final List<TimeSlot> availableTimeSlots;
  final TimeSlot? selectedTimeSlot;
  final String? address;
  final String? notes;

  BookingState({
    this.service,
    this.serviceOptions = const [],
    this.selectedServiceOption,
    this.selectedDate,
    this.availableTimeSlots = const [],
    this.selectedTimeSlot,
    this.address,
    this.notes,
  });

  BookingState copyWith({
    ServiceItem? service,
    List<ServiceOption>? serviceOptions,
    ServiceOption? selectedServiceOption,
    DateTime? selectedDate,
    List<TimeSlot>? availableTimeSlots,
    TimeSlot? selectedTimeSlot,
    String? address,
    String? notes,
  }) {
    return BookingState(
      service: service ?? this.service,
      serviceOptions: serviceOptions ?? this.serviceOptions,
      selectedServiceOption: selectedServiceOption ?? this.selectedServiceOption,
      selectedDate: selectedDate ?? this.selectedDate,
      availableTimeSlots: availableTimeSlots ?? this.availableTimeSlots,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      address: address ?? this.address,
      notes: notes ?? this.notes,
    );
  }
}

class BookingNotifier extends Notifier<BookingState> {
  late final BookingRepository repository;

  @override
  BookingState build() {
    repository = ref.watch(bookingRepositoryProvider);
    return BookingState();
  }

  Future<void> initialize(ServiceItem service) async {
    state = state.copyWith(service: service);
    await loadServiceOptions(service.id);
  }

  Future<void> loadServiceOptions(String serviceId) async {
    final options = await repository.getServiceOptions(serviceId);
    state = state.copyWith(serviceOptions: options);
  }

  void selectServiceOption(ServiceOption option) {
    state = state.copyWith(selectedServiceOption: option);
  }

  Future<void> selectDate(DateTime date) async {
    state = state.copyWith(selectedDate: date);
    await loadTimeSlots(date);
  }

  Future<void> loadTimeSlots(DateTime date) async {
    final timeSlots = await repository.getAvailableTimeSlots(date);
    state = state.copyWith(availableTimeSlots: timeSlots);
  }

  void selectTimeSlot(TimeSlot timeSlot) {
    state = state.copyWith(selectedTimeSlot: timeSlot);
  }

  void updateAddress(String address) {
    state = state.copyWith(address: address);
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }
}

final bookingProvider = NotifierProvider<BookingNotifier, BookingState>(() {
  return BookingNotifier();
});
