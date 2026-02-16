import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthEntity>> register({
    required String fullName,
    required String email,
    String? username,
    required String password,
    String? phoneNumber,
    String? role,
  });

  Future<Either<Failure, AuthEntity>> login({
    required String emailOrUsername,
    required String password,
  });

  Future<Either<Failure, AuthEntity?>> getCurrentUser();

  Future<Either<Failure, AuthEntity?>> getMe();

  Future<Either<Failure, void>> logout();

  String? get lastRegistrationMessage;
}

