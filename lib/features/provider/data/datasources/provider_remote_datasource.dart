import 'package:dio/dio.dart';
import '../models/provider_order_model.dart';
import '../models/provider_dashboard_model.dart';
import '../../../booking/data/models/booking_model.dart';

abstract class ProviderRemoteDataSource {
  Future<List<ProviderOrderModel>> getProviderBookings({String? status});
  Future<BookingModel> acceptBooking(String bookingId);
  Future<BookingModel> declineBooking(String bookingId);
  Future<BookingModel> completeBooking(String bookingId);
  Future<BookingModel> cancelBooking(String bookingId);
  Future<BookingModel> updateBookingStatus(String bookingId, String status);
  Future<ProviderDashboardModel> getDashboardSummary();
}

class ProviderRemoteDataSourceImpl implements ProviderRemoteDataSource {
  final Dio _dio;

  ProviderRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<ProviderOrderModel>> getProviderBookings({String? status}) async {
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
      List<ProviderOrderModel> orders = [];

      List<dynamic> bookingsList = [];
      
      if (data is Map) {
        if (data.containsKey('bookings')) {
          bookingsList = data['bookings'] as List? ?? [];
        } else if (data.containsKey('data')) {
          final dataList = data['data'];
          if (dataList is List) {
            bookingsList = dataList;
          } else if (dataList is Map<String, dynamic> && dataList.containsKey('bookings')) {
            bookingsList = dataList['bookings'] as List? ?? [];
          }
        } else if (data.containsKey('results')) {
          bookingsList = data['results'] as List? ?? [];
        }
      } else if (data is List) {
        bookingsList = data;
      }

      orders = bookingsList.map((booking) {
        try {
          final bookingMap = booking is Map<String, dynamic> 
              ? booking 
              : booking as Map<String, dynamic>;
          final bookingModel = BookingModel.fromJson(bookingMap);
          
          final price = bookingModel.service?['price'] ?? 
                       bookingModel.service?['basePrice'] ?? 
                       bookingModel.service?['priceRs'] ?? 
                       0;
          final priceInt = price is int ? price : (price is num ? price.toInt() : 0);
          
          return ProviderOrderModel(
            id: bookingModel.id,
            customerName: bookingModel.user?['name'] ?? 
                         bookingModel.user?['fullName'] ?? 
                         bookingModel.user?['username'] ??
                         'Unknown',
            serviceName: bookingModel.service?['name'] ?? 
                        bookingModel.service?['title'] ?? 
                        bookingModel.service?['serviceName'] ??
                        'Service',
            status: bookingModel.status.toUpperCase().trim(),
            priceRs: priceInt,
            location: bookingModel.area,
            createdAt: bookingModel.createdAt,
            scheduledDate: DateTime.tryParse(bookingModel.date),
            paymentStatus: bookingModel.paymentStatus,
          );
        } catch (e) {
          return null;
        }
      }).whereType<ProviderOrderModel>().toList();

      return orders;
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
  Future<BookingModel> cancelBooking(String bookingId) async {
    try {
      final response = await _dio.patch('/api/provider/bookings/$bookingId/cancel');
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

  @override
  Future<ProviderDashboardModel> getDashboardSummary() async {
    try {
      final response = await _dio.get('/api/provider/dashboard/summary');
      final data = response.data;

      return ProviderDashboardModel.fromJson(data);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to fetch dashboard summary';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to fetch dashboard summary: ${e.toString()}');
    }
  }
}
