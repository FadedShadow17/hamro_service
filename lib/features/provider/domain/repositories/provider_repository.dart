import '../entities/provider_order.dart';
import '../entities/provider_stats.dart';

abstract class ProviderRepository {
  Future<ProviderStats> getProviderStats();
  Future<List<ProviderOrder>> getPendingOrders();
  Future<List<ProviderOrder>> getActiveOrders();
  Future<List<ProviderOrder>> getRecentOrders();
}
