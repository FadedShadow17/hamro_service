import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/provider_verification_model.dart';

abstract class ProviderVerificationRemoteDataSource {
  Future<ProviderVerificationModel> submitVerification({
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
  Future<ProviderVerificationModel> getVerificationStatus();
  Future<Map<String, dynamic>> getVerificationSummary();
}

class ProviderVerificationRemoteDataSourceImpl implements ProviderVerificationRemoteDataSource {
  final Dio _dio;

  ProviderVerificationRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<ProviderVerificationModel> submitVerification({
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
    try {
      final formData = FormData();

      formData.fields.addAll([
        MapEntry('fullName', fullName),
        MapEntry('phoneNumber', phoneNumber),
        MapEntry('citizenshipNumber', citizenshipNumber),
        MapEntry('serviceRole', serviceRole),
        MapEntry('address', jsonEncode(address)),
      ]);

      if (citizenshipFront != null) {
        formData.files.add(MapEntry(
          'citizenshipFront',
          await MultipartFile.fromFile(
            citizenshipFront.path,
            filename: citizenshipFront.path.split('/').last,
          ),
        ));
      }

      if (citizenshipBack != null) {
        formData.files.add(MapEntry(
          'citizenshipBack',
          await MultipartFile.fromFile(
            citizenshipBack.path,
            filename: citizenshipBack.path.split('/').last,
          ),
        ));
      }

      if (profileImage != null) {
        formData.files.add(MapEntry(
          'profileImage',
          await MultipartFile.fromFile(
            profileImage.path,
            filename: profileImage.path.split('/').last,
          ),
        ));
      }

      if (selfie != null) {
        formData.files.add(MapEntry(
          'selfie',
          await MultipartFile.fromFile(
            selfie.path,
            filename: selfie.path.split('/').last,
          ),
        ));
      }

      final response = await _dio.post(
        '/api/provider/verification',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      final profileData = response.data['profile'] ?? response.data;
      return ProviderVerificationModel.fromJson(profileData);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to submit verification';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to submit verification: ${e.toString()}');
    }
  }

  @override
  Future<ProviderVerificationModel> getVerificationStatus() async {
    try {
      final response = await _dio.get('/api/provider/verification');
      return ProviderVerificationModel.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to fetch verification status';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to fetch verification status: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getVerificationSummary() async {
    try {
      final response = await _dio.get('/api/provider/me/verification');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to fetch verification summary';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to fetch verification summary: ${e.toString()}');
    }
  }
}
