import '../datasources/auth_datasource.dart';
import '../models/auth_hive_model.dart';

/// Concrete repository implementation for authentication
class AuthRepository {
  final AuthDatasource _datasource;

  AuthRepository({required AuthDatasource datasource})
      : _datasource = datasource;

  /// Register a new user
  Future<AuthHiveModel> register(AuthHiveModel user) async {
    return await _datasource.register(user);
  }

  /// Login with email/username and password
  Future<AuthHiveModel> login(String emailOrUsername, String password) async {
    return await _datasource.login(emailOrUsername, password);
  }

  /// Get current logged-in user
  Future<AuthHiveModel?> getCurrentUser(String userId) async {
    return await _datasource.getCurrentUser(userId);
  }

  /// Logout
  Future<void> logout() async {
    return await _datasource.logout();
  }
}

