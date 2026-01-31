import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hamro_service/core/services/storage/user_session_service.dart';

void main() {
  late UserSessionService userSessionService;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    userSessionService = UserSessionService(prefs: prefs);
  });

  group('UserSessionService', () {
    test('should save session successfully', () async {
     
      const userId = 'test_user_id_123';

    
      final result = await userSessionService.saveSession(userId);

      
      expect(result, true);
      expect(userSessionService.getCurrentUserId(), userId);
      expect(userSessionService.isLoggedIn(), true);
    });

    test('should return null when no user is logged in', () {
      
      final userId = userSessionService.getCurrentUserId();
      final isLoggedIn = userSessionService.isLoggedIn();

      
      expect(userId, isNull);
      expect(isLoggedIn, false);
    });

    test('should save and retrieve token successfully', () async {
      
      const token = 'test_auth_token_12345';

    
      await userSessionService.saveToken(token);
      final retrievedToken = userSessionService.getToken();

      
      expect(retrievedToken, token);
    });

    test('should clear session successfully', () async {
      
      const userId = 'test_user_id_123';
      await userSessionService.saveSession(userId);
      await userSessionService.saveToken('test_token');

      
      final result = await userSessionService.clearSession();

      
      expect(result, true);
      expect(userSessionService.getCurrentUserId(), isNull);
      expect(userSessionService.isLoggedIn(), false);
      expect(userSessionService.getToken(), isNull);
    });

    test('should clear token when clearing session', () async {
     
      const token = 'test_token';
      await userSessionService.saveToken(token);

      
      await userSessionService.clearToken();
      final retrievedToken = userSessionService.getToken();

      
      expect(retrievedToken, isNull);
    });
  });
}
