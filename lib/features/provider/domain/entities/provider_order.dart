class ProviderOrder {
  final String id;
  final String customerName;
  final String serviceName;
  final String status; // pending, accepted, in_progress, completed, cancelled
  final int priceRs;
  final String location;
  final DateTime createdAt;
  final DateTime? scheduledDate;

  const ProviderOrder({
    required this.id,
    required this.customerName,
    required this.serviceName,
    required this.status,
    required this.priceRs,
    required this.location,
    required this.createdAt,
    this.scheduledDate,
  });
}
