import '../../../booking/data/models/booking_model.dart';
import '../../domain/entities/provider_stats.dart';
import '../../data/models/provider_stats_model.dart';
import '../../../../core/utils/pricing_helper.dart';

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
        
        double price = 0.0;
        
        if (booking.service != null) {
          final categoryTag = booking.service?['category']?['name'] ?? 
                            booking.service?['categoryName'] ?? 
                            booking.service?['category'] ?? '';
          final rawPrice = booking.service?['totalPrice'] ?? 
                          booking.service?['serviceOptionPrice'] ??
                          booking.service?['price'] ?? 
                          booking.service?['basePrice'] ?? 
                          booking.service?['priceRs'] ?? 
                          0.0;
          price = PricingHelper.getPriceWithFallback(rawPrice, categoryTag);
        }
        
        totalEarnings += price.toInt();
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
