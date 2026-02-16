import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/service_category.dart';
import '../entities/popular_service.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<ServiceCategory>>> getMostBookedServices();
  Future<Either<Failure, List<PopularService>>> getPopularServices();
}
