import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/academic/academic_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'EduInsight',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.currentTheme.copyWith(
            textTheme: GoogleFonts.interTextTheme(
              themeProvider.currentTheme.textTheme,
            ),
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/academic': (context) => const AcademicScreen(),
            '/profile':(context) => const ProfileScreen(), 
          },
        );
      },
    );
  }
}
