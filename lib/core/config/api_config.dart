import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String physicalDeviceIp = "192.168.1.73";
  
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

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
  
  static String get baseUrlWithFallback {
    try {
      return baseUrl;
    } catch (e) {
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
