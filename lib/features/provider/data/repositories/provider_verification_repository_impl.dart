import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/connectivity/connectivity_service.dart';
import '../../domain/entities/provider_verification_entity.dart';
import '../../domain/repositories/provider_verification_repository.dart';
import '../datasources/provider_verification_remote_datasource.dart';
import '../models/provider_verification_model.dart';

class ProviderVerificationRepositoryImpl implements ProviderVerificationRepository {
  final ProviderVerificationRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;

  ProviderVerificationRepositoryImpl({
    required this.remoteDataSource,
    required this.connectivityService,
  });

  @override
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
  }) async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final verification = await remoteDataSource.submitVerification(
        fullName: fullName,
        phoneNumber: phoneNumber,
        citizenshipNumber: citizenshipNumber,
        serviceRole: serviceRole,
        address: address,
        citizenshipFront: citizenshipFront,
        citizenshipBack: citizenshipBack,
        profileImage: profileImage,
        selfie: selfie,
      );
      return Right(verification.toEntity());
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    } catch (e) {
      return Left(ServerFailure('Failed to submit verification: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ProviderVerificationEntity>> getVerificationStatus() async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final verification = await remoteDataSource.getVerificationStatus();
      return Right(verification.toEntity());
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch verification status: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getVerificationSummary() async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final summary = await remoteDataSource.getVerificationSummary();
      return Right(summary);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch verification summary: ${e.toString()}'));
    }
  }
}
