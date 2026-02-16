import 'package:dio/dio.dart';
import '../models/contact_model.dart';

abstract class ContactRemoteDataSource {
  Future<ContactModel> createContact({
    required String subject,
    required String message,
    required String category,
    int? rating,
  });
  Future<List<ContactModel>> getMyContacts();
  Future<List<ContactModel>> getTestimonials({int? limit});
}

class ContactRemoteDataSourceImpl implements ContactRemoteDataSource {
  final Dio _dio;

  ContactRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<ContactModel> createContact({
    required String subject,
    required String message,
    required String category,
    int? rating,
  }) async {
    try {
      final body = <String, dynamic>{
        'subject': subject,
        'message': message,
        'category': category,
      };
      if (rating != null) {
        body['rating'] = rating;
      }

      final response = await _dio.post('/api/v1/contact', data: body);
      final contactData = response.data['contact'] ?? response.data;
      return ContactModel.fromJson(contactData);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to submit contact';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to submit contact: ${e.toString()}');
    }
  }

  @override
  Future<List<ContactModel>> getMyContacts() async {
    try {
      final response = await _dio.get('/api/v1/contact/me');
      final List<dynamic> contactsJson = response.data['contacts'] ?? [];
      return contactsJson
          .map((json) => ContactModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to fetch contacts';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to fetch contacts: ${e.toString()}');
    }
  }

  @override
  Future<List<ContactModel>> getTestimonials({int? limit}) async {
    try {
      final response = await _dio.get(
        '/api/v1/contact/testimonials',
        queryParameters: limit != null ? {'limit': limit} : null,
      );
      final List<dynamic> testimonialsJson = response.data['testimonials'] ?? [];
      return testimonialsJson
          .map((json) => ContactModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to fetch testimonials';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to fetch testimonials: ${e.toString()}');
    }
  }
}
