import 'package:dio/dio.dart';
import '../../models/auth_response_model.dart';

class AuthRemoteDatasource {
  final Dio _dio;

  AuthRemoteDatasource({required Dio dio}) : _dio = dio;

  Future<AuthResponseModel> register({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
    String? username,
    String? role,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': fullName,
        'email': email,
        'password': password,
      };
      
      if (role != null && role.isNotEmpty) {
        body['role'] = role;
      }

      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        body['phoneNumber'] = phoneNumber;
      }
      if (username != null && username.isNotEmpty) {
        body['username'] = username;
      }

      final response = await _dio.post(
        '/api/auth/register',
        data: body,
      );

      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Registration failed';
      throw Exception(message);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<AuthResponseModel> login({
    required String emailOrUsername,
    required String password,
  }) async {
    try {
      final trimmedEmailOrUsername = emailOrUsername.trim();
      final trimmedPassword = password.trim();
      
      final requestBody = {
        'email': trimmedEmailOrUsername,
        'password': trimmedPassword,
      };
      
      final response = await _dio.post(
        '/api/auth/login',
        data: requestBody,
      );
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      String? message;
      if (e.response?.data != null) {
        if (e.response!.data is Map) {
          message = e.response!.data['message'] as String? ??
              e.response!.data['error'] as String?;

          if (message == null && e.response!.data.containsKey('errors')) {
            final errors = e.response!.data['errors'];
            if (errors is Map) {
              final firstError = errors.values.first;
              if (firstError is List && firstError.isNotEmpty) {
                message = firstError.first.toString();
              } else if (firstError is String) {
                message = firstError;
              }
            }
          }
        } else if (e.response!.data is String) {
          message = e.response!.data as String;
        }
      }
      message ??= e.message ?? 'Login failed';
      throw Exception(message);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _dio.get('/api/auth/me');
      final data = response.data;
      if (data is Map && data.containsKey('user')) {
        return data['user'] as Map<String, dynamic>;
      }
      return data as Map<String, dynamic>;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to fetch user';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to fetch user: ${e.toString()}');
    }
  }
}
