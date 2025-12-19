import 'app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // needed for SystemChrome

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    // DeviceOrientation.portraitDown, // optional if you want to allow upside-down
  ]).then((_) {
    runApp(const App());
  });
}
