import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String authId;
  final String fullName;
  final String email;
  final String? username;
  final String? phoneNumber;

  const AuthEntity({
    required this.authId,
    required this.fullName,
    required this.email,
    this.username,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [authId, fullName, email, username, phoneNumber];
}

