import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo representation
            const LogoWidget(),
            const SizedBox(height: 24),
            Text(
              'EduInsight',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tagline Aplikasi',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Sun
          Positioned(
            top: 20,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFFF9800),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Sun rays
          Positioned(
            top: 5,
            left: 25,
            child: Container(width: 4, height: 10, color: const Color(0xFFFF9800), transform: Matrix4.rotationZ(-0.5)),
          ),
          Positioned(
            top: 0,
            child: Container(width: 4, height: 10, color: const Color(0xFFFF9800)),
          ),
          Positioned(
            top: 5,
            right: 25,
            child: Container(width: 4, height: 10, color: const Color(0xFFFF9800), transform: Matrix4.rotationZ(0.5)),
          ),
          // Book pages
          Positioned(
            bottom: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 35,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D47A1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(2),
                      bottomLeft: Radius.circular(2),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Container(
                  width: 50,
                  height: 35,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D47A1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(2),
                      topRight: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
