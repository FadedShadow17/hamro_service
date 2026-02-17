import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/provider_order.dart';
import '../entities/provider_stats.dart';

abstract class ProviderRepository {
  Future<Either<Failure, ProviderStats>> getProviderStats();
  Future<Either<Failure, List<ProviderOrder>>> getPendingOrders();
  Future<Either<Failure, List<ProviderOrder>>> getActiveOrders();
  Future<Either<Failure, List<ProviderOrder>>> getRecentOrders();
  Future<Either<Failure, List<ProviderOrder>>> getProviderBookings({String? status});
  Future<Either<Failure, ProviderOrder>> acceptBooking(String bookingId);
  Future<Either<Failure, ProviderOrder>> declineBooking(String bookingId);
  Future<Either<Failure, ProviderOrder>> completeBooking(String bookingId);
  Future<Either<Failure, Map<String, dynamic>>> checkVerificationStatus();
}
