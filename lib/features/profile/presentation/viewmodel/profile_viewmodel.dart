import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/entities/profile_entity.dart';
import '../../../auth/presentation/view_model/auth_viewmodel.dart';
import '../state/profile_state.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  throw UnimplementedError('profileRepositoryProvider must be overridden');
});

class ProfileViewModel extends Notifier<ProfileState> {
  GetProfileUsecase? _getProfileUsecase;
  UpdateProfileUsecase? _updateProfileUsecase;

  GetProfileUsecase get getProfileUsecase {
    _getProfileUsecase ??= GetProfileUsecase(ref.read(profileRepositoryProvider));
    return _getProfileUsecase!;
  }

  UpdateProfileUsecase get updateProfileUsecase {
    _updateProfileUsecase ??= UpdateProfileUsecase(ref.read(profileRepositoryProvider));
    return _updateProfileUsecase!;
  }

  @override
  ProfileState build() {
    Future.microtask(() => loadProfile());
    return const ProfileState.initial();
  }

  Future<void> loadProfile() async {
    state = const ProfileState.loading();
    final result = await getProfileUsecase();
    result.fold(
      (failure) {
        final authState = ref.read(authViewModelProvider);
        if (authState.user != null) {
          final profile = ProfileEntity(
            userId: authState.user!.authId,
            fullName: authState.user!.fullName,
            email: authState.user!.email,
            phoneNumber: authState.user!.phoneNumber,
          );
          updateProfile(profile);
        } else {
          state = ProfileState.error(failure.message);
        }
      },
      (profile) {
        if (profile == null) {
          final authState = ref.read(authViewModelProvider);
          if (authState.user != null) {
            final newProfile = ProfileEntity(
              userId: authState.user!.authId,
              fullName: authState.user!.fullName,
              email: authState.user!.email,
              phoneNumber: authState.user!.phoneNumber,
            );
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

  Future<void> updateProfile(ProfileEntity profile) async {
    state = const ProfileState.loading();
    final result = await updateProfileUsecase(profile);
    result.fold(
      (failure) => state = ProfileState.error(failure.message),
      (updatedProfile) {
        state = ProfileState.loaded(updatedProfile);
        loadProfile();
      },
    );
  }

  void resetProfile() {
    state = const ProfileState.initial();
  }
}

final profileViewModelProvider =
    NotifierProvider<ProfileViewModel, ProfileState>(() => ProfileViewModel());