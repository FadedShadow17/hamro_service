import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import '../../data/datasources/favorites_local_datasource.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../../services/domain/entities/service_item.dart';
import '../../../services/presentation/providers/services_list_provider.dart';

final favoritesLocalDataSourceProvider = Provider<FavoritesLocalDataSource>((ref) {
  throw UnimplementedError('favoritesLocalDataSourceProvider must be overridden');
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  final localDataSource = ref.watch(favoritesLocalDataSourceProvider);
  final servicesRepository = ref.watch(servicesRepositoryProvider);
  return FavoritesRepositoryImpl(
    localDataSource: localDataSource,
    servicesRepository: servicesRepository,
  );
});

final favoriteServicesProvider = FutureProvider<List<ServiceItem>>((ref) async {
  final repository = ref.watch(favoritesRepositoryProvider);
  final result = await repository.getFavoriteServices();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (services) => services,
  );
});

final isFavoriteProvider = FutureProvider.family<bool, String>((ref, serviceId) async {
  final repository = ref.watch(favoritesRepositoryProvider);
  final result = await repository.isFavorite(serviceId);
  return result.fold(
    (failure) => false,
    (isFav) => isFav,
  );
});
