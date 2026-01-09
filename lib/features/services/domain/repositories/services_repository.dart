import '../entities/service_item.dart';

/// Services repository contract
abstract class ServicesRepository {
  Future<List<ServiceItem>> getServicesByCategory(String categoryIdOrName);
}
