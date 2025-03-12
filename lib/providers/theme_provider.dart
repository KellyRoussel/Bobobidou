import 'package:flutter/material.dart';

class AppTheme extends ChangeNotifier {
  ThemeData _currentTheme = lightPurpleTheme;

  ThemeData get currentTheme => _currentTheme;

  void setTheme(ThemeData theme) {
    _currentTheme = theme;
    notifyListeners();
  }

  // Light purple theme (your current default)
  static final ThemeData lightPurpleTheme = ThemeData(
    primaryColor: const Color(0xFF6750A4),
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF6750A4),
      secondary: const Color(0xFF6750A4),
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
    ),
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF6750A4),
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6750A4),
        foregroundColor: Colors.white,
      ),
    ),
  );

  // Alternative theme - Green
  static final ThemeData lightGreenTheme = ThemeData(
    primaryColor: Colors.green[700],
    colorScheme: ColorScheme.light(
      primary: Colors.green[700]!,
      secondary: Colors.green[500]!,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
    ),
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.green[700],
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
    ),
  );

  // Alternative theme - Blue
  static final ThemeData lightBlueTheme = ThemeData(
    primaryColor: Colors.blue[700],
    colorScheme: ColorScheme.light(
      primary: Colors.blue[700]!,
      secondary: Colors.blue[500]!,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
    ),
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue[700],
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
    ),
  );


}