class ProviderStats {
  final int totalOrders;
  final int pendingOrders;
  final int confirmedOrders;
  final int completedOrders;
  final int totalEarnings;
  final double averageRating;
  final int totalReviews;

  const ProviderStats({
    required this.totalOrders,
    required this.pendingOrders,
    this.confirmedOrders = 0,
    required this.completedOrders,
    required this.totalEarnings,
    required this.averageRating,
    required this.totalReviews,
  });
}
