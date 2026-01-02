/// Base exception class for the application
abstract class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

/// Exception thrown when a server error occurs
class ServerException extends AppException {
  ServerException([String message = 'Server error occurred']) : super(message);
}

/// Exception thrown when a cache error occurs
class CacheException extends AppException {
  CacheException([String message = 'Cache error occurred']) : super(message);
}

/// Exception thrown when authentication fails
class AuthenticationException extends AppException {
  AuthenticationException([String message = 'Authentication failed']) : super(message);
}

/// Exception thrown when a user is not found
class UserNotFoundException extends AppException {
  UserNotFoundException([String message = 'User not found']) : super(message);
}

/// Exception thrown when a user already exists
class UserAlreadyExistsException extends AppException {
  UserAlreadyExistsException([String message = 'User already exists']) : super(message);
}

