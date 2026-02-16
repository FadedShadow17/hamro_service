import '../models/provider_stats_model.dart';

class ProviderDashboardModel {
  final ProviderStatsModel stats;
  final Map<String, dynamic>? additionalData;

  ProviderDashboardModel({
    required this.stats,
    this.additionalData,
  });

  factory ProviderDashboardModel.fromJson(Map<String, dynamic> json) {
    return ProviderDashboardModel(
      stats: ProviderStatsModel(
        totalOrders: json['totalOrders'] ?? json['totalBookings'] ?? 0,
        pendingOrders: json['pendingOrders'] ?? json['pendingBookings'] ?? 0,
        completedOrders: json['completedOrders'] ?? json['completedBookings'] ?? 0,
        totalEarnings: (json['totalEarnings'] ?? 0.0).toDouble(),
        averageRating: (json['averageRating'] ?? 0.0).toDouble(),
        totalReviews: json['totalReviews'] ?? 0,
      ),
      additionalData: json,
    );
  }
}
