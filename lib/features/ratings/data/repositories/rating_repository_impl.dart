import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/connectivity/connectivity_service.dart';
import '../../domain/entities/rating_entity.dart';
import '../../domain/repositories/rating_repository.dart';
import '../datasources/rating_remote_datasource.dart';

class RatingRepositoryImpl implements RatingRepository {
  final RatingRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;

  RatingRepositoryImpl({
    required this.remoteDataSource,
    required this.connectivityService,
  });

  @override
  Future<Either<Failure, RatingEntity>> submitRating({
    required String bookingId,
    required String providerId,
    required int rating,
    String? comment,
  }) async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final ratingModel = await remoteDataSource.submitRating(
        bookingId: bookingId,
        providerId: providerId,
        rating: rating,
        comment: comment,
      );
      return Right(ratingModel.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RatingEntity>>> getProviderRatings(String providerId) async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final ratings = await remoteDataSource.getProviderRatings(providerId);
      return Right(ratings.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RatingEntity>>> getUserRatings(String userId) async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final ratings = await remoteDataSource.getUserRatings(userId);
      return Right(ratings.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RatingEntity?>> getRatingForBooking(String bookingId) async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final rating = await remoteDataSource.getRatingForBooking(bookingId);
      return Right(rating?.toEntity());
    } catch (e) {
      return const Right(null);
    }
  }
}
