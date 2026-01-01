import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../state/auth_state.dart';

/// Provider for AuthRepository (to be provided in main or app setup)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('authRepositoryProvider must be overridden');
});

/// ViewModel for authentication using NotifierProvider
class AuthViewModel extends Notifier<AuthState> {
  late final LoginUsecase _loginUsecase;
  late final RegisterUsecase _registerUsecase;
  late final GetCurrentUserUsecase _getCurrentUserUsecase;
  late final LogoutUsecase _logoutUsecase;

  @override
  AuthState build() {
    final repository = ref.read(authRepositoryProvider);
    _loginUsecase = LoginUsecase(repository);
    _registerUsecase = RegisterUsecase(repository);
    _getCurrentUserUsecase = GetCurrentUserUsecase(repository);
    _logoutUsecase = LogoutUsecase(repository);

    // Check if user is already logged in
    checkAuth();

    return const AuthState.initial();
  }

  /// Check if user is authenticated
  Future<void> checkAuth() async {
    state = const AuthState.loading();
    final result = await _getCurrentUserUsecase();
    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (user) {
        if (user != null) {
          state = AuthState.authenticated(user);
        } else {
          state = const AuthState.initial();
        }
      },
    );
  }

  /// Login with email/username and password
  Future<void> login({
    required String emailOrUsername,
    required String password,
  }) async {
    state = const AuthState.loading();
    final result = await _loginUsecase(
      emailOrUsername: emailOrUsername,
      password: password,
    );
    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (user) => state = AuthState.authenticated(user),
    );
  }

  /// Register a new user
  Future<void> register({
    required String fullName,
    required String email,
    String? username,
    required String password,
    String? phoneNumber,
  }) async {
    state = const AuthState.loading();
    final result = await _registerUsecase(
      fullName: fullName,
      email: email,
      username: username,
      password: password,
      phoneNumber: phoneNumber,
    );
    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (user) => state = const AuthState.registered(),
    );
  }

  /// Logout
  Future<void> logout() async {
    state = const AuthState.loading();
    final result = await _logoutUsecase();
    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (_) => state = const AuthState.initial(),
    );
  }
}

/// Provider for AuthViewModel
final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);

