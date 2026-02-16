import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/connectivity/connectivity_service.dart';
import '../../domain/entities/provider_order.dart';
import '../../domain/entities/provider_stats.dart';
import '../../domain/repositories/provider_repository.dart';
import '../datasources/provider_local_datasource.dart';
import '../datasources/provider_remote_datasource.dart';
import '../models/provider_dashboard_model.dart';

class ProviderRepositoryImpl implements ProviderRepository {
  final ProviderRemoteDataSource remoteDataSource;
  final ProviderLocalDataSource localDataSource;
  final ConnectivityService connectivityService;

  ProviderRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
  });

  @override
  Future<Either<Failure, ProviderStats>> getProviderStats() async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (hasInternet) {
      try {
        final dashboard = await remoteDataSource.getDashboardSummary();
        return Right(dashboard.stats.toEntity());
      } catch (e) {
        try {
          final model = await localDataSource.getProviderStats();
          return Right(model.toEntity());
        } catch (localError) {
          return Left(CacheFailure(e.toString()));
        }
      }
    } else {
      try {
        final model = await localDataSource.getProviderStats();
        return Right(model.toEntity());
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<ProviderOrder>>> getPendingOrders() async {
    return getProviderBookings(status: 'PENDING');
  }

  @override
  Future<Either<Failure, List<ProviderOrder>>> getActiveOrders() async {
    return getProviderBookings(status: 'CONFIRMED');
  }

  @override
  Future<Either<Failure, List<ProviderOrder>>> getRecentOrders() async {
    return getProviderBookings();
  }

  @override
  Future<Either<Failure, List<ProviderOrder>>> getProviderBookings({String? status}) async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (hasInternet) {
      try {
        final models = await remoteDataSource.getProviderBookings(status: status);
        return Right(models.map((model) => model.toEntity()).toList());
      } catch (e) {
        try {
          if (status == 'PENDING' || status == null) {
            final models = await localDataSource.getPendingOrders();
            return Right(models.map((model) => model.toEntity()).toList());
          } else if (status == 'CONFIRMED' || status == 'in_progress') {
            final models = await localDataSource.getActiveOrders();
            return Right(models.map((model) => model.toEntity()).toList());
          } else {
            final models = await localDataSource.getRecentOrders();
            return Right(models.map((model) => model.toEntity()).toList());
          }
        } catch (localError) {
          return Left(CacheFailure(e.toString()));
        }
      }
    } else {
      try {
        if (status == 'PENDING' || status == null) {
          final models = await localDataSource.getPendingOrders();
          return Right(models.map((model) => model.toEntity()).toList());
        } else if (status == 'CONFIRMED' || status == 'in_progress') {
          final models = await localDataSource.getActiveOrders();
          return Right(models.map((model) => model.toEntity()).toList());
        } else {
          final models = await localDataSource.getRecentOrders();
          return Right(models.map((model) => model.toEntity()).toList());
        }
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }
}
