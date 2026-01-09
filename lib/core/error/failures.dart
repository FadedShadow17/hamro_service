import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred']) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error occurred']) : super(message);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure([String message = 'Authentication failed']) : super(message);
}

class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure([String message = 'User not found']) : super(message);
}

class UserAlreadyExistsFailure extends Failure {
  const UserAlreadyExistsFailure([String message = 'User already exists']) : super(message);
}

