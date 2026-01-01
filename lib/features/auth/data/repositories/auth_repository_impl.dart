import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/storage/user_session_service.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';
import '../models/auth_hive_model.dart';

/// Implementation of domain AuthRepository using data layer
class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource _datasource;
  final UserSessionService _sessionService;
  final _uuid = const Uuid();

  AuthRepositoryImpl({
    required AuthDatasource datasource,
    required UserSessionService sessionService,
  })  : _datasource = datasource,
        _sessionService = sessionService;

  /// Convert AuthHiveModel to AuthEntity
  AuthEntity _modelToEntity(AuthHiveModel model) {
    return AuthEntity(
      authId: model.authId,
      fullName: model.fullName,
      email: model.email,
      username: model.username,
      phoneNumber: model.phoneNumber,
    );
  }

  @override
  Future<Either<Failure, AuthEntity>> register({
    required String fullName,
    required String email,
    String? username,
    required String password,
    String? phoneNumber,
  }) async {
    try {
      final authId = _uuid.v4();
      final userModel = AuthHiveModel(
        authId: authId,
        fullName: fullName,
        email: email,
        username: username,
        password: password, // In production, hash this
        phoneNumber: phoneNumber,
      );

      final registeredUser = await _datasource.register(userModel);
      return Right(_modelToEntity(registeredUser));
    } on UserAlreadyExistsException catch (e) {
      return Left(UserAlreadyExistsFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login({
    required String emailOrUsername,
    required String password,
  }) async {
    try {
      final user = await _datasource.login(emailOrUsername, password);
      return Right(_modelToEntity(user));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on UserNotFoundException catch (e) {
      return Left(UserNotFoundFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity?>> getCurrentUser() async {
    try {
      final userId = _sessionService.getCurrentUserId();
      if (userId == null) {
        return const Right(null);
      }

      final user = await _datasource.getCurrentUser(userId);
      if (user == null) {
        return const Right(null);
      }
      return Right(_modelToEntity(user));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _datasource.logout();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}

