import '../models/profile_hive_model.dart';

/// Abstract datasource interface for profile operations
abstract class ProfileDatasource {
  /// Get user profile
  Future<ProfileHiveModel?> getProfile(String userId);

  /// Update user profile
  Future<ProfileHiveModel> updateProfile(ProfileHiveModel profile);
}

