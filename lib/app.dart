import 'package:flutter/material.dart';
import 'package:hamro_service/main.dart';
import 'package:hamro_service/screens/login_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HamroServiceApp());
  }
}
