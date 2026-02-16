import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../../services/domain/entities/service_item.dart';
import '../../../services/data/repositories/services_repository_impl.dart';
import '../datasources/favorites_local_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource localDataSource;
  final ServicesRepositoryImpl servicesRepository;

  FavoritesRepositoryImpl({
    required this.localDataSource,
    required this.servicesRepository,
  });

  @override
  Future<Either<Failure, List<ServiceItem>>> getFavoriteServices() async {
    try {
      final favorites = await localDataSource.getFavorites();
      if (favorites.isEmpty) {
        return const Right([]);
      }

      final allServicesResult = await servicesRepository.getServicesByCategory('all');
      
      return allServicesResult.fold(
        (failure) => Left(failure),
        (allServices) {
          final favoriteServiceIds = favorites.map((f) => f.serviceId).toSet();
          final favoriteServices = allServices
              .where((service) => favoriteServiceIds.contains(service.id))
              .toList();
          return Right(favoriteServices);
        },
      );
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addFavorite(String serviceId) async {
    try {
      await localDataSource.addFavorite(serviceId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite(String serviceId) async {
    try {
      await localDataSource.removeFavorite(serviceId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(String serviceId) async {
    try {
      final isFav = await localDataSource.isFavorite(serviceId);
      return Right(isFav);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
