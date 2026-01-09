import '../entities/service_category.dart';
import '../entities/popular_service.dart';
import '../repositories/home_repository.dart';

/// Use case to get home dashboard data
class GetHomeDashboardData {
  final HomeRepository repository;

  GetHomeDashboardData(this.repository);

  Future<HomeDashboardData> call() async {
    final mostBooked = await repository.getMostBookedServices();
    final popular = await repository.getPopularServices();
    return HomeDashboardData(
      mostBookedServices: mostBooked,
      popularServices: popular,
    );
  }
}

/// Home dashboard data model
class HomeDashboardData {
  final List<ServiceCategory> mostBookedServices;
  final List<PopularService> popularServices;

  const HomeDashboardData({
    required this.mostBookedServices,
    required this.popularServices,
  });
}
