import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/theme/theme_service.dart';

/// Theme mode state
enum AppThemeMode {
  light,
  dark,
}

/// Theme state notifier
class ThemeNotifier extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() {
    // Load theme asynchronously
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

/// Theme provider
final themeProvider = NotifierProvider<ThemeNotifier, AppThemeMode>(() {
  return ThemeNotifier();
});

