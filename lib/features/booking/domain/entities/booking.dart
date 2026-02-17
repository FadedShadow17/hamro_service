import 'package:equatable/equatable.dart';

class Booking extends Equatable {
  final String id;
  final String userId;
  final String? providerId;
  final String serviceId;
  final String serviceName;
  final String? serviceOptionId;
  final DateTime selectedDate;
  final String selectedTimeSlot;
  final String address;
  final String area;
  final String status;
  final String? notes;
  final double totalPrice;
  final String? paymentStatus;
  final DateTime? paidAt;
  final String? paymentMethod;
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? provider;
  final Map<String, dynamic>? service;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Booking({
    required this.id,
    required this.userId,
    this.providerId,
    required this.serviceId,
    required this.serviceName,
    this.serviceOptionId,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.address,
    required this.area,
    required this.status,
    this.notes,
    required this.totalPrice,
    this.paymentStatus,
    this.paidAt,
    this.paymentMethod,
    this.user,
    this.provider,
    this.service,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        providerId,
        serviceId,
        serviceName,
        serviceOptionId,
        selectedDate,
        selectedTimeSlot,
        address,
        area,
        status,
        notes,
        totalPrice,
        paymentStatus,
        paidAt,
        paymentMethod,
        user,
        provider,
        service,
        createdAt,
        updatedAt,
      ];
}
