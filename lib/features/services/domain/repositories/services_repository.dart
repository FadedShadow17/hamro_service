import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/service_item.dart';

abstract class ServicesRepository {
  Future<Either<Failure, List<ServiceItem>>> getServicesByCategory(String categoryIdOrName);
  Future<List<Map<String, dynamic>>> getAvailableProviders({
    required String serviceId,
    required String date,
    required String area,
  });
}
