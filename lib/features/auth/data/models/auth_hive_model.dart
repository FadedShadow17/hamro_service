import 'package:hive/hive.dart';
import '../../../../core/constants/hive_table_constant.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.authHiveModelTypeId)
class AuthHiveModel {
  @HiveField(0)
  final String authId;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? username;

  @HiveField(4)
  final String password;

  @HiveField(5)
  final String? phoneNumber;

  AuthHiveModel({
    required this.authId,
    required this.fullName,
    required this.email,
    this.username,
    required this.password,
    this.phoneNumber,
  });

  AuthHiveModel copyWith({
    String? authId,
    String? fullName,
    String? email,
    String? username,
    String? password,
    String? phoneNumber,
  }) {
    return AuthHiveModel(
      authId: authId ?? this.authId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

