import 'dart:io';
import 'package:dio/dio.dart';
import '../../../domain/entities/profile_entity.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileEntity> getProfile();
  Future<ProfileEntity> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? description,
  });
  Future<ProfileEntity> updateRole(String role);
  Future<ProfileEntity> uploadAvatar(File imageFile);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio _dio;

  ProfileRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<ProfileEntity> getProfile() async {
    try {
      final response = await _dio.get('/api/auth/me');
      final data = response.data;

      final userData = data is Map && data.containsKey('user')
          ? data['user']
          : data;

      return ProfileEntity(
        userId: userData['_id'] ?? userData['id'] ?? '',
        fullName: userData['name'] ?? userData['fullName'] ?? '',
        email: userData['email'] ?? '',
        phoneNumber: userData['phone'] ?? userData['phoneNumber'],
        avatarUrl: userData['profileImageUrl'] ?? 
                   userData['avatar'] ?? 
                   userData['avatarUrl'],
        address: userData['address'],
        description: userData['description'],
        role: userData['role'],
      );
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to fetch profile';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to fetch profile: ${e.toString()}');
    }
  }

  @override
  Future<ProfileEntity> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? description,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null && name.isNotEmpty) {
        body['name'] = name;
      }
      if (phone != null && phone.isNotEmpty) {
        body['phone'] = phone;
      }
      if (address != null && address.isNotEmpty) {
        body['address'] = address;
      }
      if (description != null && description.isNotEmpty) {
        body['description'] = description;
      }

      final response = await _dio.patch('/api/users/me', data: body);
      final data = response.data;

      final userData = data is Map && data.containsKey('user')
          ? data['user']
          : data;

      return ProfileEntity(
        userId: userData['_id'] ?? userData['id'] ?? '',
        fullName: userData['name'] ?? userData['fullName'] ?? '',
        email: userData['email'] ?? '',
        phoneNumber: userData['phone'] ?? userData['phoneNumber'],
        avatarUrl: userData['profileImageUrl'] ?? 
                   userData['avatar'] ?? 
                   userData['avatarUrl'],
        address: userData['address'],
        description: userData['description'],
        role: userData['role'],
      );
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to update profile';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Future<ProfileEntity> updateRole(String role) async {
    try {
      final response = await _dio.patch(
        '/api/users/me',
        data: {'role': role},
      );
      final data = response.data;

      final userData = data is Map && data.containsKey('user')
          ? data['user']
          : data;

      return ProfileEntity(
        userId: userData['_id'] ?? userData['id'] ?? '',
        fullName: userData['name'] ?? userData['fullName'] ?? '',
        email: userData['email'] ?? '',
        phoneNumber: userData['phone'] ?? userData['phoneNumber'],
        avatarUrl: userData['profileImageUrl'] ?? 
                   userData['avatar'] ?? 
                   userData['avatarUrl'],
        address: userData['address'],
        description: userData['description'],
        role: userData['role'],
      );
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to update role';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to update role: ${e.toString()}');
    }
  }

  @override
  Future<ProfileEntity> uploadAvatar(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        '/api/users/me/avatar',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      final data = response.data;
      Map<String, dynamic> userData;
      
      if (data is Map<String, dynamic>) {
        if (data.containsKey('user')) {
          final user = data['user'];
          userData = user is Map<String, dynamic> ? user : Map<String, dynamic>.from(user as Map);
        } else {
          userData = data;
        }
      } else {
        userData = {};
      }

      return ProfileEntity(
        userId: userData['_id']?.toString() ?? userData['id']?.toString() ?? '',
        fullName: userData['name']?.toString() ?? userData['fullName']?.toString() ?? '',
        email: userData['email']?.toString() ?? '',
        phoneNumber: userData['phone']?.toString() ?? userData['phoneNumber']?.toString(),
        avatarUrl: userData['profileImageUrl']?.toString() ?? 
                   userData['avatar']?.toString() ?? 
                   userData['avatarUrl']?.toString(),
        address: userData['address']?.toString(),
        description: userData['description']?.toString(),
      );
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to upload avatar';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to upload avatar: ${e.toString()}');
    }
  }
}
