import 'package:equatable/equatable.dart';

class ServiceItem extends Equatable {
  final String id;
  final String title;
  final double priceRs;
  final double rating;
  final int reviewsCount;
  final String categoryTag;
  final String? providerId;
  final String? providerName;
  final String? providerAvatarUrl;

  const ServiceItem({
    required this.id,
    required this.title,
    required this.priceRs,
    required this.rating,
    required this.reviewsCount,
    required this.categoryTag,
    this.providerId,
    this.providerName,
    this.providerAvatarUrl,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        priceRs,
        rating,
        reviewsCount,
        categoryTag,
        providerId,
        providerName,
        providerAvatarUrl,
      ];
}
