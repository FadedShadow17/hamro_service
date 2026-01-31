import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/repositories/image_repository.dart';

final imageRepositoryProvider = Provider<ImageRepository>((ref) {
  throw UnimplementedError('imageRepositoryProvider must be overridden');
});

class ImageUploadState {
  final bool isLoading;
  final String? url;
  final String? errorMessage;

  const ImageUploadState({
    this.isLoading = false,
    this.url,
    this.errorMessage,
  });

  const ImageUploadState.idle()
      : isLoading = false,
        url = null,
        errorMessage = null;

  const ImageUploadState.loading()
      : isLoading = true,
        url = null,
        errorMessage = null;

  const ImageUploadState.success(this.url)
      : isLoading = false,
        errorMessage = null;

  const ImageUploadState.error(this.errorMessage)
      : isLoading = false,
        url = null;
}

class ImageUploadNotifier extends Notifier<ImageUploadState> {
  late final ImageRepository _repository;

  @override
  ImageUploadState build() {
    _repository = ref.read(imageRepositoryProvider);
    return const ImageUploadState.idle();
  }

  Future<String?> uploadImage(File image) async {
    state = const ImageUploadState.loading();
    try {
      final url = await _repository.uploadImage(image);
      state = ImageUploadState.success(url);
      return url;
    } catch (e) {
      state = ImageUploadState.error(e.toString().replaceFirst('Exception: ', ''));
      return null;
    }
  }

  void reset() {
    state = const ImageUploadState.idle();
  }
}

final imageUploadNotifierProvider =
    NotifierProvider<ImageUploadNotifier, ImageUploadState>(() {
  return ImageUploadNotifier();
});

