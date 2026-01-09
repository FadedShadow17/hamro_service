abstract class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

class ServerException extends AppException {
  ServerException([String message = 'Server error occurred']) : super(message);
}

class CacheException extends AppException {
  CacheException([String message = 'Cache error occurred']) : super(message);
}

class AuthenticationException extends AppException {
  AuthenticationException([String message = 'Authentication failed']) : super(message);
}

class UserNotFoundException extends AppException {
  UserNotFoundException([String message = 'User not found']) : super(message);
}

class UserAlreadyExistsException extends AppException {
  UserAlreadyExistsException([String message = 'User already exists']) : super(message);
}

