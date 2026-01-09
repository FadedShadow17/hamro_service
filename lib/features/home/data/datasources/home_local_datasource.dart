import '../models/service_category_model.dart';
import '../models/popular_service_model.dart';

abstract class HomeLocalDataSource {
  Future<List<ServiceCategoryModel>> getMostBookedServices();
  Future<List<PopularServiceModel>> getPopularServices();
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  @override
  Future<List<ServiceCategoryModel>> getMostBookedServices() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return const [
      ServiceCategoryModel(
        id: '1',
        name: 'Plumber',
        iconKey: 'plumber',
      ),
      ServiceCategoryModel(
        id: '2',
        name: 'Electrician',
        iconKey: 'electrician',
      ),
      ServiceCategoryModel(
        id: '3',
        name: 'Carpenter',
        iconKey: 'carpenter',
      ),
      ServiceCategoryModel(
        id: '4',
        name: 'Painter',
        iconKey: 'painter',
      ),
      ServiceCategoryModel(
        id: '5',
        name: 'Mason',
        iconKey: 'mason',
      ),
      ServiceCategoryModel(
        id: '6',
        name: 'Welder',
        iconKey: 'welder',
      ),
      ServiceCategoryModel(
        id: '7',
        name: 'Roofer',
        iconKey: 'roofer',
      ),
      ServiceCategoryModel(
        id: '8',
        name: 'More',
        iconKey: 'more',
      ),
    ];
  }

  @override
  Future<List<PopularServiceModel>> getPopularServices() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return const [
      PopularServiceModel(
        id: '1',
        title: 'Expert Plumbing',
        priceRs: 450,
        categoryTag: 'Plumber',
      ),
      PopularServiceModel(
        id: '2',
        title: 'Electrical Repair',
        priceRs: 550,
        categoryTag: 'Electrician',
      ),
      PopularServiceModel(
        id: '3',
        title: 'Carpentry Work',
        priceRs: 650,
        categoryTag: 'Carpenter',
      ),
      PopularServiceModel(
        id: '4',
        title: 'House Painting',
        priceRs: 999,
        categoryTag: 'Painter',
      ),
      PopularServiceModel(
        id: '5',
        title: 'Masonry Services',
        priceRs: 750,
        categoryTag: 'Mason',
      ),
    ];
  }
}
