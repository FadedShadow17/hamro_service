import '../../domain/entities/provider_stats.dart';

class ProviderStatsModel extends ProviderStats {
  const ProviderStatsModel({
    required super.totalOrders,
    required super.pendingOrders,
    required super.completedOrders,
    required super.totalEarnings,
    required super.averageRating,
    required super.totalReviews,
  });

  factory ProviderStatsModel.fromEntity(ProviderStats stats) {
    return ProviderStatsModel(
      totalOrders: stats.totalOrders,
      pendingOrders: stats.pendingOrders,
      completedOrders: stats.completedOrders,
      totalEarnings: stats.totalEarnings,
      averageRating: stats.averageRating,
      totalReviews: stats.totalReviews,
    );
  }

  ProviderStats toEntity() {
    return ProviderStats(
      totalOrders: totalOrders,
      pendingOrders: pendingOrders,
      completedOrders: completedOrders,
      totalEarnings: totalEarnings,
      averageRating: averageRating,
      totalReviews: totalReviews,
    );
  }
}
