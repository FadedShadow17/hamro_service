import '../../domain/entities/service_category.dart';
import '../../domain/entities/popular_service.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';

/// Implementation of HomeRepository
class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource localDataSource;

  HomeRepositoryImpl({required this.localDataSource});

  @override
  Future<List<ServiceCategory>> getMostBookedServices() async {
    final models = await localDataSource.getMostBookedServices();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<PopularService>> getPopularServices() async {
    final models = await localDataSource.getPopularServices();
    return models.map((model) => model.toEntity()).toList();
  }
}
