import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  final String bookingId;
  final String serviceName;
  final String date;
  final String timeSlot;
  final String area;
  final double amount;
  final String status;
  final String? paymentStatus;
  final String? paymentMethod;
  final DateTime? paidAt;

  const PaymentEntity({
    required this.bookingId,
    required this.serviceName,
    required this.date,
    required this.timeSlot,
    required this.area,
    required this.amount,
    required this.status,
    this.paymentStatus,
    this.paymentMethod,
    this.paidAt,
  });

  @override
  List<Object?> get props => [
        bookingId,
        serviceName,
        date,
        timeSlot,
        area,
        amount,
        status,
        paymentStatus,
        paymentMethod,
        paidAt,
      ];
}
