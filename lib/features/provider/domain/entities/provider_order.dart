class ProviderOrder {
  final String id;
  final String customerName;
  final String serviceName;
  final String status;
  final int priceRs;
  final String location;
  final DateTime createdAt;
  final DateTime? scheduledDate;
  final String? paymentStatus;

  const ProviderOrder({
    required this.id,
    required this.customerName,
    required this.serviceName,
    required this.status,
    required this.priceRs,
    required this.location,
    required this.createdAt,
    this.scheduledDate,
    this.paymentStatus,
  });
}
