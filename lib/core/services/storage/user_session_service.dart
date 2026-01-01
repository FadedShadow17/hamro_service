import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing user session persistence
class UserSessionService {
  final SharedPreferences _prefs;

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  // Session keys
  static const String _sessionUserIdKey = 'session_user_id';
  static const String _sessionIsLoggedInKey = 'session_is_logged_in';

  /// Save user session after successful login
  Future<bool> saveSession(String userId) async {
    final userIdSaved = await _prefs.setString(_sessionUserIdKey, userId);
    final isLoggedInSaved = await _prefs.setBool(_sessionIsLoggedInKey, true);
    return userIdSaved && isLoggedInSaved;
  }

  /// Get current logged-in user ID
  String? getCurrentUserId() {
    return _prefs.getString(_sessionUserIdKey);
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return _prefs.getBool(_sessionIsLoggedInKey) ?? false;
  }

  /// Clear session on logout
  Future<bool> clearSession() async {
    final userIdRemoved = await _prefs.remove(_sessionUserIdKey);
    final isLoggedInRemoved = await _prefs.remove(_sessionIsLoggedInKey);
    return userIdRemoved && isLoggedInRemoved;
  }
}

