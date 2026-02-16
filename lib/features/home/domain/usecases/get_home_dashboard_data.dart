import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/service_category.dart';
import '../entities/popular_service.dart';
import '../repositories/home_repository.dart';

class GetHomeDashboardData {
  final HomeRepository repository;

  GetHomeDashboardData(this.repository);

  Future<Either<Failure, HomeDashboardData>> call() async {
    final mostBookedResult = await repository.getMostBookedServices();
    final popularResult = await repository.getPopularServices();

    return mostBookedResult.fold(
      (failure) => Left(failure),
      (mostBooked) async {
        return popularResult.fold(
          (failure) => Left(failure),
          (popular) => Right(HomeDashboardData(
            mostBookedServices: mostBooked,
            popularServices: popular,
          )),
        );
      },
    );
  }
}

class HomeDashboardData {
  final List<ServiceCategory> mostBookedServices;
  final List<PopularService> popularServices;

  const HomeDashboardData({
    required this.mostBookedServices,
    required this.popularServices,
  });
}
