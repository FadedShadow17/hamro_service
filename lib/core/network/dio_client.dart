import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../services/storage/user_session_service.dart';

class DioClient {
  final Dio dio;
  final UserSessionService _sessionService;

  DioClient({required UserSessionService session})
      : _sessionService = session,
        dio = Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        ) {
    // Add logging interceptor for debugging
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
      ),
    );
    
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _sessionService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            _sessionService.clearToken();
            _sessionService.clearSession();
          }
          handler.next(error);
        },
      ),
    );
  }
}
