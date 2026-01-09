import '../entities/service_category.dart';
import '../entities/popular_service.dart';

/// Repository contract for home dashboard data
abstract class HomeRepository {
  Future<List<ServiceCategory>> getMostBookedServices();
  Future<List<PopularService>> getPopularServices();
}
