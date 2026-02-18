import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../state/auth_state.dart';
import '../../../profile/presentation/viewmodel/profile_viewmodel.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('authRepositoryProvider must be overridden');
});

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

    return const AuthState.initial();
  }

  Future<void> checkAuth() async {
    state = const AuthState.loading();
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.getMe();
    result.fold(
      (failure) {
        state = const AuthState.initial();
      },
      (user) {
        if (user != null) {
          state = AuthState.authenticated(user);
        } else {
          state = const AuthState.initial();
        }
      },
    );
  }

  Future<void> login({
    required String emailOrUsername,
    required String password,
  }) async {
    state = const AuthState.loading();
    ref.invalidate(profileViewModelProvider);
    ref.read(profileViewModelProvider.notifier).resetProfile();
    
    final result = await _loginUsecase(
      emailOrUsername: emailOrUsername,
      password: password,
    );
    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (user) {
        state = AuthState.authenticated(user);
        Future.microtask(() {
          ref.read(profileViewModelProvider.notifier).loadProfile();
        });
      },
    );
  }

  Future<void> register({
    required String fullName,
    required String email,
    String? username,
    required String password,
    String? phoneNumber,
    String? role,
  }) async {
    state = const AuthState.loading();
    final repository = ref.read(authRepositoryProvider);
    final result = await _registerUsecase(
      fullName: fullName,
      email: email,
      username: username,
      password: password,
      phoneNumber: phoneNumber,
      role: role,
    );
    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (user) {
        final message = repository.lastRegistrationMessage;
        state = AuthState.registered(user, message);
      },
    );
  }

  Future<void> logout() async {
    state = const AuthState.loading();
    final result = await _logoutUsecase();
    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (_) {
        ref.invalidate(profileViewModelProvider);
        ref.read(profileViewModelProvider.notifier).resetProfile();
        state = const AuthState.initial();
      },
    );
  }
}

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);

