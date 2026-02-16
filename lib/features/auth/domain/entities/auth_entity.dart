import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String authId;
  final String fullName;
  final String email;
  final String? username;
  final String? phoneNumber;
  final String? role;

  const AuthEntity({
    required this.authId,
    required this.fullName,
    required this.email,
    this.username,
    this.phoneNumber,
    this.role,
  });

  @override
  List<Object?> get props => [authId, fullName, email, username, phoneNumber, role];
}

