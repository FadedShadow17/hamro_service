import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadApi {
  final Dio _dio;

  ImageUploadApi({required Dio dio}) : _dio = dio;

  Future<String> uploadImage({File? file, XFile? xFile}) async {
    if ((file == null && xFile == null) || (file != null && xFile != null)) {
      throw Exception('Please provide exactly one image to upload.');
    }

    try {
      final String filePath = file?.path ?? xFile!.path;
      final fileToUpload = file ?? File(filePath);
      
      if (!await fileToUpload.exists()) {
        throw Exception('Image file does not exist at path: $filePath');
      }

      final String filename = filePath.split(Platform.pathSeparator).last;
      
      if (filename.isEmpty) {
        throw Exception('Invalid filename');
      }

      final fileSize = await fileToUpload.length();
      if (fileSize == 0) {
        throw Exception('Image file is empty');
      }

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          filePath,
          filename: filename,
        ),
      });

      final response = await _dio.post(
        '/api/upload/image',
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Upload failed with status code: ${response.statusCode}');
      }

      final data = response.data;
      String? url;
      
      if (data is Map<String, dynamic>) {
        url = data['url'] as String?;
      } else if (data is Map) {
        final mapData = Map<String, dynamic>.from(data);
        url = mapData['url'] as String?;
      } else if (data is List) {
        if (data.isNotEmpty && data[0] is Map) {
          final firstItem = Map<String, dynamic>.from(data[0] as Map);
          url = firstItem['url'] as String?;
        } else if (data.isNotEmpty && data[0] is String) {
          url = data[0] as String;
        } else {
          throw Exception('Upload failed: unexpected List response format. Response: ${response.data}');
        }
      } else {
        throw Exception('Upload failed: unexpected response format. Expected Map, got ${data.runtimeType}. Response: ${response.data}');
      }

      if (url == null || url.isEmpty) {
        throw Exception('Upload failed: missing image URL in response. Response: ${response.data}');
      }

      if (url.startsWith('/')) {
        final baseUrl = _dio.options.baseUrl;
        if (baseUrl.isNotEmpty) {
          final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
          url = '$cleanBaseUrl$url';
        }
      }

      return url;
    } on DioException catch (e) {
      String message = 'Image upload failed';
      
      if (e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map) {
          message = responseData['message'] ?? 
                   responseData['error'] ?? 
                   responseData['msg'] ??
                   'Image upload failed';
        } else if (responseData is String) {
          message = responseData;
        }
      } else if (e.message != null) {
        message = e.message!;
      }
      
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout) {
        message = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        message = 'Connection error. Please check your internet connection and server URL.';
      }
      
      throw Exception(message);
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Image upload failed: ${e.toString()}');
    }
  }
}

