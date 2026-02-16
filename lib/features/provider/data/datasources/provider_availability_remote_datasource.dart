import 'package:dio/dio.dart';
import '../models/availability_model.dart';

abstract class ProviderAvailabilityRemoteDataSource {
  Future<AvailabilityModel> getAvailability();
  Future<AvailabilityModel> updateAvailability(List<Map<String, dynamic>> weeklySchedule);
}

class ProviderAvailabilityRemoteDataSourceImpl implements ProviderAvailabilityRemoteDataSource {
  final Dio _dio;

  ProviderAvailabilityRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<AvailabilityModel> getAvailability() async {
    try {
      final response = await _dio.get('/api/provider/availability');
      final data = response.data;
      return AvailabilityModel.fromJson(data);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to fetch availability';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to fetch availability: ${e.toString()}');
    }
  }

  @override
  Future<AvailabilityModel> updateAvailability(List<Map<String, dynamic>> weeklySchedule) async {
    try {
      final response = await _dio.put(
        '/api/provider/availability',
        data: weeklySchedule,
      );
      final data = response.data;
      return AvailabilityModel.fromJson(data['availability'] ?? data);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to update availability';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to update availability: ${e.toString()}');
    }
  }
}
