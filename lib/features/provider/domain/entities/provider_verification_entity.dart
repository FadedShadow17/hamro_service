import 'package:equatable/equatable.dart';

class ProviderVerificationEntity extends Equatable {
  final String verificationStatus;
  final String? fullName;
  final String? phoneNumber;
  final String? citizenshipNumber;
  final String? serviceRole;
  final Map<String, dynamic>? address;
  final String? citizenshipFrontImage;
  final String? citizenshipBackImage;
  final String? profileImage;
  final String? selfieImage;
  final DateTime? verifiedAt;
  final String? rejectionReason;

  const ProviderVerificationEntity({
    required this.verificationStatus,
    this.fullName,
    this.phoneNumber,
    this.citizenshipNumber,
    this.serviceRole,
    this.address,
    this.citizenshipFrontImage,
    this.citizenshipBackImage,
    this.profileImage,
    this.selfieImage,
    this.verifiedAt,
    this.rejectionReason,
  });

  @override
  List<Object?> get props => [
        verificationStatus,
        fullName,
        phoneNumber,
        citizenshipNumber,
        serviceRole,
        address,
        citizenshipFrontImage,
        citizenshipBackImage,
        profileImage,
        selfieImage,
        verifiedAt,
        rejectionReason,
      ];
}
