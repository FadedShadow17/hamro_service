import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for SharedPreferences instance
/// Must be overridden in main.dart before runApp()
final sharedPrefsProvider = FutureProvider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPrefsProvider must be overridden');
});

