import '../../domain/entities/service_item.dart';

class ServiceItemModel extends ServiceItem {
  const ServiceItemModel({
    required super.id,
    required super.title,
    required super.priceRs,
    required super.rating,
    required super.reviewsCount,
    required super.categoryTag,
    super.providerId,
    super.providerName,
    super.providerAvatarUrl,
  });

  factory ServiceItemModel.fromEntity(ServiceItem entity) {
    return ServiceItemModel(
      id: entity.id,
      title: entity.title,
      priceRs: entity.priceRs,
      rating: entity.rating,
      reviewsCount: entity.reviewsCount,
      categoryTag: entity.categoryTag,
      providerId: entity.providerId,
      providerName: entity.providerName,
      providerAvatarUrl: entity.providerAvatarUrl,
    );
  }
}
