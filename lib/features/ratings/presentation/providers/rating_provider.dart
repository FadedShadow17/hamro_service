import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/rating_repository_impl.dart';
import '../../domain/entities/rating_entity.dart';

final ratingRepositoryProvider = Provider<RatingRepositoryImpl>((ref) {
  throw UnimplementedError('ratingRepositoryProvider must be overridden');
});

final providerRatingsProvider = FutureProvider.family<List<RatingEntity>, String>((ref, providerId) async {
  final repository = ref.watch(ratingRepositoryProvider);
  final result = await repository.getProviderRatings(providerId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (ratings) => ratings,
  );
});
