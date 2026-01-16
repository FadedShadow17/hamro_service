import '../models/auth_hive_model.dart';

abstract class AuthDatasource {
  Future<AuthHiveModel> register(AuthHiveModel user);

  Future<AuthHiveModel> login(String emailOrUsername, String password);

  Future<AuthHiveModel?> getCurrentUser(String userId);

  Future<void> logout();

  Future<void> saveUser(AuthHiveModel user);
}

