import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String? _lastRegistrationMessage;

  AuthRepositoryImpl({
    AuthDatasource? localDatasource,
    required AuthRemoteDatasource remoteDatasource,
    required UserSessionService sessionService,
    required ConnectivityService connectivityService,
  })  : _localDatasource = localDatasource,
        _remoteDatasource = remoteDatasource,
        _sessionService = sessionService,
        _connectivityService = connectivityService;

  String? get lastRegistrationMessage => _lastRegistrationMessage;

  AuthEntity _modelToEntity(AuthHiveModel model) {
    return AuthEntity(
      authId: model.authId,
      fullName: model.fullName,
      email: model.email,
      username: model.username,
      phoneNumber: model.phoneNumber,
      role: model.role,
    );
  }

  AuthEntity _mapUserToEntity(Map<String, dynamic> user, String email) {
    final id = user["_id"] ?? user["id"] ?? "";
    final fullName = user["fullName"] ?? user["name"] ?? "";
    final userEmail = user["email"] ?? email;
    final username = user["username"];
    final phoneNumber = user["phoneNumber"];
    final role = user["role"] as String?;

    return AuthEntity(
      authId: id,
      fullName: fullName,
      email: userEmail,
      username: username,
      phoneNumber: phoneNumber,
      role: role,
    );
  }

  @override
  Future<Either<Failure, AuthEntity>> register({
    required String fullName,
    required String email,
    String? username,
    required String password,
    String? phoneNumber,
    String? role,
  }) async {
    final hasInternet = await _connectivityService.hasInternetConnection();

    if (hasInternet) {
      try {
        final response = await _remoteDatasource.register(
          fullName: fullName,
          email: email,
          password: password,
          phoneNumber: phoneNumber,
          username: username,
          role: role,
        );

        _lastRegistrationMessage = response.message;

        if (response.token.isNotEmpty) {
          await _sessionService.saveToken(response.token);
        }

        final authEntity = _mapUserToEntity(response.user, email);

        if (authEntity.authId.isNotEmpty) {
          await _sessionService.saveSession(authEntity.authId);

          if (authEntity.role != null && authEntity.role!.isNotEmpty) {
            await _sessionService.saveRole(authEntity.role!);
          }
          
          if (_localDatasource != null) {
            final userModel = AuthHiveModel(
              authId: authEntity.authId,
              fullName: authEntity.fullName,
              email: authEntity.email,
              username: authEntity.username,
              password: '', 
              phoneNumber: authEntity.phoneNumber,
              role: authEntity.role,
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

    if (hasInternet) {
      try {
        final response = await _remoteDatasource.login(
          emailOrUsername: emailOrUsername,
          password: password,
        );

        if (response.token.isNotEmpty) {
          await _sessionService.saveToken(response.token);
        }

        final email = response.user["email"] ?? emailOrUsername;
        final authEntity = _mapUserToEntity(response.user, email);

        if (authEntity.authId.isNotEmpty) {
          await _sessionService.saveSession(authEntity.authId);

          final prefs = await SharedPreferences.getInstance();
          final roleSelected = prefs.getBool('role_selected') ?? false;
          
          if (roleSelected && authEntity.role != null && authEntity.role!.isNotEmpty) {
            await _sessionService.saveRole(authEntity.role!);
          }
          
          if (_localDatasource != null) {
            final userModel = AuthHiveModel(
              authId: authEntity.authId,
              fullName: authEntity.fullName,
              email: authEntity.email,
              username: authEntity.username,
              password: '', 
              phoneNumber: authEntity.phoneNumber,
              role: authEntity.role,
            );
            await _localDatasource!.saveUser(userModel);
          }
        }

        return Right(authEntity);
      } on DioException catch (e) {


        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.connectionError) {

          if (_localDatasource == null) {
            return Left(CacheFailure('Backend unavailable and local storage not available'));
          }
          
          try {
            final user = await _localDatasource!.login(emailOrUsername, password);

            final sessionRole = _sessionService.getRole();
            final userModel = user.copyWith(role: sessionRole ?? user.role);
            if (sessionRole != null && sessionRole.isNotEmpty) {
              await _localDatasource!.saveUser(userModel);
            }
            return Right(_modelToEntity(userModel));
          } on AuthenticationException catch (e) {
            return Left(AuthenticationFailure(e.message));
          } on UserNotFoundException catch (e) {
            return Left(UserNotFoundFailure(e.message));
          } on CacheException catch (e) {
            return Left(CacheFailure(e.message));
          } catch (e) {
            return Left(AuthenticationFailure('Local login failed: ${e.toString()}'));
          }
        }

        final message = e.response?.data?['message'] ??
            e.response?.data?['error'] ??
            e.message ??
            'Login failed';
        
        if (message.toString().toLowerCase().contains('invalid') ||
            message.toString().toLowerCase().contains('password') ||
            message.toString().toLowerCase().contains('credentials')) {
          return Left(AuthenticationFailure(message.toString()));
        }
        if (message.toString().toLowerCase().contains('not found') ||
            message.toString().toLowerCase().contains('user not found')) {
          return Left(UserNotFoundFailure(message.toString()));
        }
        return Left(AuthenticationFailure(message.toString()));
      } on Exception catch (e) {
        final message = e.toString().replaceFirst('Exception: ', '');

        if (message.toLowerCase().contains('timeout') ||
            message.toLowerCase().contains('connection') ||
            message.toLowerCase().contains('failed host lookup')) {
          if (_localDatasource == null) {
            return Left(CacheFailure('Backend unavailable and local storage not available'));
          }
          
          try {
            final user = await _localDatasource!.login(emailOrUsername, password);
            final sessionRole = _sessionService.getRole();
            final userModel = user.copyWith(role: sessionRole ?? user.role);
            if (sessionRole != null && sessionRole.isNotEmpty) {
              await _localDatasource!.saveUser(userModel);
            }
            return Right(_modelToEntity(userModel));
          } on AuthenticationException catch (e) {
            return Left(AuthenticationFailure(e.message));
          } on UserNotFoundException catch (e) {
            return Left(UserNotFoundFailure(e.message));
          } catch (e) {
            return Left(AuthenticationFailure('Local login failed: ${e.toString()}'));
          }
        }
        
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

        if (_localDatasource != null) {
          try {
            final user = await _localDatasource!.login(emailOrUsername, password);
            final sessionRole = _sessionService.getRole();
            final userModel = user.copyWith(role: sessionRole ?? user.role);
            if (sessionRole != null && sessionRole.isNotEmpty) {
              await _localDatasource!.saveUser(userModel);
            }
            return Right(_modelToEntity(userModel));
          } catch (localError) {
            return Left(AuthenticationFailure('Login failed: ${e.toString()}'));
          }
        }
        return Left(AuthenticationFailure(e.toString()));
      }
    } else {

      if (_localDatasource == null) {
        return const Left(CacheFailure('No internet connection and local storage not available'));
      }
      
      try {
        final user = await _localDatasource!.login(emailOrUsername, password);
        final sessionRole = _sessionService.getRole();
        final userModel = user.copyWith(role: sessionRole ?? user.role);
        if (sessionRole != null && sessionRole.isNotEmpty) {
          await _localDatasource!.saveUser(userModel);
        }
        return Right(_modelToEntity(userModel));
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

      
      if (!_sessionService.isLoggedIn()) {
        return const Right(null);
      }

      
      if (_localDatasource != null) {
        final user = await _localDatasource!.getCurrentUser(userId);
        if (user != null) {

          if (user.role == null || user.role!.isEmpty) {
            final sessionRole = _sessionService.getRole();
            if (sessionRole != null && sessionRole.isNotEmpty) {

              final updatedUser = user.copyWith(role: sessionRole);
              await _localDatasource!.saveUser(updatedUser);
              return Right(_modelToEntity(updatedUser));
            }
          }
          return Right(_modelToEntity(user));
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity?>> getMe() async {
    final hasInternet = await _connectivityService.hasInternetConnection();
    
    if (hasInternet) {
      try {
        final userData = await _remoteDatasource.getMe();
        final email = userData["email"] ?? "";
        final authEntity = _mapUserToEntity(userData, email);
        
        if (authEntity.authId.isNotEmpty) {
          await _sessionService.saveSession(authEntity.authId);

          if (authEntity.role != null && authEntity.role!.isNotEmpty) {
            await _sessionService.saveRole(authEntity.role!);
          }
          
          if (_localDatasource != null) {
            final userModel = AuthHiveModel(
              authId: authEntity.authId,
              fullName: authEntity.fullName,
              email: authEntity.email,
              username: authEntity.username,
              password: '',
              phoneNumber: authEntity.phoneNumber,
              role: authEntity.role,
            );
            await _localDatasource!.saveUser(userModel);
          }
        }
        
        return Right(authEntity);
      } on DioException catch (e) {


        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.connectionError) {

          return getCurrentUser();
        }

        final message = e.response?.data?['message'] ??
            e.response?.data?['error'] ??
            e.message ??
            'Failed to fetch user';
        
        if (message.toString().toLowerCase().contains('unauthorized') ||
            message.toString().toLowerCase().contains('invalid token')) {
          await _sessionService.clearSession();
          return const Right(null);
        }

        return getCurrentUser();
      } on Exception catch (e) {
        final message = e.toString().replaceFirst('Exception: ', '');
        if (message.toLowerCase().contains('unauthorized') ||
            message.toLowerCase().contains('invalid token')) {
          await _sessionService.clearSession();
          return const Right(null);
        }

        return getCurrentUser();
      } catch (e) {

        return getCurrentUser();
      }
    } else {
      return getCurrentUser();
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

