import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/service_option.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../../services/domain/entities/service_item.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  throw UnimplementedError('bookingRepositoryProvider must be overridden');
});

class BookingState {
  final ServiceItem? service;
  final List<ServiceOption> serviceOptions;
  final ServiceOption? selectedServiceOption;
  final DateTime? selectedDate;
  final List<TimeSlot> availableTimeSlots;
  final TimeSlot? selectedTimeSlot;
  final String? address;
  final String? area;
  final String? notes;
  final bool isLoadingTimeSlots;

  BookingState({
    this.service,
    this.serviceOptions = const [],
    this.selectedServiceOption,
    this.selectedDate,
    this.availableTimeSlots = const [],
    this.selectedTimeSlot,
    this.address,
    this.area,
    this.notes,
    this.isLoadingTimeSlots = false,
  });

  BookingState copyWith({
    ServiceItem? service,
    List<ServiceOption>? serviceOptions,
    ServiceOption? selectedServiceOption,
    DateTime? selectedDate,
    List<TimeSlot>? availableTimeSlots,
    TimeSlot? selectedTimeSlot,
    String? address,
    String? area,
    String? notes,
    bool? isLoadingTimeSlots,
  }) {
    return BookingState(
      service: service ?? this.service,
      serviceOptions: serviceOptions ?? this.serviceOptions,
      selectedServiceOption: selectedServiceOption ?? this.selectedServiceOption,
      selectedDate: selectedDate ?? this.selectedDate,
      availableTimeSlots: availableTimeSlots ?? this.availableTimeSlots,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      address: address ?? this.address,
      area: area ?? this.area,
      notes: notes ?? this.notes,
      isLoadingTimeSlots: isLoadingTimeSlots ?? this.isLoadingTimeSlots,
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
    if (state.service != null && state.area != null && state.area!.isNotEmpty) {
      await loadTimeSlotsFromAPI(date, state.area!);
    } else {
      await loadTimeSlots(date);
    }
  }

  Future<void> loadTimeSlots(DateTime date) async {
    final timeSlots = await repository.getAvailableTimeSlots(date);
    state = state.copyWith(availableTimeSlots: timeSlots);
  }

  Future<void> loadTimeSlotsFromAPI(DateTime date, String area) async {
    if (state.service == null) return;

    state = state.copyWith(isLoadingTimeSlots: true);
    
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    final result = await repository.getAvailableTimeSlotsFromAPI(
      serviceId: state.service!.id,
      date: dateStr,
      area: area,
    );

    final timeSlotsResult = result.fold(
      (failure) => null,
      (timeSlots) => timeSlots,
    );

    if (timeSlotsResult != null) {
      state = state.copyWith(
        availableTimeSlots: timeSlotsResult,
        isLoadingTimeSlots: false,
      );
    } else {
      final fallbackSlots = await repository.getAvailableTimeSlots(date);
      state = state.copyWith(
        availableTimeSlots: fallbackSlots,
        isLoadingTimeSlots: false,
      );
    }
  }

  void updateArea(String area) {
    state = state.copyWith(area: area);
    if (state.selectedDate != null) {
      loadTimeSlotsFromAPI(state.selectedDate!, area);
    }
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
