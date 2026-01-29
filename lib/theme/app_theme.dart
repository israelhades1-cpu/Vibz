import 'package:flutter/material.dart';

class AppTheme {
  // Colors from design
  static const Color background = Color(0xFF1F1F1F);
  static const Color cardBackground = Color(0xFF2A2A2A);
  static const Color accentCyan = Color(0xFF00D9FF);
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color tabBackground = Color(0xFF2A2A2A);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    primaryColor: accentCyan,
    colorScheme: const ColorScheme.dark(
      primary: accentCyan,
      secondary: accentOrange,
      surface: cardBackground,
      background: background,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        color: textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      labelSmall: TextStyle(
        color: textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      centerTitle: true,
    ),
    iconTheme: const IconThemeData(
      color: textPrimary,
    ),
  );
}