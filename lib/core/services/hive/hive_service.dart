import 'package:hive_flutter/hive_flutter.dart';
import '../../constants/hive_table_constant.dart';

/// Service for managing Hive database initialization and box operations
class HiveService {
  HiveService._();

  static Future<void> init() async {
    await Hive.initFlutter(HiveTableConstant.dbName);

    // Register adapters will be added in later commits
    // Example: Hive.registerAdapter(AuthHiveModelAdapter());
  }

  /// Open a Hive box
  static Future<Box> openBox(String boxName) async {
    return await Hive.openBox(boxName);
  }

  /// Get an already opened box
  static Box? getBox(String boxName) {
    return Hive.box(boxName);
  }

  /// Close a box
  static Future<void> closeBox(String boxName) async {
    await Hive.box(boxName).close();
  }

  /// Clear all data from a box
  static Future<void> clearBox(String boxName) async {
    await Hive.box(boxName).clear();
  }
}

