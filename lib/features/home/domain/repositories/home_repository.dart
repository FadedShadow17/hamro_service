import '../entities/service_category.dart';
import '../entities/popular_service.dart';

abstract class HomeRepository {
  Future<List<ServiceCategory>> getMostBookedServices();
  Future<List<PopularService>> getPopularServices();
}
