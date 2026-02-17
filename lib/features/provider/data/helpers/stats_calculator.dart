import '../../../booking/data/models/booking_model.dart';
import '../../domain/entities/provider_stats.dart';
import '../../data/models/provider_stats_model.dart';

class StatsCalculator {
  static ProviderStatsModel calculateFromBookings(List<BookingModel> bookings) {
    int totalOrders = bookings.length;
    int pendingOrders = 0;
    int confirmedOrders = 0;
    int completedOrders = 0;
    int totalEarnings = 0;

    for (final booking in bookings) {
      final status = booking.status.toUpperCase().trim();
      
      if (status == 'PENDING') {
        pendingOrders++;
      } else if (status == 'CONFIRMED') {
        confirmedOrders++;
      } else if (status == 'COMPLETED') {
        completedOrders++;
        
        final price = booking.service?['price'] ?? 
                     booking.service?['basePrice'] ?? 
                     booking.service?['priceRs'] ?? 
                     0;
        final priceInt = price is int ? price : (price is num ? price.toInt() : 0);
        totalEarnings += priceInt;
      }
    }

    return ProviderStatsModel(
      totalOrders: totalOrders,
      pendingOrders: pendingOrders,
      confirmedOrders: confirmedOrders,
      completedOrders: completedOrders,
      totalEarnings: totalEarnings,
      averageRating: 0.0,
      totalReviews: 0,
    );
  }
}
