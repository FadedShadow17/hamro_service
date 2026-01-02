import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/storage/user_session_service.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_datasource.dart';
import '../models/profile_hive_model.dart';

/// Implementation of domain ProfileRepository using data layer
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDatasource _datasource;
  final UserSessionService _sessionService;

  ProfileRepositoryImpl({
    required ProfileDatasource datasource,
    required UserSessionService sessionService,
  })  : _datasource = datasource,
        _sessionService = sessionService;

  /// Convert ProfileHiveModel to ProfileEntity
  ProfileEntity _modelToEntity(ProfileHiveModel model) {
    return ProfileEntity(
      userId: model.userId,
      fullName: model.fullName,
      email: model.email,
      phoneNumber: model.phoneNumber,
      avatarUrl: model.avatarUrl,
      address: model.address,
    );
  }

  /// Convert ProfileEntity to ProfileHiveModel
  ProfileHiveModel _entityToModel(ProfileEntity entity) {
    return ProfileHiveModel(
      userId: entity.userId,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      avatarUrl: entity.avatarUrl,
      address: entity.address,
    );
  }

  @override
  Future<Either<Failure, ProfileEntity?>> getProfile() async {
    try {
      final userId = _sessionService.getCurrentUserId();
      if (userId == null) {
        return const Right(null);
      }

      final profile = await _datasource.getProfile(userId);
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

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile(
      ProfileEntity profile) async {
    try {
      final model = _entityToModel(profile);
      final updatedProfile = await _datasource.updateProfile(model);
      return Right(_modelToEntity(updatedProfile));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}

