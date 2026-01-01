import 'package:equatable/equatable.dart';

/// Base failure class
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Server failure
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred']) : super(message);
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error occurred']) : super(message);
}

/// Authentication failure
class AuthenticationFailure extends Failure {
  const AuthenticationFailure([String message = 'Authentication failed']) : super(message);
}

/// User not found failure
class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure([String message = 'User not found']) : super(message);
}

/// User already exists failure
class UserAlreadyExistsFailure extends Failure {
  const UserAlreadyExistsFailure([String message = 'User already exists']) : super(message);
}

