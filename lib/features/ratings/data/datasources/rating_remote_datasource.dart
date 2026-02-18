import 'package:dio/dio.dart';
import '../models/rating_model.dart';

abstract class RatingRemoteDataSource {
  Future<RatingModel> submitRating({
    required String bookingId,
    required String providerId,
    required int rating,
    String? comment,
  });
  Future<List<RatingModel>> getProviderRatings(String providerId);
  Future<List<RatingModel>> getUserRatings(String userId);
  Future<RatingModel?> getRatingForBooking(String bookingId);
}

class RatingRemoteDataSourceImpl implements RatingRemoteDataSource {
  final Dio _dio;

  RatingRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<RatingModel> submitRating({
    required String bookingId,
    required String providerId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await _dio.post(
        '/api/ratings',
        data: {
          'bookingId': bookingId,
          'providerId': providerId,
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
      );

      final data = response.data;
      Map<String, dynamic> ratingData;
      
      if (data is Map<String, dynamic>) {
        if (data.containsKey('rating')) {
          final rating = data['rating'];
          ratingData = rating is Map<String, dynamic> 
              ? rating 
              : Map<String, dynamic>.from(rating as Map);
        } else {
          ratingData = data;
        }
      } else {
        ratingData = {};
      }

      return RatingModel.fromJson(ratingData);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to submit rating';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to submit rating: ${e.toString()}');
    }
  }

  @override
  Future<List<RatingModel>> getProviderRatings(String providerId) async {
    try {
      final response = await _dio.get('/api/providers/$providerId/ratings');
      final data = response.data;

      List<dynamic> ratingsList = [];
      
      if (data is Map) {
        if (data.containsKey('ratings')) {
          ratingsList = data['ratings'] as List? ?? [];
        } else if (data.containsKey('data')) {
          final dataList = data['data'];
          if (dataList is List) {
            ratingsList = dataList;
          }
        }
      } else if (data is List) {
        ratingsList = data;
      }

      return ratingsList
          .map((rating) => RatingModel.fromJson(
              Map<String, dynamic>.from(rating as Map)))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to fetch ratings';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to fetch ratings: ${e.toString()}');
    }
  }

  @override
  Future<List<RatingModel>> getUserRatings(String userId) async {
    try {
      final response = await _dio.get('/api/users/$userId/ratings');
      final data = response.data;

      List<dynamic> ratingsList = [];
      
      if (data is Map) {
        if (data.containsKey('ratings')) {
          ratingsList = data['ratings'] as List? ?? [];
        } else if (data.containsKey('data')) {
          final dataList = data['data'];
          if (dataList is List) {
            ratingsList = dataList;
          }
        }
      } else if (data is List) {
        ratingsList = data;
      }

      return ratingsList
          .map((rating) => RatingModel.fromJson(
              Map<String, dynamic>.from(rating as Map)))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to fetch ratings';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to fetch ratings: ${e.toString()}');
    }
  }

  @override
  Future<RatingModel?> getRatingForBooking(String bookingId) async {
    try {
      final response = await _dio.get('/api/bookings/$bookingId/rating');
      final data = response.data;

      if (data == null) {
        return null;
      }

      final ratingData = data is Map && data.containsKey('rating')
          ? data['rating']
          : data;

      return RatingModel.fromJson(ratingData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
