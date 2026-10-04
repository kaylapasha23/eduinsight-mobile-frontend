import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/academic/academic.dart';
import 'screens/profile_screen.dart';
import 'screens/ai_evalution_card.dart';

const Color kNavy = Color(0xFF1E2B52);
const Color kCardBlue = Color(0xFFCCDAFC);
const Color kBookBlue = Color(0xFF1F4FE0);
const Color kSun = Color(0xFFF5B08C);
const Color kActive = Color(0xFFFFFBB5);
const Color kLogout = Color(0xFFE5484D);

class HeaderBar extends StatelessWidget {
  final bool showLogout;
  const HeaderBar({super.key, this.showLogout = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: kNavy,
      padding: const EdgeInsets.fromLTRB(20, 44, 20, 14),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                const Icon(Icons.menu_book, size: 52, color: kBookBlue),
                Positioned(
                  top: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: kSun,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('EduInsight',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text('Tagline Aplikasi',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontStyle: FontStyle.italic)),
            ],
          ),
          const Spacer(),
          if (showLogout)
            IconButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false),
              icon: const Icon(Icons.logout, size: 28, color: kLogout),
            ),
        ],
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  final int currentIndex;
  const BottomBar({super.key, required this.currentIndex});

  void _goTo(BuildContext context, int index, Widget page) {
    if (index == currentIndex) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page,),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: kNavy,
      padding: const EdgeInsets.only(top: 10, bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () => _goTo(context, 0, const HomeScreen()),
            icon: Icon(Icons.home_outlined,
                size: currentIndex == 0 ? 42 : 30,
                color: currentIndex == 0 ? kActive : Colors.white),
          ),
          IconButton(
            onPressed: () => _goTo(context, 1, const AcademicScreen()),
            icon: Icon(Icons.school_outlined,
                size: currentIndex == 1 ? 42 : 30,
                color: currentIndex == 1 ? kActive : Colors.white),
          ),
          IconButton(
            onPressed: () => _goTo(context, 2, const AiEvalutionScreen()),
            icon: Text('Ai',
            style: TextStyle(
              fontSize: currentIndex == 2 ? 42 : 30,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: currentIndex == 2 ? kActive : Colors.white,),
            ),
          ),
          IconButton(
            onPressed: () => _goTo(context, 3, const ProfileScreen()),
            icon: Icon(Icons.person_outline,
                size: currentIndex == 3 ? 42 : 30,
                color: currentIndex == 3 ? kActive : Colors.white),
          ),
        ],
      ),
    );
  }
}