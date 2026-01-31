import 'dart:io';

import '../../domain/repositories/image_repository.dart';
import '../data_sources/remote/image_upload_api.dart';

class ImageRepositoryImpl implements ImageRepository {
  final ImageUploadApi _api;

  ImageRepositoryImpl({required ImageUploadApi api}) : _api = api;

  @override
  Future<String> uploadImage(File image) {
    return _api.uploadImage(file: image);
  }
}

