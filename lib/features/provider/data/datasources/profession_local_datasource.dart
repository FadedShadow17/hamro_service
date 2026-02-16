import 'package:hive/hive.dart';
import '../../../../core/constants/hive_table_constant.dart';
import '../../../../core/error/exceptions.dart';
import '../models/profession_hive_model.dart';
import '../models/profession_model.dart';

abstract class ProfessionLocalDataSource {
  Future<List<ProfessionModel>> getAllProfessions();
  Future<void> saveProfessions(List<ProfessionModel> professions);
  Future<void> clearProfessions();
}

class ProfessionLocalDataSourceImpl implements ProfessionLocalDataSource {
  Box<ProfessionHiveModel> _getProfessionsBox() {
    try {
      if (!Hive.isBoxOpen(HiveTableConstant.professionsBox)) {
        throw Exception('Professions box not opened. Call HiveService.init() first.');
      }
      final box = Hive.box<ProfessionHiveModel>(HiveTableConstant.professionsBox);
      return box;
    } catch (e) {
      throw CacheException('Professions box not initialized: ${e.toString()}');
    }
  }

  @override
  Future<List<ProfessionModel>> getAllProfessions() async {
    try {
      final box = _getProfessionsBox();
      final professionKeys = box.keys.toList();
      final professions = professionKeys
          .map((key) => ProfessionModel.fromHiveModel(box.get(key)!))
          .toList();
      return professions;
    } catch (e) {
      throw CacheException('Failed to get professions from local storage: ${e.toString()}');
    }
  }

  @override
  Future<void> saveProfessions(List<ProfessionModel> professions) async {
    try {
      final box = _getProfessionsBox();
      await box.clear();
      
      for (final profession in professions) {
        await box.put(profession.id, profession.toHiveModel());
      }
    } catch (e) {
      throw CacheException('Failed to save professions to local storage: ${e.toString()}');
    }
  }

  @override
  Future<void> clearProfessions() async {
    try {
      final box = _getProfessionsBox();
      await box.clear();
    } catch (e) {
      throw CacheException('Failed to clear professions from local storage: ${e.toString()}');
    }
  }
}
