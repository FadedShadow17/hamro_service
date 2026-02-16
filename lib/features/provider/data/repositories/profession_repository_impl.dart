import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/connectivity/connectivity_service.dart';
import '../../domain/entities/profession_entity.dart';
import '../../domain/repositories/profession_repository.dart';
import '../datasources/profession_local_datasource.dart';
import '../datasources/profession_remote_datasource.dart';
import '../models/profession_model.dart';

class ProfessionRepositoryImpl implements ProfessionRepository {
  final ProfessionRemoteDataSource remoteDataSource;
  final ProfessionLocalDataSource localDataSource;
  final ConnectivityService connectivityService;

  ProfessionRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
  });

  @override
  Future<Either<Failure, List<ProfessionEntity>>> getAllProfessions() async {
    final hasInternet = await connectivityService.hasInternetConnection();

    if (hasInternet) {
      try {
        final models = await remoteDataSource.getAllProfessions();
        
        // Cache professions in local storage
        try {
          await localDataSource.saveProfessions(models);
        } catch (e) {
          // Silently fail caching - don't affect the main request
        }
        
        return Right(models.map((model) => model.toEntity()).toList());
      } catch (e) {
        // If remote fails, try to get from local storage
        try {
          final localModels = await localDataSource.getAllProfessions();
          if (localModels.isNotEmpty) {
            return Right(localModels.map((model) => model.toEntity()).toList());
          }
        } catch (localError) {
          return Left(ServerFailure(e.toString()));
        }
        return Left(ServerFailure(e.toString()));
      }
    } else {
      // No internet, get from local storage
      try {
        final localModels = await localDataSource.getAllProfessions();
        return Right(localModels.map((model) => model.toEntity()).toList());
      } catch (e) {
        return Left(CacheFailure('No internet connection and no cached professions available'));
      }
    }
  }
}
