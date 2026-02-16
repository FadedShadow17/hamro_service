import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/service_item.dart';

abstract class ServicesRepository {
  Future<Either<Failure, List<ServiceItem>>> getServicesByCategory(String categoryIdOrName);
}
