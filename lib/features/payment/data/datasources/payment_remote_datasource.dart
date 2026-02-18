import 'package:dio/dio.dart';
import '../models/payment_model.dart';

abstract class PaymentRemoteDataSource {
  Future<List<PaymentModel>> getPayableBookings();
  Future<PaymentModel> payForBooking(String bookingId, String paymentMethod);
  Future<List<PaymentModel>> getPaymentHistory();
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final Dio _dio;

  PaymentRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<PaymentModel>> getPayableBookings() async {
    try {
      final response = await _dio.get('/api/payments/me');
      final List<dynamic> bookingsJson = response.data['bookings'] ?? [];
      return bookingsJson
          .map((json) => PaymentModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to fetch payable bookings';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to fetch payable bookings: ${e.toString()}');
    }
  }

  @override
  Future<PaymentModel> payForBooking(String bookingId, String paymentMethod) async {
    try {
      final response = await _dio.post(
        '/api/payments/$bookingId/pay',
        data: {'paymentMethod': paymentMethod},
      );
      final bookingData = response.data['booking'] ?? response.data;
      return PaymentModel.fromJson(bookingData);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to process payment';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to process payment: ${e.toString()}');
    }
  }

  @override
  Future<List<PaymentModel>> getPaymentHistory() async {
    try {
      final response = await _dio.get('/api/payments/me/history');
      final data = response.data;
      
      List<dynamic> paymentsList = [];
      if (data is Map) {
        if (data.containsKey('payments')) {
          paymentsList = data['payments'] as List? ?? [];
        } else if (data.containsKey('data')) {
          paymentsList = data['data'] as List? ?? [];
        } else if (data.containsKey('history')) {
          paymentsList = data['history'] as List? ?? [];
        }
      } else if (data is List) {
        paymentsList = data;
      }
      
      return paymentsList
          .map((json) => PaymentModel.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to fetch payment history';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to fetch payment history: ${e.toString()}');
    }
  }
}
