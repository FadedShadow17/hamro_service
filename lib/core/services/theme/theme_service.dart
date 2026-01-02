import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing theme preferences
class ThemeService {
  static const String _themeKey = 'theme_mode';
  
  /// Get saved theme mode
  static Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }
  
  /// Save theme mode
  static Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }
}

