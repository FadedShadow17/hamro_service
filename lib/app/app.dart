import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamro_service/screens/splash_screen.dart';
import 'package:hamro_service/app/theme/themes.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: getApplicationTheme(),
      home: const SplashScreen(),
    );
  }
}

