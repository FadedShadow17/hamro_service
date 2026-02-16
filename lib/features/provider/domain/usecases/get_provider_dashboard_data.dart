import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/provider_order.dart';
import '../entities/provider_stats.dart';
import '../repositories/provider_repository.dart';

class GetProviderDashboardData {
  final ProviderRepository repository;

  GetProviderDashboardData(this.repository);

  Future<Either<Failure, ProviderDashboardData>> call() async {
    final statsResult = await repository.getProviderStats();
    final pendingResult = await repository.getPendingOrders();
    final activeResult = await repository.getActiveOrders();
    final recentResult = await repository.getRecentOrders();

    return statsResult.fold(
      (failure) => Left(failure),
      (stats) async {
        return pendingResult.fold(
          (failure) => Left(failure),
          (pending) async {
            return activeResult.fold(
              (failure) => Left(failure),
              (active) async {
                return recentResult.fold(
                  (failure) => Left(failure),
                  (recent) => Right(ProviderDashboardData(
                    stats: stats,
                    pendingOrders: pending,
                    activeOrders: active,
                    recentOrders: recent,
                  )),
                );
              },
            );
          },
        );
      },
    );
  }
}

class ProviderDashboardData {
  final ProviderStats stats;
  final List<ProviderOrder> pendingOrders;
  final List<ProviderOrder> activeOrders;
  final List<ProviderOrder> recentOrders;

  const ProviderDashboardData({
    required this.stats,
    required this.pendingOrders,
    required this.activeOrders,
    required this.recentOrders,
  });
}
