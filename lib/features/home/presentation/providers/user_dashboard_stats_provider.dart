import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../booking/presentation/providers/booking_provider.dart';
import '../../../services/presentation/providers/services_list_provider.dart';

class UserDashboardStats {
  final int activeBookings; // PENDING + CONFIRMED
  final int completedBookings;
  final int availableServices;
  final int pendingPayments; // CONFIRMED + UNPAID

  UserDashboardStats({
    required this.activeBookings,
    required this.completedBookings,
    required this.availableServices,
    required this.pendingPayments,
  });
}

final userDashboardStatsProvider = FutureProvider<UserDashboardStats>((ref) async {
  final bookingRepository = ref.watch(bookingRepositoryProvider);
  final getServicesByCategory = ref.watch(getServicesByCategoryProvider);

  // Fetch all bookings
  final bookingsResult = await bookingRepository.getMyBookings();
  
  // Fetch all services
  final servicesResult = await getServicesByCategory('all');

  return bookingsResult.fold(
    (failure) {
      // Return default stats on error
      return servicesResult.fold(
        (_) => UserDashboardStats(
          activeBookings: 0,
          completedBookings: 0,
          availableServices: 0,
          pendingPayments: 0,
        ),
        (services) => UserDashboardStats(
          activeBookings: 0,
          completedBookings: 0,
          availableServices: services.length,
          pendingPayments: 0,
        ),
      );
    },
    (bookings) {
      // Calculate stats from bookings
      final activeBookings = bookings.where((b) => 
        b.status.toUpperCase() == 'PENDING' || 
        b.status.toUpperCase() == 'CONFIRMED'
      ).length;

      final completedBookings = bookings.where((b) => 
        b.status.toUpperCase() == 'COMPLETED'
      ).length;

      final pendingPayments = bookings.where((b) => 
        b.status.toUpperCase() == 'CONFIRMED' && 
        (b.paymentStatus?.toUpperCase() ?? 'UNPAID') == 'UNPAID'
      ).length;

      return servicesResult.fold(
        (_) => UserDashboardStats(
          activeBookings: activeBookings,
          completedBookings: completedBookings,
          availableServices: 0,
          pendingPayments: pendingPayments,
        ),
        (services) => UserDashboardStats(
          activeBookings: activeBookings,
          completedBookings: completedBookings,
          availableServices: services.length,
          pendingPayments: pendingPayments,
        ),
      );
    },
  );
});
