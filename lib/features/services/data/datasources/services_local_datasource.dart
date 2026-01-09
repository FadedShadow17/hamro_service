import '../../domain/entities/service_item.dart';

abstract class ServicesLocalDataSource {
  Future<List<ServiceItem>> getServicesByCategory(String categoryIdOrName);
}

class ServicesLocalDataSourceImpl implements ServicesLocalDataSource {
  @override
  Future<List<ServiceItem>> getServicesByCategory(String categoryIdOrName) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final categoryName = categoryIdOrName.toLowerCase();
    
    String categoryTag;
    if (categoryName == 'all') {
      categoryTag = 'Plumbing';
    } else {
      categoryTag = categoryName.substring(0, 1).toUpperCase() + categoryName.substring(1);
    }

    return [
      ServiceItem(
        id: 'service_1',
        title: 'Service Expert',
        priceRs: 1000.0,
        rating: 4.5,
        reviewsCount: 120,
        categoryTag: categoryTag,
        providerId: 'provider_1',
        providerName: 'Provider 1',
        providerAvatarUrl: null,
      ),
    ];
  }
}
