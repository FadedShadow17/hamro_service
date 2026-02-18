import 'package:equatable/equatable.dart';

class RatingEntity extends Equatable {
  final String id;
  final String bookingId;
  final String userId;
  final String providerId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  const RatingEntity({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.providerId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        bookingId,
        userId,
        providerId,
        rating,
        comment,
        createdAt,
      ];
}
