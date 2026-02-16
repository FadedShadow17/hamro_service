import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/profession_repository_impl.dart';
import '../../domain/entities/profession_entity.dart';

final professionRepositoryProvider = Provider<ProfessionRepositoryImpl>((ref) {
  throw UnimplementedError('professionRepositoryProvider must be overridden');
});

final professionsProvider = FutureProvider<List<ProfessionEntity>>((ref) async {
  final repository = ref.watch(professionRepositoryProvider);
  final result = await repository.getAllProfessions();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (professions) => professions,
  );
});
