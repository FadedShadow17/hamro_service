import 'package:dio/dio.dart';
import '../models/booking_model.dart';

abstract class BookingRemoteDataSource {
  Future<BookingModel> createBooking({
    required String serviceId,
    required String date,
    required String timeSlot,
    required String area,
  });

  Future<List<BookingModel>> getMyBookings({String? status});

  Future<BookingModel> cancelBooking(String bookingId);

  Future<List<BookingModel>> getProviderBookings({String? status});

  Future<BookingModel> acceptBooking(String bookingId);

  Future<BookingModel> declineBooking(String bookingId);

  Future<BookingModel> completeBooking(String bookingId);

  Future<BookingModel> updateBookingStatus(String bookingId, String status);

  Future<BookingModel> updateBooking({
    required String bookingId,
    String? date,
    String? timeSlot,
    String? area,
  });
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final Dio _dio;

  BookingRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<BookingModel> createBooking({
    required String serviceId,
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

      final response = await _dio.post('/api/bookings', data: body);
      final data = response.data;

      Map<String, dynamic> bookingData;
      if (data is Map) {
        if (data.containsKey('booking')) {
          bookingData = Map<String, dynamic>.from(data['booking'] as Map);
        } else {
          bookingData = Map<String, dynamic>.from(data);
        }
      } else {
        throw Exception('Invalid response format');
      }

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

      if (data is Map) {
        if (data.containsKey('bookings')) {
          final bookingsList = data['bookings'] as List;
          bookings = bookingsList
              .map((booking) => BookingModel.fromJson(Map<String, dynamic>.from(booking as Map)))
              .toList();
        } else if (data.containsKey('data')) {
          final bookingsList = data['data'] as List;
          bookings = bookingsList
              .map((booking) => BookingModel.fromJson(Map<String, dynamic>.from(booking as Map)))
              .toList();
        }
      } else if (data is List) {
        bookings = data
            .map((booking) => BookingModel.fromJson(Map<String, dynamic>.from(booking as Map)))
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

      Map<String, dynamic> bookingData;
      if (data is Map) {
        if (data.containsKey('booking')) {
          bookingData = Map<String, dynamic>.from(data['booking'] as Map);
        } else {
          bookingData = Map<String, dynamic>.from(data);
        }
      } else {
        throw Exception('Invalid response format');
      }

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

  @override
  Future<List<BookingModel>> getProviderBookings({String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null && status.isNotEmpty && status != 'ALL') {
        queryParams['status'] = status;
      }

      final response = await _dio.get(
        '/api/provider/bookings',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      final data = response.data;
      List<BookingModel> bookings = [];

      if (data is Map) {
        if (data.containsKey('bookings')) {
          final bookingsList = data['bookings'] as List;
          bookings = bookingsList
              .map((booking) => BookingModel.fromJson(Map<String, dynamic>.from(booking as Map)))
              .toList();
        } else if (data.containsKey('data')) {
          final bookingsList = data['data'] as List;
          bookings = bookingsList
              .map((booking) => BookingModel.fromJson(Map<String, dynamic>.from(booking as Map)))
              .toList();
        }
      } else if (data is List) {
        bookings = data
            .map((booking) => BookingModel.fromJson(Map<String, dynamic>.from(booking as Map)))
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
  Future<BookingModel> acceptBooking(String bookingId) async {
    try {
      final response = await _dio.patch('/api/provider/bookings/$bookingId/accept');
      final data = response.data;

      final bookingData = data is Map && data.containsKey('booking')
          ? data['booking']
          : data;

      return BookingModel.fromJson(bookingData);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to accept booking';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to accept booking: ${e.toString()}');
    }
  }

  @override
  Future<BookingModel> declineBooking(String bookingId) async {
    try {
      final response = await _dio.patch('/api/provider/bookings/$bookingId/decline');
      final data = response.data;

      final bookingData = data is Map && data.containsKey('booking')
          ? data['booking']
          : data;

      return BookingModel.fromJson(bookingData);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to decline booking';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to decline booking: ${e.toString()}');
    }
  }

  @override
  Future<BookingModel> completeBooking(String bookingId) async {
    try {
      final response = await _dio.patch('/api/provider/bookings/$bookingId/complete');
      final data = response.data;

      final bookingData = data is Map && data.containsKey('booking')
          ? data['booking']
          : data;

      return BookingModel.fromJson(bookingData);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to complete booking';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to complete booking: ${e.toString()}');
    }
  }

  @override
  Future<BookingModel> updateBooking({
    required String bookingId,
    String? date,
    String? timeSlot,
    String? area,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (date != null) data['date'] = date;
      if (timeSlot != null) data['timeSlot'] = timeSlot;
      if (area != null) data['area'] = area;

      final response = await _dio.patch(
        '/api/bookings/$bookingId',
        data: data,
      );

      final responseData = response.data;
      final bookingData = responseData is Map && responseData.containsKey('booking')
          ? responseData['booking']
          : responseData;

      return BookingModel.fromJson(bookingData);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to update booking';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to update booking: ${e.toString()}');
    }
  }

  @override
  Future<BookingModel> updateBookingStatus(String bookingId, String status) async {
    try {
      final response = await _dio.patch(
        '/api/provider/bookings/$bookingId/status',
        data: {'status': status},
      );
      final data = response.data;

      final bookingData = data is Map && data.containsKey('booking')
          ? data['booking']
          : data;

      return BookingModel.fromJson(bookingData);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to update booking status';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to update booking status: ${e.toString()}');
    }
  }
}
