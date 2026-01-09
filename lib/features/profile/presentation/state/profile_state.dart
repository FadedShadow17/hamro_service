import 'package:equatable/equatable.dart';
import '../../domain/entities/profile_entity.dart';

class ProfileState extends Equatable {
  final bool isLoading;
  final ProfileEntity? profile;
  final String? errorMessage;

  const ProfileState({
    this.isLoading = false,
    this.profile,
    this.errorMessage,
  });

  const ProfileState.initial()
      : isLoading = false,
        profile = null,
        errorMessage = null;

  const ProfileState.loading()
      : isLoading = true,
        profile = null,
        errorMessage = null;

  const ProfileState.loaded(this.profile)
      : isLoading = false,
        errorMessage = null;

  const ProfileState.error(this.errorMessage)
      : isLoading = false,
        profile = null;

  ProfileState copyWith({
    bool? isLoading,
    ProfileEntity? profile,
    String? errorMessage,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, profile, errorMessage];
}

