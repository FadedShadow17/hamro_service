import 'package:dio/dio.dart';
import '../models/profession_model.dart';

abstract class ProfessionRemoteDataSource {
  Future<List<ProfessionModel>> getAllProfessions();
}

class ProfessionRemoteDataSourceImpl implements ProfessionRemoteDataSource {
  final Dio _dio;

  ProfessionRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<ProfessionModel>> getAllProfessions() async {
    try {
      final response = await _dio.get('/api/professions');
      final data = response.data;
      
      List<ProfessionModel> professions = [];
      
      if (data is Map && data.containsKey('data')) {
        final professionsList = data['data'] as List;
        professions = professionsList
            .map((profession) => ProfessionModel.fromJson(profession))
            .toList();
      } else if (data is List) {
        professions = data
            .map((profession) => ProfessionModel.fromJson(profession))
            .toList();
      }

      return professions;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to fetch professions';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to fetch professions: ${e.toString()}');
    }
  }
}
