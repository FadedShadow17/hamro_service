import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/connectivity/connectivity_service.dart';
import '../../domain/entities/service_category.dart';
import '../../domain/entities/popular_service.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;
  final ConnectivityService connectivityService;

  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
  });

  @override
  Future<Either<Failure, List<ServiceCategory>>> getMostBookedServices() async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (hasInternet) {
      try {
        final models = await remoteDataSource.getServiceCategories();
        return Right(models.map((model) => model.toEntity()).toList());
      } catch (e) {
        try {
          final models = await localDataSource.getMostBookedServices();
          return Right(models.map((model) => model.toEntity()).toList());
        } catch (localError) {
          return Left(CacheFailure(e.toString()));
        }
      }
    } else {
      try {
        final models = await localDataSource.getMostBookedServices();
        return Right(models.map((model) => model.toEntity()).toList());
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<PopularService>>> getPopularServices() async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (hasInternet) {
      try {
        final models = await remoteDataSource.getPopularServices();
        return Right(models.map((model) => model.toEntity()).toList());
      } catch (e) {
        try {
          final models = await localDataSource.getPopularServices();
          return Right(models.map((model) => model.toEntity()).toList());
        } catch (localError) {
          return Left(CacheFailure(e.toString()));
        }
      }
    } else {
      try {
        final models = await localDataSource.getPopularServices();
        return Right(models.map((model) => model.toEntity()).toList());
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }
}
