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
      print('[ProfessionRemoteDataSource] Fetching professions from /api/professions');
      final response = await _dio.get('/api/professions');
      final data = response.data;
      
      print('[ProfessionRemoteDataSource] Response status: ${response.statusCode}');
      print('[ProfessionRemoteDataSource] Response data type: ${data.runtimeType}');
      print('[ProfessionRemoteDataSource] Response data: $data');
      
      List<ProfessionModel> professions = [];
      
      if (data is Map) {
        if (data.containsKey('data')) {
          final professionsList = data['data'];
          print('[ProfessionRemoteDataSource] Found data key, type: ${professionsList.runtimeType}');
          if (professionsList is List) {
            professions = professionsList
                .map((profession) {
                  try {
                    return ProfessionModel.fromJson(profession);
                  } catch (e) {
                    print('[ProfessionRemoteDataSource] Error parsing profession: $e');
                    print('[ProfessionRemoteDataSource] Profession data: $profession');
                    rethrow;
                  }
                })
                .toList();
          } else {
            print('[ProfessionRemoteDataSource] Warning: data key exists but is not a List');
          }
        } else if (data.containsKey('professions') && data['professions'] is List) {
          final professionsList = data['professions'] as List;
          print('[ProfessionRemoteDataSource] Found professions key');
          professions = professionsList
              .map((profession) => ProfessionModel.fromJson(profession))
              .toList();
        } else {
          print('[ProfessionRemoteDataSource] Warning: Response is Map but no data/professions key found');
          print('[ProfessionRemoteDataSource] Available keys: ${data.keys.toList()}');
        }
      } else if (data is List) {
        print('[ProfessionRemoteDataSource] Response is directly a List');
        professions = data
            .map((profession) => ProfessionModel.fromJson(profession))
            .toList();
      } else {
        print('[ProfessionRemoteDataSource] Warning: Unexpected response type: ${data.runtimeType}');
      }

      print('[ProfessionRemoteDataSource] Successfully parsed ${professions.length} professions');
      return professions;
    } on DioException catch (e) {
      print('[ProfessionRemoteDataSource] DioException: ${e.message}');
      print('[ProfessionRemoteDataSource] Response: ${e.response?.data}');
      print('[ProfessionRemoteDataSource] Status code: ${e.response?.statusCode}');
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to fetch professions';
      throw Exception('Failed to fetch professions: $message');
    } catch (e, stackTrace) {
      print('[ProfessionRemoteDataSource] Unexpected error: $e');
      print('[ProfessionRemoteDataSource] Stack trace: $stackTrace');
      throw Exception('Failed to fetch professions: ${e.toString()}');
    }
  }
}
