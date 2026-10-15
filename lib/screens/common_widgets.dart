import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'academic/academic.dart';
import 'profile_screen.dart';
import 'ai_evalution_card.dart';

const Color kNavy = Color(0xFF1E2B52);
const Color kCardBlue = Color(0xFFCCDAFC);
const Color kBookBlue = Color(0xFF1F4FE0);
const Color kSun = Color(0xFFF5B08C);
const Color kActive = Color(0xFFFFFBB5);
const Color kLogout = Color(0xFFE5484D);

class HeaderBar extends StatelessWidget {
  final bool showLogout;
  final String title;
  final Widget? trailing;
  const HeaderBar({
    super.key,
    this.showLogout = false,
    this.title = 'EduInsight',
    this.trailing,
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
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                mainAxisSize: MainAxisSize.min,
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
              if (trailing != null)
                trailing!
              else if (showLogout)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () async {
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      await authProvider.logout();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/login', (route) => false);
                      }
                    },
                    icon: const Icon(Icons.logout, size: 24, color: kLogout),
                  ),
                ),
            ],
          ),
        ),
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
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            iconOutlined: Icons.home_outlined,
            iconSize: 28,
            isActive: currentIndex == 0,
            onTap: () => _goTo(context, 0, const HomeScreen()),
          ),
          _NavItem(
            icon: Icons.school_rounded,
            iconOutlined: Icons.school_outlined,
            iconSize: 31, // optical match for wide graduation cap
            isActive: currentIndex == 1,
            onTap: () => _goTo(context, 1, const AcademicScreen()),
          ),
          _AiNavItem(
            isActive: currentIndex == 2,
            onTap: () => _goTo(context, 2, const AiEvalutionScreen()),
          ),
          _NavItem(
            icon: Icons.person_rounded,
            iconOutlined: Icons.person_outline,
            iconSize: 29,
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
  final double iconSize;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.iconOutlined,
    required this.iconSize,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: isActive ? 60 : 48,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? kActive.withValues(alpha: 0.22) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isActive
              ? Border.all(color: kActive.withValues(alpha: 0.45), width: 1.5)
              : null,
        ),
        child: AnimatedScale(
          scale: isActive ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: SizedBox(
            width: 34,
            height: 32,
            child: Center(
              child: Icon(
                isActive ? icon : iconOutlined,
                size: iconSize,
                color: isActive ? kActive : Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AiNavItem extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _AiNavItem({
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: isActive ? 60 : 48,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? kActive.withValues(alpha: 0.22) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isActive
              ? Border.all(color: kActive.withValues(alpha: 0.45), width: 1.5)
              : null,
        ),
        child: AnimatedScale(
          scale: isActive ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: SizedBox(
            width: 34,
            height: 32,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ai',
                    style: TextStyle(
                      color: isActive ? kActive : Colors.white70,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 1),
                  Icon(
                    Icons.auto_awesome,
                    size: 11,
                    color: isActive ? kActive : Colors.white70,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}