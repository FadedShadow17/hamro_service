import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_entity.dart';

class AuthState extends Equatable {
  final bool isAuthenticated;
  final bool isLoading;
  final AuthEntity? user;
  final String? errorMessage;
  final String? successMessage;
  final bool isRegistered;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user,
    this.errorMessage,
    this.successMessage,
    this.isRegistered = false,
  });

  const AuthState.initial()
      : isAuthenticated = false,
        isLoading = false,
        user = null,
        errorMessage = null,
        successMessage = null,
        isRegistered = false;

  const AuthState.loading()
      : isAuthenticated = false,
        isLoading = true,
        user = null,
        errorMessage = null,
        successMessage = null,
        isRegistered = false;

  const AuthState.authenticated(this.user)
      : isAuthenticated = true,
        isLoading = false,
        errorMessage = null,
        successMessage = null,
        isRegistered = false;

  AuthState.registered([this.user, this.successMessage])
      : isAuthenticated = false,
        isLoading = false,
        errorMessage = null,
        isRegistered = true;

  const AuthState.error(this.errorMessage)
      : isAuthenticated = false,
        isLoading = false,
        user = null,
        successMessage = null,
        isRegistered = false;

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    AuthEntity? user,
    String? errorMessage,
    String? successMessage,
    bool? isRegistered,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }

  @override
  List<Object?> get props => [
        isAuthenticated,
        isLoading,
        user,
        errorMessage,
        successMessage,
        isRegistered,
      ];
}

