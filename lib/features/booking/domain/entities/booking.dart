import 'package:equatable/equatable.dart';

class Booking extends Equatable {
  final String id;
  final String serviceId;
  final String serviceName;
  final String serviceOptionId;
  final DateTime selectedDate;
  final String selectedTimeSlot;
  final String address;
  final String? notes;
  final double totalPrice;

  const Booking({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.serviceOptionId,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.address,
    this.notes,
    required this.totalPrice,
  });

  @override
  List<Object?> get props => [
        id,
        serviceId,
        serviceName,
        serviceOptionId,
        selectedDate,
        selectedTimeSlot,
        address,
        notes,
        totalPrice,
      ];
}
