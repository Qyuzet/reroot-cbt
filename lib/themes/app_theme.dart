import 'package:flutter/material.dart';

class AppTheme {
  static const Color _primaryColorLight = Color(0xFF6A8EAE);
  static const Color _primaryColorDark = Color(0xFF3A6EA5);
  static const Color _accentColorLight = Color(0xFF91C4F2);
  static const Color _accentColorDark = Color(0xFF8FB8DE);
  static const Color _backgroundColorLight = Color(0xFFF9F9F9);
  static const Color _backgroundColorDark = Color(0xFF121212);
  static const Color _textColorLight = Color(0xFF333333);
  static const Color _textColorDark = Color(0xFFE0E0E0);

  // Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: _primaryColorLight,
      secondary: _accentColorLight,
      background: _backgroundColorLight,
      onPrimary: Colors.white,
      onSecondary: _textColorLight,
      onBackground: _textColorLight,
    ),
    scaffoldBackgroundColor: _backgroundColorLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: _primaryColorLight,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColorLight,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryColorLight,
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: _textColorLight,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: _textColorLight,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: _textColorLight,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: _textColorLight,
      ),
      bodyMedium: TextStyle(
        color: _textColorLight,
      ),
    ),
  );

  // Dark theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: _primaryColorDark,
      secondary: _accentColorDark,
      background: _backgroundColorDark,
      onPrimary: Colors.white,
      onSecondary: _textColorDark,
      onBackground: _textColorDark,
    ),
    scaffoldBackgroundColor: _backgroundColorDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: _primaryColorDark,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColorDark,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _accentColorDark,
      ),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF1E1E1E),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: _textColorDark,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: _textColorDark,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: _textColorDark,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: _textColorDark,
      ),
      bodyMedium: TextStyle(
        color: _textColorDark,
      ),
    ),
  );
}
