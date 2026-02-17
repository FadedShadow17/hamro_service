import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/connectivity/connectivity_service.dart';
import '../../../../core/services/storage/user_session_service.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_datasource.dart';
import '../datasources/remote/profile_remote_datasource.dart';
import '../models/profile_hive_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileDatasource localDatasource;
  final UserSessionService _sessionService;
  final ConnectivityService connectivityService;

  ProfileRepositoryImpl({
    required ProfileRemoteDataSource remoteDataSource,
    required ProfileDatasource localDatasource,
    required UserSessionService sessionService,
    required ConnectivityService connectivityService,
  })  : remoteDataSource = remoteDataSource,
        localDatasource = localDatasource,
        _sessionService = sessionService,
        connectivityService = connectivityService;

  ProfileEntity _modelToEntity(ProfileHiveModel model) {
    return ProfileEntity(
      userId: model.userId,
      fullName: model.fullName,
      email: model.email,
      phoneNumber: model.phoneNumber,
      avatarUrl: model.avatarUrl,
      address: model.address,
      description: model.description,
    );
  }

  ProfileHiveModel _entityToModel(ProfileEntity entity) {
    return ProfileHiveModel(
      userId: entity.userId,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      avatarUrl: entity.avatarUrl,
      address: entity.address,
      description: entity.description,
    );
  }

  @override
  Future<Either<Failure, ProfileEntity?>> getProfile() async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (hasInternet) {
      try {
        final profile = await remoteDataSource.getProfile();
        final userId = _sessionService.getCurrentUserId();
        if (userId != null) {
          final model = _entityToModel(profile);
          await localDatasource.updateProfile(model);
        }
        return Right(profile);
      } catch (e) {
        try {
          final userId = _sessionService.getCurrentUserId();
          if (userId != null) {
            final profile = await localDatasource.getProfile(userId);
            if (profile != null) {
              return Right(_modelToEntity(profile));
            }
          }
          return const Right(null);
        } catch (localError) {
          return Left(CacheFailure(e.toString()));
        }
      }
    } else {
      try {
        final userId = _sessionService.getCurrentUserId();
        if (userId == null) {
          return const Right(null);
        }
        final profile = await localDatasource.getProfile(userId);
        if (profile == null) {
          return const Right(null);
        }
        return Right(_modelToEntity(profile));
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile(
      ProfileEntity profile) async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (hasInternet) {
      try {
        final updatedProfile = await remoteDataSource.updateProfile(
          name: profile.fullName,
          phone: profile.phoneNumber,
          address: profile.address,
          description: profile.description,
        );
        final model = _entityToModel(updatedProfile);
        await localDatasource.updateProfile(model);
        return Right(updatedProfile);
      } catch (e) {
        try {
          final model = _entityToModel(profile);
          final updatedProfile = await localDatasource.updateProfile(model);
          return Right(_modelToEntity(updatedProfile));
        } catch (localError) {
          return Left(CacheFailure(e.toString()));
        }
      }
    } else {
      try {
        final model = _entityToModel(profile);
        final updatedProfile = await localDatasource.updateProfile(model);
        return Right(_modelToEntity(updatedProfile));
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateRole(String role) async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final updatedProfile = await remoteDataSource.updateRole(role);
      final model = _entityToModel(updatedProfile);
      await localDatasource.updateProfile(model);
      await _sessionService.saveRole(role);
      return Right(updatedProfile);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<Either<Failure, ProfileEntity>> uploadAvatar(File imageFile) async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final updatedProfile = await remoteDataSource.uploadAvatar(imageFile);
      final model = _entityToModel(updatedProfile);
      await localDatasource.updateProfile(model);
      return Right(updatedProfile);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}

