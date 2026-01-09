import '../entities/provider_order.dart';
import '../entities/provider_stats.dart';
import '../repositories/provider_repository.dart';

class GetProviderDashboardData {
  final ProviderRepository repository;

  GetProviderDashboardData(this.repository);

  Future<ProviderDashboardData> call() async {
    final stats = await repository.getProviderStats();
    final pendingOrders = await repository.getPendingOrders();
    final activeOrders = await repository.getActiveOrders();
    final recentOrders = await repository.getRecentOrders();
    
    return ProviderDashboardData(
      stats: stats,
      pendingOrders: pendingOrders,
      activeOrders: activeOrders,
      recentOrders: recentOrders,
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
