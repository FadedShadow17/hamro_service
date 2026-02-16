import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/contact_repository_impl.dart';
import '../../domain/entities/contact_entity.dart';

final contactRepositoryProvider = Provider<ContactRepositoryImpl>((ref) {
  throw UnimplementedError('contactRepositoryProvider must be overridden');
});

final testimonialsProvider = FutureProvider<List<ContactEntity>>((ref) async {
  final repository = ref.watch(contactRepositoryProvider);
  final result = await repository.getTestimonials(limit: 3);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (testimonials) => testimonials,
  );
});
