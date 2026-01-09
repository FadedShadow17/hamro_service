import 'package:flutter/material.dart';

/// App text style constants
class AppTextStyles {
  AppTextStyles._();

  // Headings
  static TextStyle headingLarge(BuildContext context) => TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      );

  static TextStyle headingMedium(BuildContext context) => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      );

  static TextStyle headingSmall(BuildContext context) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      );

  // Body text
  static TextStyle bodyLarge(BuildContext context) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      );

  static TextStyle bodyMedium(BuildContext context) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      );

  static TextStyle bodySmall(BuildContext context) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: Theme.of(context).textTheme.bodySmall?.color,
      );

  // Special styles
  static TextStyle price(BuildContext context) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      );

  static TextStyle categoryTag(BuildContext context) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      );
}
