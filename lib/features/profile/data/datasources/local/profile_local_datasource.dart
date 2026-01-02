import 'package:hive/hive.dart';
import 'package:hamro_service/core/constants/hive_table_constant.dart';
import 'package:hamro_service/core/error/exceptions.dart';
import '../../models/profile_hive_model.dart';
import '../profile_datasource.dart';

/// Local datasource implementation using Hive for profile storage
class ProfileLocalDatasource implements ProfileDatasource {
  /// Get the profile box
  Box<ProfileHiveModel> _getProfileBox() {
    try {
      if (!Hive.isBoxOpen(HiveTableConstant.profileBox)) {
        throw Exception('Profile box not opened. Call HiveService.init() first.');
      }
      final box = Hive.box<ProfileHiveModel>(HiveTableConstant.profileBox);
      return box;
    } catch (e) {
      throw CacheException('Profile box not initialized: ${e.toString()}');
    }
  }

  @override
  Future<ProfileHiveModel?> getProfile(String userId) async {
    final box = _getProfileBox();
    return box.get(userId);
  }

  @override
  Future<ProfileHiveModel> updateProfile(ProfileHiveModel profile) async {
    final box = _getProfileBox();
    await box.put(profile.userId, profile);
    return profile;
  }
}

