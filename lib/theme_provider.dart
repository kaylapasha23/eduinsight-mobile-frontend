import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme => _isDarkMode ? _darkTheme : _lightTheme;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF0D47A1), // Deep Blue
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    cardColor: Colors.white,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black54),
      titleMedium: TextStyle(color: Color(0xFF0D47A1)), // Custom for section titles
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0D47A1),
      secondary: Color(0xFFFF9800), // Orange
      surface: Color(0xFFF5F5F5),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E293B),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E293B),
    )
  );

  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF82B1FF), // Lighter blue for dark mode text
    scaffoldBackgroundColor: Colors.black, // For Splash and Login
    cardColor: const Color(0xFF333333), // For Beranda background
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      titleMedium: TextStyle(color: Color(0xFF82B1FF)), // Light blue for section titles
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF82B1FF),
      secondary: Color(0xFFFFB74D), // Light Orange
      surface: Color(0xFF1E1E1E),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2C3E50), // Darker blue for app bar in dark mode
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF2C3E50),
    )
  );
}
