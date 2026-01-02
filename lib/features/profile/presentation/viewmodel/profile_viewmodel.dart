import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/entities/profile_entity.dart';
import '../../../auth/presentation/viewmodel/auth_viewmodel.dart';
import '../state/profile_state.dart';

/// Provider for ProfileRepository (to be provided in main or app setup)
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  throw UnimplementedError('profileRepositoryProvider must be overridden');
});

/// ViewModel for profile using NotifierProvider
class ProfileViewModel extends Notifier<ProfileState> {
  late final GetProfileUsecase _getProfileUsecase;
  late final UpdateProfileUsecase _updateProfileUsecase;

  @override
  ProfileState build() {
    final repository = ref.read(profileRepositoryProvider);
    _getProfileUsecase = GetProfileUsecase(repository);
    _updateProfileUsecase = UpdateProfileUsecase(repository);

    // Load profile on init
    Future.microtask(() => loadProfile());

    return const ProfileState.initial();
  }

  /// Load user profile
  Future<void> loadProfile() async {
    state = const ProfileState.loading();
    final result = await _getProfileUsecase();
    result.fold(
      (failure) {
        // If profile doesn't exist, try to create from auth data
        final authState = ref.read(authViewModelProvider);
        if (authState.user != null) {
          // Create profile from auth user data
          final profile = ProfileEntity(
            userId: authState.user!.authId,
            fullName: authState.user!.fullName,
            email: authState.user!.email,
            phoneNumber: authState.user!.phoneNumber,
          );
          // Save the profile
          updateProfile(profile);
        } else {
          state = ProfileState.error(failure.message);
        }
      },
      (profile) {
        if (profile == null) {
          // Profile doesn't exist, create from auth data
          final authState = ref.read(authViewModelProvider);
          if (authState.user != null) {
            final newProfile = ProfileEntity(
              userId: authState.user!.authId,
              fullName: authState.user!.fullName,
              email: authState.user!.email,
              phoneNumber: authState.user!.phoneNumber,
            );
            // Save the profile
            updateProfile(newProfile);
          } else {
            state = const ProfileState.loaded(null);
          }
        } else {
          state = ProfileState.loaded(profile);
        }
      },
    );
  }

  /// Update user profile
  Future<void> updateProfile(ProfileEntity profile) async {
    state = const ProfileState.loading();
    final result = await _updateProfileUsecase(profile);
    result.fold(
      (failure) => state = ProfileState.error(failure.message),
      (updatedProfile) => state = ProfileState.loaded(updatedProfile),
    );
  }
}

/// Provider for ProfileViewModel
final profileViewModelProvider =
    NotifierProvider<ProfileViewModel, ProfileState>(
  () => ProfileViewModel(),
);

