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
    List<dynamic> upcoming = [];
    List<dynamic> recent = [];
    
    if (json.containsKey('upcoming')) {
      upcoming = json['upcoming'] is List ? json['upcoming'] as List<dynamic> : [];
    } else if (json.containsKey('upcomingBookings')) {
      upcoming = json['upcomingBookings'] is List ? json['upcomingBookings'] as List<dynamic> : [];
    }
    
    if (json.containsKey('recent')) {
      recent = json['recent'] is List ? json['recent'] as List<dynamic> : [];
    } else if (json.containsKey('recentBookings')) {
      recent = json['recentBookings'] is List ? json['recentBookings'] as List<dynamic> : [];
    }
    
    final total = json['total'] ?? 0;
    final pending = json['pending'] ?? 0;
    final confirmed = json['confirmed'] ?? 0;
    final completed = json['completed'] ?? 0;
    final earnings = json['totalEarnings'] ?? json['earnings'] ?? 0.0;
    final rating = (json['averageRating'] ?? json['rating'] ?? 0.0).toDouble();
    final reviews = json['totalReviews'] ?? json['reviews'] ?? 0;
    
    return ProviderDashboardModel(
      stats: ProviderStatsModel(
        totalOrders: total is int ? total : (total is num ? total.toInt() : 0),
        pendingOrders: pending is int ? pending : (pending is num ? pending.toInt() : 0),
        confirmedOrders: confirmed is int ? confirmed : (confirmed is num ? confirmed.toInt() : 0),
        completedOrders: completed is int ? completed : (completed is num ? completed.toInt() : 0),
        totalEarnings: earnings is int ? earnings : (earnings is num ? earnings.toInt() : 0),
        averageRating: rating,
        totalReviews: reviews is int ? reviews : (reviews is num ? reviews.toInt() : 0),
      ),
      upcomingBookings: upcoming.map((b) {
        try {
          return BookingModel.fromJson(b as Map<String, dynamic>);
        } catch (e) {
          return null;
        }
      }).whereType<BookingModel>().toList(),
      recentBookings: recent.map((b) {
        try {
          return BookingModel.fromJson(b as Map<String, dynamic>);
        } catch (e) {
          return null;
        }
      }).whereType<BookingModel>().toList(),
    );
  }
}
