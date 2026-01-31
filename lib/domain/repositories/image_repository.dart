import 'dart:io';

abstract class ImageRepository {
  Future<String> uploadImage(File image);
}

