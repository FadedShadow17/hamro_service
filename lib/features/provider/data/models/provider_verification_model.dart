import '../../domain/entities/provider_verification_entity.dart';

class ProviderVerificationModel extends ProviderVerificationEntity {
  const ProviderVerificationModel({
    required super.verificationStatus,
    super.fullName,
    super.phoneNumber,
    super.citizenshipNumber,
    super.serviceRole,
    super.address,
    super.citizenshipFrontImage,
    super.citizenshipBackImage,
    super.profileImage,
    super.selfieImage,
    super.verifiedAt,
    super.rejectionReason,
  });

  factory ProviderVerificationModel.fromJson(Map<String, dynamic> json) {
    return ProviderVerificationModel(
      verificationStatus: json['verificationStatus'] ?? json['status'] ?? 'NOT_SUBMITTED',
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      citizenshipNumber: json['citizenshipNumber'],
      serviceRole: json['serviceRole'],
      address: json['address'] is Map ? Map<String, dynamic>.from(json['address']) : null,
      citizenshipFrontImage: json['citizenshipFrontImage'],
      citizenshipBackImage: json['citizenshipBackImage'],
      profileImage: json['profileImage'],
      selfieImage: json['selfieImage'],
      verifiedAt: json['verifiedAt'] != null ? DateTime.parse(json['verifiedAt']) : null,
      rejectionReason: json['rejectionReason'],
    );
  }

  ProviderVerificationEntity toEntity() {
    return ProviderVerificationEntity(
      verificationStatus: verificationStatus,
      fullName: fullName,
      phoneNumber: phoneNumber,
      citizenshipNumber: citizenshipNumber,
      serviceRole: serviceRole,
      address: address,
      citizenshipFrontImage: citizenshipFrontImage,
      citizenshipBackImage: citizenshipBackImage,
      profileImage: profileImage,
      selfieImage: selfieImage,
      verifiedAt: verifiedAt,
      rejectionReason: rejectionReason,
    );
  }
}
