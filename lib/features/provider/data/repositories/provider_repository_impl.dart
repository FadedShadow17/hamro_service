import '../../domain/entities/provider_order.dart';
import '../../domain/entities/provider_stats.dart';
import '../../domain/repositories/provider_repository.dart';
import '../datasources/provider_local_datasource.dart';

class ProviderRepositoryImpl implements ProviderRepository {
  final ProviderLocalDataSource localDataSource;

  ProviderRepositoryImpl({required this.localDataSource});

  @override
  Future<ProviderStats> getProviderStats() async {
    final model = await localDataSource.getProviderStats();
    return model.toEntity();
  }

  @override
  Future<List<ProviderOrder>> getPendingOrders() async {
    final models = await localDataSource.getPendingOrders();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<ProviderOrder>> getActiveOrders() async {
    final models = await localDataSource.getActiveOrders();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<ProviderOrder>> getRecentOrders() async {
    final models = await localDataSource.getRecentOrders();
    return models.map((model) => model.toEntity()).toList();
  }
}
