import '../models/provider_stats_model.dart';
import '../../../booking/data/models/booking_model.dart';

class ProviderDashboardModel {
  final ProviderStatsModel stats;
  final List<BookingModel> upcomingBookings;
  final List<BookingModel> recentBookings;

  ProviderDashboardModel({
    required this.stats,
    required this.upcomingBookings,
    required this.recentBookings,
  });

  factory ProviderDashboardModel.fromJson(Map<String, dynamic> json) {
    // Backend returns: { pending, confirmed, completed, total, upcoming: [...], recent: [...] }
    final upcoming = json['upcoming'] as List<dynamic>? ?? [];
    final recent = json['recent'] as List<dynamic>? ?? [];
    
    return ProviderDashboardModel(
      stats: ProviderStatsModel(
        totalOrders: json['total'] ?? 0,
        pendingOrders: json['pending'] ?? 0,
        completedOrders: json['completed'] ?? 0,
        totalEarnings: 0, // Backend doesn't provide earnings in summary
        averageRating: 0.0, // Backend doesn't provide rating in summary
        totalReviews: 0, // Backend doesn't provide reviews in summary
      ),
      upcomingBookings: upcoming.map((b) => BookingModel.fromJson(b as Map<String, dynamic>)).toList(),
      recentBookings: recent.map((b) => BookingModel.fromJson(b as Map<String, dynamic>)).toList(),
    );
  }
}
