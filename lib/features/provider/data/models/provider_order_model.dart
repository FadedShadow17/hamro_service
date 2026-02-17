import '../../domain/entities/provider_order.dart';

class ProviderOrderModel extends ProviderOrder {
  const ProviderOrderModel({
    required super.id,
    required super.customerName,
    required super.serviceName,
    required super.status,
    required super.priceRs,
    required super.location,
    required super.createdAt,
    super.scheduledDate,
    super.paymentStatus,
  });

  factory ProviderOrderModel.fromEntity(ProviderOrder order) {
    return ProviderOrderModel(
      id: order.id,
      customerName: order.customerName,
      serviceName: order.serviceName,
      status: order.status,
      priceRs: order.priceRs,
      location: order.location,
      createdAt: order.createdAt,
      scheduledDate: order.scheduledDate,
      paymentStatus: order.paymentStatus,
    );
  }

  ProviderOrder toEntity() {
    return ProviderOrder(
      id: id,
      customerName: customerName,
      serviceName: serviceName,
      status: status,
      priceRs: priceRs,
      location: location,
      createdAt: createdAt,
      scheduledDate: scheduledDate,
      paymentStatus: paymentStatus,
    );
  }
}
