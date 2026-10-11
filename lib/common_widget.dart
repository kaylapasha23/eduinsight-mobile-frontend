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
  final String title;
  const HeaderBar({
    super.key,
    this.showLogout = false,
    this.title = 'EduInsight',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2547), Color(0xFF253672)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2B52).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 18),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              const Text(
                'Tagline Aplikasi',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (showLogout)
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false),
                icon: const Icon(Icons.logout, size: 24, color: kLogout),
              ),
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
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool aiActive = currentIndex == 2;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2547), Color(0xFF253672)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2B52).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 10, bottom: 26),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            iconOutlined: Icons.home_outlined,
            isActive: currentIndex == 0,
            onTap: () => _goTo(context, 0, const HomeScreen()),
          ),
          _NavItem(
            icon: Icons.school_rounded,
            iconOutlined: Icons.school_outlined,
            isActive: currentIndex == 1,
            onTap: () => _goTo(context, 1, const AcademicScreen()),
          ),
          GestureDetector(
            onTap: () => _goTo(context, 2, const AiEvalutionScreen()),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: aiActive ? 18 : 14,
                vertical: aiActive ? 10 : 8,
              ),
              decoration: BoxDecoration(
                color: aiActive
                    ? kActive.withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Text(
                    'Ai',
                    style: TextStyle(
                      color: aiActive ? kActive : Colors.white70,
                      fontSize: aiActive ? 30 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: -8,
                    child: Icon(
                      Icons.auto_awesome,
                      size: aiActive ? 14 : 10,
                      color: aiActive ? kActive : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _NavItem(
            icon: Icons.person_rounded,
            iconOutlined: Icons.person_outline,
            isActive: currentIndex == 3,
            onTap: () => _goTo(context, 3, const ProfileScreen()),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData iconOutlined;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.iconOutlined,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? kActive.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          isActive ? icon : iconOutlined,
          size: isActive ? 32 : 26,
          color: isActive ? kActive : Colors.white70,
        ),
      ),
    );
  }
}