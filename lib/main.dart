import 'package:hamro_service/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,

  ]).then((_) {
    runApp(const App());
  });
}
