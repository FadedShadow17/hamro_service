import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final String id;
  final String serviceId;
  final String serviceName;
  final double servicePrice;
  final String serviceOptionId;
  final String serviceOptionName;
  final double serviceOptionPrice;
  final String serviceOptionDuration;
  final DateTime selectedDate;
  final String selectedTimeSlot;
  final String address;
  final String? notes;
  final double totalPrice;

  const CartItem({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.servicePrice,
    required this.serviceOptionId,
    required this.serviceOptionName,
    required this.serviceOptionPrice,
    required this.serviceOptionDuration,
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
        servicePrice,
        serviceOptionId,
        serviceOptionName,
        serviceOptionPrice,
        serviceOptionDuration,
        selectedDate,
        selectedTimeSlot,
        address,
        notes,
        totalPrice,
      ];
}
