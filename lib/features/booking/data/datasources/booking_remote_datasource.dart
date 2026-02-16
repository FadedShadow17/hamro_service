import 'package:dio/dio.dart';
import '../models/booking_model.dart';

abstract class BookingRemoteDataSource {
  Future<BookingModel> createBooking({
    required String serviceId,
    String? providerId,
    required String date,
    required String timeSlot,
    required String area,
  });

  Future<List<BookingModel>> getMyBookings({String? status});

  Future<BookingModel> cancelBooking(String bookingId);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final Dio _dio;

  BookingRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<BookingModel> createBooking({
    required String serviceId,
    String? providerId,
    required String date,
    required String timeSlot,
    required String area,
  }) async {
    try {
      final body = <String, dynamic>{
        'serviceId': serviceId,
        'date': date,
        'timeSlot': timeSlot,
        'area': area,
      };

      if (providerId != null && providerId.isNotEmpty) {
        body['providerId'] = providerId;
      }

      final response = await _dio.post('/api/bookings', data: body);
      final data = response.data;

      final bookingData = data is Map && data.containsKey('booking')
          ? data['booking']
          : data;

      return BookingModel.fromJson(bookingData);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to create booking';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to create booking: ${e.toString()}');
    }
  }

  @override
  Future<List<BookingModel>> getMyBookings({String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _dio.get(
        '/api/bookings/my',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      final data = response.data;
      List<BookingModel> bookings = [];

      if (data is Map && data.containsKey('bookings')) {
        final bookingsList = data['bookings'] as List;
        bookings = bookingsList
            .map((booking) => BookingModel.fromJson(booking))
            .toList();
      }

      return bookings;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to fetch bookings';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to fetch bookings: ${e.toString()}');
    }
  }

  @override
  Future<BookingModel> cancelBooking(String bookingId) async {
    try {
      final response = await _dio.patch('/api/bookings/$bookingId/cancel');
      final data = response.data;

      final bookingData = data is Map && data.containsKey('booking')
          ? data['booking']
          : data;

      return BookingModel.fromJson(bookingData);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to cancel booking';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to cancel booking: ${e.toString()}');
    }
  }
}
