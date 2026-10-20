import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final prefs = SharedPreferencesAsync();

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme => _isDarkMode ? _darkTheme : _lightTheme;

  ThemeProvider() {
    _loadTheme(); // baca pilihan terakhir saat aplikasi dibuka
  }

  // BACA: getter bertipe, nilai default jika belum pernah disimpan
  Future<void> _loadTheme() async {
    _isDarkMode = await prefs.getBool('dark_mode') ?? false;
    notifyListeners();
  }

  // SIMPAN: setBool dengan key string
    Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await prefs.setBool('dark_mode', _isDarkMode);
  }

  // ─────────────────────────────────────────
  // PALET WARNA SESUAI FIGMA
  // ─────────────────────────────────────────
  static const Color darkBg = Color(0xFF23272F); // Charcoal gelap elegan dari Figma
  static const Color lightBg = Color(0xFFF0F4FF);
  static const Color darkAuthBg = Color(0xFF121418); // Gelap pekat untuk Splash & Login
  static const Color pastelBlueCard = Color(0xFFCCDAFC); // Kartu biru pastel dari Figma
  static const Color pastelYellowCard = Color(0xFFFFF3B8); // Kartu kuning pastel dari Figma
  static const Color cardTextColor = Color(0xFF101C3D); // Teks kontras dalam kartu

  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF1E2B52),
    scaffoldBackgroundColor: lightBg,
    cardColor: pastelBlueCard,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black54),
      titleMedium: TextStyle(color: Color(0xFF1E2B52)),
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1E2B52),
      secondary: Color(0xFFFFF3B8),
      surface: lightBg,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A2547),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1A2547),
    ),
  );

  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF82B1FF),
    scaffoldBackgroundColor: darkBg,
    cardColor: pastelBlueCard,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      titleMedium: TextStyle(color: Color(0xFF82B1FF)),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF82B1FF),
      secondary: Color(0xFFFFF3B8),
      surface: darkBg,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A2547),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1A2547),
    ),
  );
}