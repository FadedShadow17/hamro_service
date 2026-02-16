import 'dart:convert';

class JwtDecoder {
  static Map<String, dynamic>? decode(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      final payload = parts[1];
      final normalized = base64.normalize(payload);
      final decoded = utf8.decode(base64.decode(normalized));
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  static String? getRole(String token) {
    final decoded = decode(token);
    return decoded?['role'] as String?;
  }

  static String? getUserId(String token) {
    final decoded = decode(token);
    return decoded?['id'] as String?;
  }

  static String? getEmail(String token) {
    final decoded = decode(token);
    return decoded?['email'] as String?;
  }
}
