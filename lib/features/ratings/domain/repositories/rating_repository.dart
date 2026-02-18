import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/rating_entity.dart';

abstract class RatingRepository {
  Future<Either<Failure, RatingEntity>> submitRating({
    required String bookingId,
    required String providerId,
    required int rating,
    String? comment,
  });
  Future<Either<Failure, List<RatingEntity>>> getProviderRatings(String providerId);
  Future<Either<Failure, List<RatingEntity>>> getUserRatings(String userId);
  Future<Either<Failure, RatingEntity?>> getRatingForBooking(String bookingId);
}
