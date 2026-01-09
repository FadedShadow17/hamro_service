import 'package:hive/hive.dart';
import '../../../../core/constants/hive_table_constant.dart';

part 'profile_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.profileHiveModelTypeId)
class ProfileHiveModel {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? phoneNumber;

  @HiveField(4)
  final String? avatarUrl;

  @HiveField(5)
  final String? address;

  @HiveField(6)
  final String? description;

  ProfileHiveModel({
    required this.userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.address,
    this.description,
  });

  ProfileHiveModel copyWith({
    String? userId,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    String? address,
    String? description,
  }) {
    return ProfileHiveModel(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      address: address ?? this.address,
      description: description ?? this.description,
    );
  }
}

