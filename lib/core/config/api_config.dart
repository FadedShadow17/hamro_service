import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    
    // For Android emulator, use 10.0.2.2 to access host machine's localhost
    // For iOS simulator, localhost works fine
    // For web, use localhost
    if (kIsWeb) {
      return "http://localhost:4000";
    }
    
    if (Platform.isAndroid) {
      return "http://10.0.2.2:4000";
    } else if (Platform.isIOS) {
      return "http://localhost:4000";
    }
    
    // Default fallback
    return "http://localhost:4000";
  }
  
  static String get baseUrlWithFallback {
    try {
      return baseUrl;
    } catch (e) {
      // Fallback based on platform
      if (kIsWeb) {
        return "http://localhost:4000";
      }
      if (Platform.isAndroid) {
        return "http://10.0.2.2:4000";
      }
      return "http://localhost:4000";
    }
  }
}
