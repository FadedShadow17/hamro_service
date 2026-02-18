import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamro_service/core/error/failures.dart';
import 'package:hamro_service/features/auth/domain/entities/auth_entity.dart';
import 'package:hamro_service/features/auth/domain/repositories/auth_repository.dart';
import 'package:hamro_service/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:hamro_service/features/auth/presentation/state/auth_state.dart';
import 'package:hamro_service/features/profile/presentation/viewmodel/profile_viewmodel.dart';
import 'package:hamro_service/features/profile/domain/repositories/profile_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([AuthRepository, ProfileRepository])
import 'auth_viewmodel_test.mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late MockProfileRepository mockProfileRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    mockProfileRepository = MockProfileRepository();
  });

  const testAuthEntity = AuthEntity(
    authId: '123',
    fullName: 'Test User',
    email: 'test@example.com',
    username: 'testuser',
    role: 'USER',
  );

  group('AuthViewModel', () {
    test('should initialize with initial state', () {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      
      final state = container.read(authViewModelProvider);
      expect(state.isAuthenticated, false);
      expect(state.isLoading, false);
      expect(state.user, isNull);
      container.dispose();
    });

    test('should update state to authenticated on successful login', () async {
      when(mockRepository.login(
        emailOrUsername: anyNamed('emailOrUsername'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => Right(testAuthEntity));

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepository),
          profileRepositoryProvider.overrideWithValue(mockProfileRepository),
        ],
      );
      
      final notifier = container.read(authViewModelProvider.notifier);
      await notifier.login(
        emailOrUsername: 'test@example.com',
        password: 'password123',
      );

      await Future.delayed(const Duration(milliseconds: 200));
      
      final state = container.read(authViewModelProvider);
      expect(state.isAuthenticated, true);
      expect(state.user, testAuthEntity);
      expect(state.errorMessage, isNull);
      container.dispose();
    });

    test('should update state to error on login failure', () async {
      when(mockRepository.login(
        emailOrUsername: anyNamed('emailOrUsername'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => Left(AuthenticationFailure('Invalid credentials')));

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      
      final notifier = container.read(authViewModelProvider.notifier);
      await notifier.login(
        emailOrUsername: 'wrong@example.com',
        password: 'wrongpassword',
      );

      await Future.delayed(const Duration(milliseconds: 100));
      
      final state = container.read(authViewModelProvider);
      expect(state.isAuthenticated, false);
      expect(state.errorMessage, 'Invalid credentials');
      container.dispose();
    });

    test('should update state to initial on successful logout', () async {
      when(mockRepository.logout())
          .thenAnswer((_) async => const Right(null));

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepository),
          profileRepositoryProvider.overrideWithValue(mockProfileRepository),
        ],
      );
      
      await container.read(authViewModelProvider.notifier).logout();

      final state = container.read(authViewModelProvider);
      expect(state.isAuthenticated, false);
      expect(state.user, isNull);
      verify(mockRepository.logout()).called(1);
      container.dispose();
    });
  });
}
