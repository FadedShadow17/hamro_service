import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary colors
  static const Color primary = Color(0xFF0A2640); // Dark blue
  static const Color primaryBlue = Color(0xFF0A2640);
  
  // Accent colors
  static const Color accentGreen = Color(0xFF69E6A6);
  static const Color accentBlue = Color(0xFF4A9EFF);
  static const Color accentYellow = Color(0xFFFFD700); // For warnings/pending
  static const Color accentRed = Color(0xFFEF4444); // For errors/rejected
  static const Color accentOrange = Color(0xFFFF9800);
  
  // Background colors
  static const Color backgroundDark = Color(0xFF0A2640);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color cardDark = Color(0xFF1C3D5B); // Lighter dark for cards
  static const Color cardWhite = Colors.white;
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFF9E9E9E);
  static const Color textWhite = Colors.white;
  static const Color textWhite70 = Color(0xB3FFFFFF); // white with 70% opacity
  static const Color textWhite50 = Color(0x80FFFFFF); // white with 50% opacity
  
  // Status colors
  static const Color badgeBlue = Color(0xFF4A9EFF);
  static const Color statusPending = Color(0xFFFFD700);
  static const Color statusConfirmed = Color(0xFF69E6A6);
  static const Color statusCompleted = Color(0xFF69E6A6);
  static const Color statusRejected = Color(0xFFEF4444);
  static const Color statusCancelled = Color(0xFF9E9E9E);
  
  // Gradient colors
  static const Color gradientBlueStart = Color(0xFF0A2640);
  static const Color gradientBlueEnd = Color(0xFF1C3D5B);
}
