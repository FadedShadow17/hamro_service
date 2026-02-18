import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamro_service/core/error/failures.dart';
import 'package:hamro_service/features/auth/domain/repositories/auth_repository.dart';
import 'package:hamro_service/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:hamro_service/features/auth/presentation/state/auth_state.dart';
import 'package:hamro_service/features/profile/domain/entities/profile_entity.dart';
import 'package:hamro_service/features/profile/domain/repositories/profile_repository.dart';
import 'package:hamro_service/features/profile/presentation/viewmodel/profile_viewmodel.dart';
import 'package:hamro_service/features/profile/presentation/state/profile_state.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([ProfileRepository, AuthRepository])
import 'profile_viewmodel_test.mocks.dart';

void main() {
  late MockProfileRepository mockRepository;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    mockAuthRepository = MockAuthRepository();
  });

  const testProfileEntity = ProfileEntity(
    userId: '123',
    fullName: 'Test User',
    email: 'test@example.com',
    phoneNumber: '1234567890',
  );

  group('ProfileViewModel', () {
    test('should initialize with initial state', () {
      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      
      final state = container.read(profileViewModelProvider);
      expect(state.isLoading, false);
      container.dispose();
    });

    test('should load profile successfully', () async {
      when(mockRepository.getProfile())
          .thenAnswer((_) async => Right(testProfileEntity));

      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(mockRepository),
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );
      
      await container.read(profileViewModelProvider.notifier).loadProfile();

      final state = container.read(profileViewModelProvider);
      expect(state.profile, testProfileEntity);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);
      container.dispose();
    });

    test('should update profile successfully', () async {
      const updatedProfile = ProfileEntity(
        userId: '123',
        fullName: 'Updated User',
        email: 'updated@example.com',
      );

      when(mockRepository.updateProfile(any))
          .thenAnswer((_) async => Right(updatedProfile));
      when(mockRepository.getProfile())
          .thenAnswer((_) async => Right(updatedProfile));

      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(mockRepository),
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );
      
      await container.read(profileViewModelProvider.notifier).updateProfile(updatedProfile);

      final state = container.read(profileViewModelProvider);
      expect(state.profile, updatedProfile);
      verify(mockRepository.updateProfile(updatedProfile)).called(1);
      container.dispose();
    });

    test('should handle profile error state', () async {
      when(mockRepository.getProfile())
          .thenAnswer((_) async => Left(UserNotFoundFailure('Profile not found')));

      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(mockRepository),
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );
      
      await container.read(profileViewModelProvider.notifier).loadProfile();

      final state = container.read(profileViewModelProvider);
      expect(state.errorMessage, 'Profile not found');
      expect(state.isLoading, false);
      container.dispose();
    });
  });
}
