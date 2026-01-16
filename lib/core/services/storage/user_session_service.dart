import 'package:shared_preferences/shared_preferences.dart';

class UserSessionService {
  final SharedPreferences _prefs;

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  static const String _sessionUserIdKey = 'session_user_id';
  static const String _sessionIsLoggedInKey = 'session_is_logged_in';
  static const String _tokenKey = "auth_token";

  Future<bool> saveSession(String userId) async {
    final userIdSaved = await _prefs.setString(_sessionUserIdKey, userId);
    final isLoggedInSaved = await _prefs.setBool(_sessionIsLoggedInKey, true);
    return userIdSaved && isLoggedInSaved;
  }

  String? getCurrentUserId() {
    return _prefs.getString(_sessionUserIdKey);
  }

  bool isLoggedIn() {
    return _prefs.getBool(_sessionIsLoggedInKey) ?? false;
  }

  Future<bool> clearSession() async {
    final userIdRemoved = await _prefs.remove(_sessionUserIdKey);
    final isLoggedInRemoved = await _prefs.remove(_sessionIsLoggedInKey);
    await clearToken();
    return userIdRemoved && isLoggedInRemoved;
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
  }
}

