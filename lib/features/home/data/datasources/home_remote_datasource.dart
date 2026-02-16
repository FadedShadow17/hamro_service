import 'package:dio/dio.dart';
import '../models/service_category_model.dart';
import '../models/popular_service_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<ServiceCategoryModel>> getServiceCategories();
  Future<List<PopularServiceModel>> getPopularServices();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio _dio;

  HomeRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<ServiceCategoryModel>> getServiceCategories() async {
    try {
      final response = await _dio.get('/api/service-categories');
      final data = response.data;
      
      if (data is Map && data.containsKey('categories')) {
        final categories = data['categories'] as List;
        return categories.map((category) {
          return ServiceCategoryModel(
            id: category['_id'] ?? category['id'] ?? '',
            name: category['name'] ?? '',
            iconKey: _mapCategoryNameToIconKey(category['name'] ?? ''),
          );
        }).toList();
      }
      
      return [];
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to fetch categories';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to fetch categories: ${e.toString()}');
    }
  }

  @override
  Future<List<PopularServiceModel>> getPopularServices() async {
    try {
      final response = await _dio.get('/api/services');
      final data = response.data;
      
      List<PopularServiceModel> services = [];
      
      if (data is Map && data.containsKey('data')) {
        final servicesList = data['data'] as List;
        services = servicesList.take(5).map((service) {
          return PopularServiceModel(
            id: service['_id'] ?? service['id'] ?? '',
            title: service['title'] ?? service['name'] ?? '',
            priceRs: (service['price'] ?? service['priceRs'] ?? 0) as int,
            categoryTag: service['category']?['name'] ?? 
                        service['categoryName'] ?? 
                        service['category'] ?? '',
          );
        }).toList();
      } else if (data is Map && data.containsKey('services')) {
        final servicesList = data['services'] as List;
        services = servicesList.take(5).map((service) {
          return PopularServiceModel(
            id: service['_id'] ?? service['id'] ?? '',
            title: service['title'] ?? service['name'] ?? '',
            priceRs: (service['price'] ?? service['priceRs'] ?? 0) as int,
            categoryTag: service['category']?['name'] ?? 
                        service['categoryName'] ?? 
                        service['category'] ?? '',
          );
        }).toList();
      }
      
      return services;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to fetch services';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to fetch services: ${e.toString()}');
    }
  }

  String _mapCategoryNameToIconKey(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('plumb')) return 'plumber';
    if (name.contains('electric')) return 'electrician';
    if (name.contains('carpent')) return 'carpenter';
    if (name.contains('paint')) return 'painter';
    if (name.contains('mason')) return 'mason';
    if (name.contains('weld')) return 'welder';
    if (name.contains('roof')) return 'roofer';
    return 'more';
  }
}
