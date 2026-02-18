import 'package:dio/dio.dart';
import '../models/service_item_model.dart';
import '../../../../core/utils/pricing_helper.dart';

abstract class ServicesRemoteDataSource {
  Future<List<ServiceItemModel>> getServices();
  Future<ServiceItemModel> getServiceById(String id);
  Future<List<Map<String, dynamic>>> getAvailableProviders({
    required String serviceId,
    required String date,
    required String area,
  });
}

class ServicesRemoteDataSourceImpl implements ServicesRemoteDataSource {
  final Dio _dio;

  ServicesRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<ServiceItemModel>> getServices() async {
    try {
      final response = await _dio.get('/api/services');
      final data = response.data;
      
      List<ServiceItemModel> services = [];
      
      if (data is Map && data.containsKey('data')) {
        final servicesList = data['data'] as List;
        services = servicesList.map((service) {
          final categoryTag = service['category']?['name'] ?? 
                             service['categoryName'] ?? 
                             service['category'] ?? '';
          final rawPrice = service['price'] ?? service['priceRs'] ?? 0.0;
          final priceRs = PricingHelper.getPriceWithFallback(rawPrice, categoryTag);
          
          return ServiceItemModel(
            id: service['_id'] ?? service['id'] ?? '',
            title: service['title'] ?? service['name'] ?? '',
            priceRs: priceRs,
            rating: (service['rating'] ?? 0.0).toDouble(),
            reviewsCount: service['reviewsCount'] ?? service['reviews'] ?? 0,
            categoryTag: categoryTag,
            providerId: service['providerId'] ?? service['provider']?['_id'],
            providerName: service['provider']?['name'] ?? 
                         service['providerName'],
            providerAvatarUrl: service['provider']?['avatar'] ?? 
                              service['providerAvatarUrl'],
          );
        }).toList();
      } else if (data is Map && data.containsKey('services')) {
        final servicesList = data['services'] as List;
        services = servicesList.map((service) {
          final categoryTag = service['category']?['name'] ?? 
                             service['categoryName'] ?? 
                             service['category'] ?? '';
          final rawPrice = service['price'] ?? service['priceRs'] ?? 0.0;
          final priceRs = PricingHelper.getPriceWithFallback(rawPrice, categoryTag);
          
          return ServiceItemModel(
            id: service['_id'] ?? service['id'] ?? '',
            title: service['title'] ?? service['name'] ?? '',
            priceRs: priceRs,
            rating: (service['rating'] ?? 0.0).toDouble(),
            reviewsCount: service['reviewsCount'] ?? service['reviews'] ?? 0,
            categoryTag: categoryTag,
            providerId: service['providerId'] ?? service['provider']?['_id'],
            providerName: service['provider']?['name'] ?? 
                         service['providerName'],
            providerAvatarUrl: service['provider']?['avatar'] ?? 
                              service['providerAvatarUrl'],
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

  @override
  Future<ServiceItemModel> getServiceById(String id) async {
    try {
      final response = await _dio.get('/api/services/$id');
      final data = response.data;
      
      final service = data is Map && data.containsKey('service') 
          ? data['service'] 
          : data;
      
      final categoryTag = service['category']?['name'] ?? 
                         service['categoryName'] ?? 
                         service['category'] ?? '';
      final rawPrice = service['price'] ?? service['priceRs'] ?? 0.0;
      final priceRs = PricingHelper.getPriceWithFallback(rawPrice, categoryTag);
      
      return ServiceItemModel(
        id: service['_id'] ?? service['id'] ?? id,
        title: service['title'] ?? service['name'] ?? '',
        priceRs: priceRs,
        rating: (service['rating'] ?? 0.0).toDouble(),
        reviewsCount: service['reviewsCount'] ?? service['reviews'] ?? 0,
        categoryTag: categoryTag,
        providerId: service['providerId'] ?? service['provider']?['_id'],
        providerName: service['provider']?['name'] ?? 
                     service['providerName'],
        providerAvatarUrl: service['provider']?['avatar'] ?? 
                          service['providerAvatarUrl'],
      );
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to fetch service';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to fetch service: ${e.toString()}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAvailableProviders({
    required String serviceId,
    required String date,
    required String area,
  }) async {
    try {
      final response = await _dio.get(
        '/api/services/$serviceId/providers',
        queryParameters: {
          'date': date,
          'area': area,
        },
      );
      
      final data = response.data;
      
      if (data is Map && data.containsKey('providers')) {
        return List<Map<String, dynamic>>.from(data['providers']);
      }
      
      return [];
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to fetch providers';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to fetch providers: ${e.toString()}');
    }
  }
}
