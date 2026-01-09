import '../models/profile_hive_model.dart';

abstract class ProfileDatasource {
  Future<ProfileHiveModel?> getProfile(String userId);

  Future<ProfileHiveModel> updateProfile(ProfileHiveModel profile);
}

