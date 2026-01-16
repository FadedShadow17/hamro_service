import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/connectivity/connectivity_service.dart';
import '../../../../core/services/storage/user_session_service.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../models/auth_hive_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource? _localDatasource;
  final AuthRemoteDatasource _remoteDatasource;
  final UserSessionService _sessionService;
  final ConnectivityService _connectivityService;

  AuthRepositoryImpl({
    AuthDatasource? localDatasource,
    required AuthRemoteDatasource remoteDatasource,
    required UserSessionService sessionService,
    required ConnectivityService connectivityService,
  })  : _localDatasource = localDatasource,
        _remoteDatasource = remoteDatasource,
        _sessionService = sessionService,
        _connectivityService = connectivityService;

  AuthEntity _modelToEntity(AuthHiveModel model) {
    return AuthEntity(
      authId: model.authId,
      fullName: model.fullName,
      email: model.email,
      username: model.username,
      phoneNumber: model.phoneNumber,
    );
  }

  AuthEntity _mapUserToEntity(Map<String, dynamic> user, String email) {
    final id = user["_id"] ?? user["id"] ?? "";
    final fullName = user["fullName"] ?? user["name"] ?? "";
    final userEmail = user["email"] ?? email;
    final username = user["username"];
    final phoneNumber = user["phoneNumber"];

    return AuthEntity(
      authId: id,
      fullName: fullName,
      email: userEmail,
      username: username,
      phoneNumber: phoneNumber,
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
    final hasInternet = await _connectivityService.hasInternetConnection();
    
    // If online, use remote datasource
    if (hasInternet) {
      try {
        final response = await _remoteDatasource.register(
          fullName: fullName,
          email: email,
          password: password,
          phoneNumber: phoneNumber,
          username: username,
        );

        if (response.token.isNotEmpty) {
          await _sessionService.saveToken(response.token);
          final tokenPreview = response.token.substring(0, min(12, response.token.length));
          print("✅ Saved token: ${tokenPreview}...");
        }

        final authEntity = _mapUserToEntity(response.user, email);

        if (authEntity.authId.isNotEmpty) {
          await _sessionService.saveSession(authEntity.authId);
          
          // Save user data to local storage for persistence
          if (_localDatasource != null) {
            final userModel = AuthHiveModel(
              authId: authEntity.authId,
              fullName: authEntity.fullName,
              email: authEntity.email,
              username: authEntity.username,
              password: '', // Don't store password for online logins
              phoneNumber: authEntity.phoneNumber,
            );
            await _localDatasource!.saveUser(userModel);
          }
        }

        return Right(authEntity);
      } on Exception catch (e) {
        final message = e.toString().replaceFirst('Exception: ', '');
        if (message.toLowerCase().contains('already exists') ||
            message.toLowerCase().contains('duplicate')) {
          return Left(UserAlreadyExistsFailure(message));
        }
        return Left(CacheFailure(message));
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    } else {
      // If offline, use local datasource
      if (_localDatasource == null) {
        return const Left(CacheFailure('No internet connection and local storage not available'));
      }
      
      try {
        final authId = const Uuid().v4();
        final userModel = AuthHiveModel(
          authId: authId,
          fullName: fullName,
          email: email,
          username: username,
          password: password,
          phoneNumber: phoneNumber,
        );

        final registeredUser = await _localDatasource!.register(userModel);
        return Right(_modelToEntity(registeredUser));
      } on UserAlreadyExistsException catch (e) {
        return Left(UserAlreadyExistsFailure(e.message));
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login({
    required String emailOrUsername,
    required String password,
  }) async {
    final hasInternet = await _connectivityService.hasInternetConnection();
    
    // If online, use remote datasource
    if (hasInternet) {
      try {
        final response = await _remoteDatasource.login(
          emailOrUsername: emailOrUsername,
          password: password,
        );

        if (response.token.isNotEmpty) {
          await _sessionService.saveToken(response.token);
          final tokenPreview = response.token.substring(0, min(12, response.token.length));
          print("✅ Saved token: ${tokenPreview}...");
        }

        final email = response.user["email"] ?? emailOrUsername;
        final authEntity = _mapUserToEntity(response.user, email);

        if (authEntity.authId.isNotEmpty) {
          await _sessionService.saveSession(authEntity.authId);
          
          // Save user data to local storage for persistence
          if (_localDatasource != null) {
            final userModel = AuthHiveModel(
              authId: authEntity.authId,
              fullName: authEntity.fullName,
              email: authEntity.email,
              username: authEntity.username,
              password: '', // Don't store password for online logins
              phoneNumber: authEntity.phoneNumber,
            );
            await _localDatasource!.saveUser(userModel);
          }
        }

        return Right(authEntity);
      } on Exception catch (e) {
        final message = e.toString().replaceFirst('Exception: ', '');
        if (message.toLowerCase().contains('invalid') ||
            message.toLowerCase().contains('password') ||
            message.toLowerCase().contains('credentials')) {
          return Left(AuthenticationFailure(message));
        }
        if (message.toLowerCase().contains('not found') ||
            message.toLowerCase().contains('user not found')) {
          return Left(UserNotFoundFailure(message));
        }
        return Left(AuthenticationFailure(message));
      } catch (e) {
        return Left(AuthenticationFailure(e.toString()));
      }
    } else {
      // If offline, use local datasource
      if (_localDatasource == null) {
        return const Left(CacheFailure('No internet connection and local storage not available'));
      }
      
      try {
        final user = await _localDatasource!.login(emailOrUsername, password);
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
  }

  @override
  Future<Either<Failure, AuthEntity?>> getCurrentUser() async {
    try {
      final userId = _sessionService.getCurrentUserId();
      if (userId == null) {
        return const Right(null);
      }

      // Check if user is logged in
      if (!_sessionService.isLoggedIn()) {
        return const Right(null);
      }

      // Try to get user from local storage first
      if (_localDatasource != null) {
        final user = await _localDatasource!.getCurrentUser(userId);
        if (user != null) {
          return Right(_modelToEntity(user));
        }
      }

      // If local storage doesn't have user but we have a session and token,
      // it means user logged in online but data wasn't saved (shouldn't happen after fix, but handle it)
      // For now, return null - user will need to login again if this edge case occurs
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      if (_localDatasource != null) {
        await _localDatasource!.logout();
      } else {
        await _sessionService.clearSession();
      }
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}

