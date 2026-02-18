import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadApi {
  final Dio _dio;

  ImageUploadApi({required Dio dio}) : _dio = dio;

  /// Uploads an image via multipart/form-data to `/api/upload/image`
  /// with field name `image` and returns the public URL.
  ///
  /// Accepts either [file] or [xFile]. Exactly one must be provided.
  Future<String> uploadImage({File? file, XFile? xFile}) async {
    if ((file == null && xFile == null) || (file != null && xFile != null)) {
      throw Exception('Please provide exactly one image to upload.');
    }

    try {
      final String filePath = file?.path ?? xFile!.path;
      final String filename = filePath.split(Platform.pathSeparator).last;

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          filePath,
          filename: filename,
        ),
      });

      final response = await _dio.post(
        '/api/upload/image',
        data: formData,
        // Don't set Content-Type header - Dio will automatically set it with the correct boundary
        // when using FormData
      );

      final data = response.data;
      final url = (data is Map) ? (data['url'] as String?) : null;

      if (url == null || url.isEmpty) {
        throw Exception('Upload failed: missing image URL in response.');
      }

      return url;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Image upload failed';
      throw Exception(message);
    } catch (e) {
      throw Exception('Image upload failed: ${e.toString()}');
    }
  }
}

