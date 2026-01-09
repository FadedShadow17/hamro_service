import '../../domain/entities/service_item.dart';

/// Local data source for services
abstract class ServicesLocalDataSource {
  Future<List<ServiceItem>> getServicesByCategory(String categoryIdOrName);
}

class ServicesLocalDataSourceImpl implements ServicesLocalDataSource {
  @override
  Future<List<ServiceItem>> getServicesByCategory(String categoryIdOrName) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

    final categoryName = categoryIdOrName.toLowerCase();
    
    // Determine category tag based on selected category
    String categoryTag;
    if (categoryName == 'all') {
      categoryTag = 'Plumbing';
    } else {
      // Capitalize first letter
      categoryTag = categoryName.substring(0, 1).toUpperCase() + categoryName.substring(1);
    }

    // Return only one service: "Expert Plumbing"
    return [
      ServiceItem(
        id: 'service_1',
        title: 'Expert Plumbing',
        priceRs: 450.0,
        rating: 4.5,
        reviewsCount: 120,
        categoryTag: categoryTag,
        providerId: 'provider_1',
        providerName: 'Provider 1',
        providerAvatarUrl: null, // Placeholder
      ),
    ];
  }
}
