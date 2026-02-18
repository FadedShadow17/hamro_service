import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/connectivity/connectivity_service.dart';
import '../../domain/entities/service_item.dart';
import '../../domain/repositories/services_repository.dart';
import '../datasources/services_local_datasource.dart';
import '../datasources/services_remote_datasource.dart';
import '../models/service_item_model.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  final ServicesRemoteDataSource remoteDataSource;
  final ServicesLocalDataSource localDataSource;
  final ConnectivityService connectivityService;

  ServicesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
  });

  @override
  Future<Either<Failure, List<ServiceItem>>> getServicesByCategory(String categoryIdOrName) async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (hasInternet) {
      try {
        final models = await remoteDataSource.getServices();
        final filtered = categoryIdOrName.toLowerCase() == 'all' 
            ? models 
            : models.where((s) => 
                s.categoryTag.toLowerCase() == categoryIdOrName.toLowerCase() ||
                s.id == categoryIdOrName
              ).toList();
        return Right(filtered.map((model) => model.toEntity()).toList());
      } catch (e) {
        try {
          final items = await localDataSource.getServicesByCategory(categoryIdOrName);
          return Right(items);
        } catch (localError) {
          return Left(CacheFailure(e.toString()));
        }
      }
    } else {
      try {
        final items = await localDataSource.getServicesByCategory(categoryIdOrName);
        return Right(items);
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAvailableProviders({
    required String serviceId,
    required String date,
    required String area,
  }) async {
    try {
      return await remoteDataSource.getAvailableProviders(
        serviceId: serviceId,
        date: date,
        area: area,
      );
    } catch (e) {
      return [];
    }
  }
}
