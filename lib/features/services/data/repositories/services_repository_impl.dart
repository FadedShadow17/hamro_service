import '../../domain/entities/service_item.dart';
import '../../domain/repositories/services_repository.dart';
import '../datasources/services_local_datasource.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  final ServicesLocalDataSource localDataSource;

  ServicesRepositoryImpl({required this.localDataSource});

  @override
  Future<List<ServiceItem>> getServicesByCategory(String categoryIdOrName) async {
    return await localDataSource.getServicesByCategory(categoryIdOrName);
  }
}
