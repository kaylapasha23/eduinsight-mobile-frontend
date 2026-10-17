import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'beranda/home_screen.dart';
import 'academic/academic.dart';
import 'profil/profile_screen.dart';
import 'ai_evaluation/ai_evalution_card.dart';

const Color kNavy = Color(0xFF1E2B52);
const Color kCardBlue = Color(0xFFCCDAFC);
const Color kBookBlue = Color(0xFF1F4FE0);
const Color kSun = Color(0xFFF5B08C);
const Color kActive = Color(0xFFFFFBB5);
const Color kLogout = Color(0xFFE5484D);
const Color kNavPill = Color(0xFF4A5A86); // latar item aktif di bottom bar

// ---------- Header TANPA warna (Beranda, Akademik, AI, Profil) ----------
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subColor = isDark ? Colors.white60 : Colors.black54;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 14, 24, 10),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 56,
                  height: 56,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Tagline Aplikasi',
                      style: TextStyle(
                        color: subColor,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (trailing != null)
                  trailing!
                else if (showLogout)
                  IconButton(
                    onPressed: () async {
                      final authProvider =
                          Provider.of<AuthProvider>(context, listen: false);
                      await authProvider.logout();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/login', (route) => false);
                      }
                    },
                    icon: const Icon(Icons.logout, size: 26, color: kLogout),
                  ),
              ],
            ),
          ),
          // garis di bawah header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Divider(color: textColor, thickness: 1.2, height: 1),
          ),
        ],
      ),
    );
  }
}

// ---------- Bottom bar melayang (pil navy) ----------
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
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(22, 8, 22, 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: kNavy,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: kNavy.withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              label: 'Beranda',
              isActive: currentIndex == 0,
              onTap: () => _goTo(context, 0, const HomeScreen()),
            ),
            _NavItem(
              icon: Icons.school_outlined,
              label: 'Akademik',
              isActive: currentIndex == 1,
              onTap: () => _goTo(context, 1, const AcademicScreen()),
            ),
            _AiNavItem(
              isActive: currentIndex == 2,
              onTap: () => _goTo(context, 2, const AiEvalutionScreen()),
            ),
            _NavItem(
              icon: Icons.person_outline,
              label: 'Profil',
              isActive: currentIndex == 3,
              onTap: () => _goTo(context, 3, const ProfileScreen()),
            ),
          ],
        ),
      ),
    );
  }
}

// Item aktif: ikon + label di dalam pil terang. Item tidak aktif: ikon saja.
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
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
        padding: EdgeInsets.symmetric(horizontal: isActive ? 16 : 10, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? kNavPill : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: isActive ? kActive : Colors.white),
            if (isActive) const SizedBox(width: 8),
            if (isActive)
              Text(
                label,
                style: const TextStyle(color: kActive, fontSize: 15),
              ),
          ],
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
    final Color color = isActive ? kActive : Colors.white;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 12 : 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isActive ? kNavPill : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 24,
              color: color,
            ),
            if (isActive) ...[
              const SizedBox(width: 7),
              const Text(
                'AI Evaluation',
                style: TextStyle(
                  color: kActive,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
