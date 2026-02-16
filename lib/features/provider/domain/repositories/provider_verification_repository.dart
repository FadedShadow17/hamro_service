import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/provider_verification_entity.dart';

abstract class ProviderVerificationRepository {
  Future<Either<Failure, ProviderVerificationEntity>> submitVerification({
    required String fullName,
    required String phoneNumber,
    required String citizenshipNumber,
    required String serviceRole,
    required Map<String, dynamic> address,
    File? citizenshipFront,
    File? citizenshipBack,
    File? profileImage,
    File? selfie,
  });
  Future<Either<Failure, ProviderVerificationEntity>> getVerificationStatus();
  Future<Either<Failure, Map<String, dynamic>>> getVerificationSummary();
}
