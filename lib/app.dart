import 'package:flutter/material.dart';
import 'package:hamro_service/screens/splash_screen.dart';
import 'package:hamro_service/themes/themes.dart';



class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: getApplicationTheme(),
      home: const SplashScreen(),
    );
  }
}

