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
  }) async {
    try {
      final body = <String, dynamic>{
        'fullName': fullName,
        'email': email,
        'password': password,
      };

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
      // Trim the input to remove any whitespace
      final trimmedEmailOrUsername = emailOrUsername.trim();
      final trimmedPassword = password.trim();
      
      print('🔍 Login request: emailOrUsername=$trimmedEmailOrUsername, password length=${trimmedPassword.length}');
      
      // Backend validation expects "email" field (not "emailOrUsername")
      final requestBody = {
        'email': trimmedEmailOrUsername, // Backend expects "email" field
        'password': trimmedPassword,
      };
      
      print('📤 Sending request body: $requestBody');
      
      final response = await _dio.post(
        '/api/auth/login',
        data: requestBody,
      );

      print('✅ Login response received: ${response.statusCode}');
      print('📥 Response data: ${response.data}');
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      // Extract error message from response
      String? message;
      if (e.response?.data != null) {
        print('❌ Login error: ${e.response?.statusCode} - ${e.response?.data}');
        if (e.response!.data is Map) {
          message = e.response!.data['message'] as String? ??
              e.response!.data['error'] as String?;
          // Handle validation errors
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
      } else {
        print('❌ Login error (no response): ${e.message}');
      }
      message ??= e.message ?? 'Login failed';
      throw Exception(message);
    } catch (e) {
      print('❌ Login exception: $e');
      throw Exception('Login failed: ${e.toString()}');
    }
  }
}
