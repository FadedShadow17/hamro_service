import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hamro_service/screens/splash_screen.dart';
import 'package:hamro_service/app/theme/themes.dart';
import 'package:hamro_service/core/providers/theme_provider.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: getLightTheme(),
      darkTheme: getDarkTheme(),
      themeMode: themeMode == AppThemeMode.dark 
          ? ThemeMode.dark 
          : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}

