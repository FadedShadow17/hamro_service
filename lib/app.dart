import 'package:flutter/material.dart';
import 'package:hamro_service/screens/icon_screen.dart';
import 'package:hamro_service/screens/onboarding/onboarding_screen.dart';
import 'package:hamro_service/screens/signup_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const IconScreen(),
    );
  }
}
