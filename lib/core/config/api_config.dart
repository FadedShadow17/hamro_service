import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // IMPORTANT: For physical devices, this is your computer's local IP address
  // Your current IP: 192.168.1.73
  // If your IP changes, update this value
  static const String physicalDeviceIp = "192.168.1.73";
  
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    
    // For web, use localhost
    if (kIsWeb) {
      return "http://localhost:4000";
    }
    
    // Check if running on emulator/simulator or physical device
    // For Android: Check if we're on an emulator
    if (Platform.isAndroid) {
      // Try to detect if it's an emulator (this is a simple check)
      // If physicalDeviceIp is set, use it; otherwise use emulator IP
      if (physicalDeviceIp.isNotEmpty && physicalDeviceIp != "YOUR_LOCAL_IP_HERE") {
        return "http://$physicalDeviceIp:4000";
      }
      // Default to emulator IP
      return "http://10.0.2.2:4000";
    } 
    
    // For iOS
    if (Platform.isIOS) {
      // For iOS simulator, localhost works
      // For physical iOS device, use the local IP
      if (physicalDeviceIp.isNotEmpty && physicalDeviceIp != "YOUR_LOCAL_IP_HERE") {
        return "http://$physicalDeviceIp:4000";
      }
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
        if (physicalDeviceIp.isNotEmpty && physicalDeviceIp != "YOUR_LOCAL_IP_HERE") {
          return "http://$physicalDeviceIp:4000";
        }
        return "http://10.0.2.2:4000";
      }
      if (Platform.isIOS) {
        if (physicalDeviceIp.isNotEmpty && physicalDeviceIp != "YOUR_LOCAL_IP_HERE") {
          return "http://$physicalDeviceIp:4000";
        }
        return "http://localhost:4000";
      }
      return "http://localhost:4000";
    }
  }
}
