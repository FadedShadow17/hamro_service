import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../services/domain/entities/service_item.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, List<ServiceItem>>> getFavoriteServices();
  Future<Either<Failure, void>> addFavorite(String serviceId);
  Future<Either<Failure, void>> removeFavorite(String serviceId);
  Future<Either<Failure, bool>> isFavorite(String serviceId);
}
