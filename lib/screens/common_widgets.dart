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
            child: Divider(
              color: isDark ? Colors.white12 : textColor,
              thickness: 1.2,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Bottom bar melayang (Kontras Tinggi untuk Light & Dark Mode) ----------
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Warna navbar di dark mode dibuat sangat kontras: Deep Slate dengan border biru menyala
    final Color barBg = isDark ? const Color(0xFF131720) : kNavy;
    final Color barBorder = isDark ? const Color(0xFF3B82F6).withValues(alpha: 0.35) : Colors.transparent;
    final Color shadowColor = isDark
        ? const Color(0xFF1E3A8A).withValues(alpha: 0.35)
        : kNavy.withValues(alpha: 0.45);

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(22, 8, 22, 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: barBg,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: barBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 20,
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
              isDark: isDark,
              onTap: () => _goTo(context, 0, const HomeScreen()),
            ),
            _NavItem(
              icon: Icons.school_outlined,
              label: 'Akademik',
              isActive: currentIndex == 1,
              isDark: isDark,
              onTap: () => _goTo(context, 1, const AcademicScreen()),
            ),
            _AiNavItem(
              isActive: currentIndex == 2,
              isDark: isDark,
              onTap: () => _goTo(context, 2, const AiEvalutionScreen()),
            ),
            _NavItem(
              icon: Icons.person_outline,
              label: 'Profil',
              isActive: currentIndex == 3,
              isDark: isDark,
              onTap: () => _goTo(context, 3, const ProfileScreen()),
            ),
          ],
        ),
      ),
    );
  }
}

// Item aktif: ikon + label di dalam pil terang bergradasi/kontras
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Pill aktif: di dark mode memakai gradient biru kontras & teks putih/kuning terang
    final Color pillColor = isDark
        ? (isActive ? const Color(0xFF2563EB) : Colors.transparent)
        : (isActive ? kNavPill : Colors.transparent);
    final Color itemColor = isActive
        ? (isDark ? Colors.white : kActive)
        : (isDark ? const Color(0xFF94A3B8) : Colors.white70);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: isActive ? 16 : 10, vertical: 10),
        decoration: BoxDecoration(
          color: pillColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: (isActive && isDark)
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26, color: itemColor),
            if (isActive) const SizedBox(width: 8),
            if (isActive)
              Text(
                label,
                style: TextStyle(
                  color: itemColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AiNavItem extends StatelessWidget {
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _AiNavItem({
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color pillColor = isDark
        ? (isActive ? const Color(0xFF2563EB) : Colors.transparent)
        : (isActive ? kNavPill : Colors.transparent);
    final Color itemColor = isActive
        ? (isDark ? Colors.white : kActive)
        : (isDark ? const Color(0xFF94A3B8) : Colors.white70);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 14 : 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: pillColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: (isActive && isDark)
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 24,
              color: itemColor,
            ),
            if (isActive) ...[
              const SizedBox(width: 7),
              Text(
                'AI Evaluation',
                style: TextStyle(
                  color: itemColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
