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

  factory ServiceItemModel.fromJson(Map<String, dynamic> json) {
    return ServiceItemModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? json['name'] ?? '',
      priceRs: (json['price'] ?? json['priceRs'] ?? 0.0).toDouble(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewsCount: json['reviewsCount'] ?? json['reviews'] ?? 0,
      categoryTag: json['category']?['name'] ?? 
                  json['categoryName'] ?? 
                  json['category'] ?? '',
      providerId: json['providerId'] ?? json['provider']?['_id'],
      providerName: json['provider']?['name'] ?? json['providerName'],
      providerAvatarUrl: json['provider']?['avatar'] ?? json['providerAvatarUrl'],
    );
  }

  ServiceItem toEntity() {
    return ServiceItem(
      id: id,
      title: title,
      priceRs: priceRs,
      rating: rating,
      reviewsCount: reviewsCount,
      categoryTag: categoryTag,
      providerId: providerId,
      providerName: providerName,
      providerAvatarUrl: providerAvatarUrl,
    );
  }
}
