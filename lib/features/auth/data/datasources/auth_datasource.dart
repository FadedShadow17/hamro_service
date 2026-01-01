import '../models/auth_hive_model.dart';

/// Abstract datasource interface for authentication operations
abstract class AuthDatasource {
  /// Register a new user
  Future<AuthHiveModel> register(AuthHiveModel user);

  /// Login with email/username and password
  Future<AuthHiveModel> login(String emailOrUsername, String password);

  /// Get current logged-in user
  Future<AuthHiveModel?> getCurrentUser(String userId);

  /// Logout (clear session)
  Future<void> logout();
}

