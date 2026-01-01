import 'package:hamro_service/app/app.dart';
import 'package:hamro_service/core/services/hive/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive before runApp
  await HiveService.init();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,

  ]).then((_) {
    runApp(const App());
  });
}
