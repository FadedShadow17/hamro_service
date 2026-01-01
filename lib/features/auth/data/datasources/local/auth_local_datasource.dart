import 'package:hive/hive.dart';
import 'package:hamro_service/core/constants/hive_table_constant.dart';
import 'package:hamro_service/core/error/exceptions.dart';
import 'package:hamro_service/core/services/storage/user_session_service.dart';
import '../../models/auth_hive_model.dart';
import '../auth_datasource.dart';

/// Local datasource implementation using Hive for storage
class AuthLocalDatasource implements AuthDatasource {
  final UserSessionService _sessionService;

  AuthLocalDatasource({required UserSessionService sessionService})
      : _sessionService = sessionService;

  /// Get the users box
  Box<AuthHiveModel> _getUsersBox() {
    try {
      if (!Hive.isBoxOpen(HiveTableConstant.usersBox)) {
        throw Exception('Users box not opened. Call HiveService.init() first.');
      }
      final box = Hive.box<AuthHiveModel>(HiveTableConstant.usersBox);
      return box;
    } catch (e) {
      if (e.toString().contains('Users box not opened')) {
        rethrow;
      }
      throw Exception('Users box not initialized. Call HiveService.init() first.');
    }
  }

  @override
  Future<AuthHiveModel> register(AuthHiveModel user) async {
    final box = _getUsersBox();
    
    // Check if user with same email already exists
    try {
      box.values.firstWhere((u) => u.email == user.email);
      // If we get here, user exists
      throw UserAlreadyExistsException('User with this email already exists');
    } catch (e) {
      // If UserAlreadyExistsException, rethrow it
      if (e is UserAlreadyExistsException) {
        rethrow;
      }
      // If StateError (no element found), it means no user found - safe to register
      // This is the expected case when registering a new user
      if (e is StateError || e.toString().contains('StateError') || e.toString().contains('No element')) {
        // No user found, safe to register - continue
      } else {
        // Some other unexpected error
        throw CacheException('Error checking user existence: ${e.toString()}');
      }
    }

    // Save user to Hive
    await box.put(user.authId, user);
    
    return user;
  }

  @override
  Future<AuthHiveModel> login(String emailOrUsername, String password) async {
    final box = _getUsersBox();
    
    // Find user by email or username
    AuthHiveModel? user;
    try {
      user = box.values.firstWhere(
        (u) => (u.email == emailOrUsername || u.username == emailOrUsername),
      );
    } catch (e) {
      throw UserNotFoundException('User not found');
    }
    
    // Verify password
    if (user.password != password) {
      throw AuthenticationException('Invalid password');
    }

    // Save session
    await _sessionService.saveSession(user.authId);

    return user;
  }

  @override
  Future<AuthHiveModel?> getCurrentUser(String userId) async {
    if (!_sessionService.isLoggedIn()) {
      return null;
    }

    final box = _getUsersBox();
    return box.get(userId);
  }

  @override
  Future<void> logout() async {
    await _sessionService.clearSession();
  }
}

