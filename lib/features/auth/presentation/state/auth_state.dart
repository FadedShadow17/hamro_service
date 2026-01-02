import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_entity.dart';

/// Authentication state
class AuthState extends Equatable {
  final bool isAuthenticated;
  final bool isLoading;
  final AuthEntity? user;
  final String? errorMessage;
  final bool isRegistered;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user,
    this.errorMessage,
    this.isRegistered = false,
  });

  /// Initial unauthenticated state
  const AuthState.initial()
      : isAuthenticated = false,
        isLoading = false,
        user = null,
        errorMessage = null,
        isRegistered = false;

  /// Loading state
  const AuthState.loading()
      : isAuthenticated = false,
        isLoading = true,
        user = null,
        errorMessage = null,
        isRegistered = false;

  /// Authenticated state
  const AuthState.authenticated(this.user)
      : isAuthenticated = true,
        isLoading = false,
        errorMessage = null,
        isRegistered = false;

  /// Registered state
  const AuthState.registered()
      : isAuthenticated = false,
        isLoading = false,
        user = null,
        errorMessage = null,
        isRegistered = true;

  /// Error state
  const AuthState.error(this.errorMessage)
      : isAuthenticated = false,
        isLoading = false,
        user = null,
        isRegistered = false;

  /// Create a copy with updated fields
  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    AuthEntity? user,
    String? errorMessage,
    bool? isRegistered,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }

  @override
  List<Object?> get props => [
        isAuthenticated,
        isLoading,
        user,
        errorMessage,
        isRegistered,
      ];
}

