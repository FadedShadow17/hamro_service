import '../entities/service_item.dart';
import '../repositories/services_repository.dart';

class GetServicesByCategory {
  final ServicesRepository repository;

  GetServicesByCategory(this.repository);

  Future<List<ServiceItem>> call(String categoryIdOrName) async {
    return await repository.getServicesByCategory(categoryIdOrName);
  }
}
