import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_entity.dart';

/// Domain repository interface for authentication
abstract class AuthRepository {
  /// Register a new user
  Future<Either<Failure, AuthEntity>> register({
    required String fullName,
    required String email,
    String? username,
    required String password,
    String? phoneNumber,
  });

  /// Login with email/username and password
  Future<Either<Failure, AuthEntity>> login({
    required String emailOrUsername,
    required String password,
  });

  /// Get current logged-in user
  Future<Either<Failure, AuthEntity?>> getCurrentUser();

  /// Logout
  Future<Either<Failure, void>> logout();
}

