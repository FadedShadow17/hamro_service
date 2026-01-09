import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String userId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? avatarUrl;
  final String? address;
  final String? description;

  const ProfileEntity({
    required this.userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.address,
    this.description,
  });

  @override
  List<Object?> get props => [
        userId,
        fullName,
        email,
        phoneNumber,
        avatarUrl,
        address,
        description,
      ];
}

