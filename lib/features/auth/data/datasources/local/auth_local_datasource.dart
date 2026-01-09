import 'package:hive/hive.dart';
import 'package:hamro_service/core/constants/hive_table_constant.dart';
import 'package:hamro_service/core/error/exceptions.dart';
import 'package:hamro_service/core/services/storage/user_session_service.dart';
import '../../models/auth_hive_model.dart';
import '../auth_datasource.dart';

class AuthLocalDatasource implements AuthDatasource {
  final UserSessionService _sessionService;

  AuthLocalDatasource({required UserSessionService sessionService})
      : _sessionService = sessionService;

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
    
    try {
      box.values.firstWhere((u) => u.email == user.email);
      throw UserAlreadyExistsException('User with this email already exists');
    } catch (e) {
      if (e is UserAlreadyExistsException) {
        rethrow;
      }
      if (e is StateError || e.toString().contains('StateError') || e.toString().contains('No element')) {
      } else {
        throw CacheException('Error checking user existence: ${e.toString()}');
      }
    }

    await box.put(user.authId, user);
    
    return user;
  }

  @override
  Future<AuthHiveModel> login(String emailOrUsername, String password) async {
    final box = _getUsersBox();
    
    AuthHiveModel? user;
    try {
      user = box.values.firstWhere(
        (u) => (u.email == emailOrUsername || u.username == emailOrUsername),
      );
    } catch (e) {
      throw UserNotFoundException('User not found');
    }
    
    if (user.password != password) {
      throw AuthenticationException('Invalid password');
    }

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

