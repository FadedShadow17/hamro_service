import 'package:hive_flutter/hive_flutter.dart';
import '../../constants/hive_table_constant.dart';
import '../../../features/auth/data/models/auth_hive_model.dart';
import '../../../features/profile/data/models/profile_hive_model.dart';
import '../../../features/provider/data/models/profession_hive_model.dart';

class HiveService {
  HiveService._();

  static Future<void> init() async {
    await Hive.initFlutter(HiveTableConstant.dbName);

    Hive.registerAdapter(AuthHiveModelAdapter());
    Hive.registerAdapter(ProfileHiveModelAdapter());
    Hive.registerAdapter(ProfessionHiveModelAdapter());

    await Hive.openBox<AuthHiveModel>(HiveTableConstant.usersBox);
    await Hive.openBox<ProfileHiveModel>(HiveTableConstant.profileBox);
    await Hive.openBox<ProfessionHiveModel>(HiveTableConstant.professionsBox);
  }

  static Future<Box> openBox(String boxName) async {
    return await Hive.openBox(boxName);
  }

  static Box? getBox(String boxName) {
    return Hive.box(boxName);
  }

  static Future<void> closeBox(String boxName) async {
    await Hive.box(boxName).close();
  }

  static Future<void> clearBox(String boxName) async {
    await Hive.box(boxName).clear();
  }
}

