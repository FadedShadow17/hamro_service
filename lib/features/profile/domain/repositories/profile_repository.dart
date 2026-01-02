import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/profile_entity.dart';

/// Domain repository interface for profile operations
abstract class ProfileRepository {
  /// Get user profile
  Future<Either<Failure, ProfileEntity?>> getProfile();

  /// Update user profile
  Future<Either<Failure, ProfileEntity>> updateProfile(ProfileEntity profile);
}

