import '../../domain/entities/rating_entity.dart';

class RatingModel extends RatingEntity {
  const RatingModel({
    required super.id,
    required super.bookingId,
    required super.userId,
    required super.providerId,
    required super.rating,
    super.comment,
    required super.createdAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    int parseRating(dynamic ratingValue) {
      if (ratingValue is int) {
        return ratingValue;
      } else if (ratingValue is num) {
        return ratingValue.toInt();
      } else if (ratingValue is String) {
        return int.tryParse(ratingValue) ?? 0;
      }
      return 0;
    }

    String parseId(dynamic idValue) {
      if (idValue == null) return '';
      if (idValue is String) return idValue;
      return idValue.toString();
    }

    return RatingModel(
      id: parseId(json['_id'] ?? json['id']),
      bookingId: parseId(json['bookingId'] ?? json['booking']),
      userId: parseId(json['userId'] ?? json['user']),
      providerId: parseId(json['providerId'] ?? json['provider']),
      rating: parseRating(json['rating']),
      comment: json['comment']?.toString() ?? json['review']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  RatingEntity toEntity() {
    return RatingEntity(
      id: id,
      bookingId: bookingId,
      userId: userId,
      providerId: providerId,
      rating: rating,
      comment: comment,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'userId': userId,
      'providerId': providerId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
