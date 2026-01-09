import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/theme/theme_service.dart';

enum AppThemeMode {
  light,
  dark,
}

class ThemeNotifier extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() {
    Future.microtask(() => _loadTheme());
    return AppThemeMode.light;
  }

  Future<void> _loadTheme() async {
    final isDark = await ThemeService.isDarkMode();
    state = isDark ? AppThemeMode.dark : AppThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final newMode = state == AppThemeMode.light 
        ? AppThemeMode.dark 
        : AppThemeMode.light;
    state = newMode;
    await ThemeService.setDarkMode(newMode == AppThemeMode.dark);
  }

  bool get isDarkMode => state == AppThemeMode.dark;
}

final themeProvider = NotifierProvider<ThemeNotifier, AppThemeMode>(() {
  return ThemeNotifier();
});

