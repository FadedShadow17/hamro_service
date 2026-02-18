import '../../domain/entities/payment_entity.dart';
import '../../../../core/utils/pricing_helper.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.bookingId,
    required super.serviceName,
    required super.date,
    required super.timeSlot,
    required super.area,
    required super.amount,
    required super.status,
    super.paymentStatus,
    super.paymentMethod,
    super.paidAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    final booking = json['booking'] ?? json;
    final service = booking['service'] is Map
        ? Map<String, dynamic>.from(booking['service'])
        : null;

    final serviceName = service?['name'] ?? service?['title'] ?? 'Service';
    final categoryTag = service?['category']?['name'] ?? 
                       service?['categoryName'] ?? 
                       service?['category'] ?? '';
    final rawAmount = booking['totalPrice'] ?? 
                     booking['serviceOptionPrice'] ??
                     service?['totalPrice'] ??
                     service?['serviceOptionPrice'] ??
                     service?['price'] ?? 
                     service?['basePrice'] ??
                     service?['priceRs'] ??
                     0.0;
    final amount = PricingHelper.getPriceWithFallback(rawAmount, categoryTag);

    return PaymentModel(
      bookingId: booking['_id'] ?? booking['id'] ?? '',
      serviceName: serviceName,
      date: booking['date'] ?? '',
      timeSlot: booking['timeSlot'] ?? '',
      area: booking['area'] ?? '',
      amount: amount,
      status: booking['status'] ?? 'PENDING',
      paymentStatus: booking['paymentStatus'],
      paymentMethod: booking['paymentMethod'],
      paidAt: booking['paidAt'] != null ? DateTime.parse(booking['paidAt']) : null,
    );
  }

  PaymentEntity toEntity() {
    return PaymentEntity(
      bookingId: bookingId,
      serviceName: serviceName,
      date: date,
      timeSlot: timeSlot,
      area: area,
      amount: amount,
      status: status,
      paymentStatus: paymentStatus,
      paymentMethod: paymentMethod,
      paidAt: paidAt,
    );
  }
}
