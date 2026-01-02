import 'package:equatable/equatable.dart';
import '../../domain/entities/profile_entity.dart';

/// Profile state
class ProfileState extends Equatable {
  final bool isLoading;
  final ProfileEntity? profile;
  final String? errorMessage;

  const ProfileState({
    this.isLoading = false,
    this.profile,
    this.errorMessage,
  });

  /// Initial state
  const ProfileState.initial()
      : isLoading = false,
        profile = null,
        errorMessage = null;

  /// Loading state
  const ProfileState.loading()
      : isLoading = true,
        profile = null,
        errorMessage = null;

  /// Loaded state
  const ProfileState.loaded(this.profile)
      : isLoading = false,
        errorMessage = null;

  /// Error state
  const ProfileState.error(this.errorMessage)
      : isLoading = false,
        profile = null;

  /// Create a copy with updated fields
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

