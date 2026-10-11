import 'package:flutter/material.dart';
import './../common_widgets.dart';
import 'ipk.dart';
import 'kehadiran.dart';
import 'nilai.dart';
import '../kelas/kelas_screen.dart';

class MenuItem {
  final String title;
  final Widget? page;

  const MenuItem({required this.title, this.page});
}

const List<MenuItem> menuItems = [
  MenuItem(title: 'IPK', page: IpkScreen()),
  MenuItem(title: 'Kehadiran', page: KehadiranScreen()),
  MenuItem(title: 'Nilai', page: NilaiScreen()),
  MenuItem(title: 'Kelas', page: KelasScreen()),
];

class AcademicScreen extends StatelessWidget {
  const AcademicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          const HeaderBar(),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: menuItems
                      .map(
                        (item) => MenuCard(
                          title: item.title,
                          onTap: () {
                            final page = item.page;
                            if (page != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => page),
                              );
                            }
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
          const BottomBar(currentIndex: 1),
        ],
      ),
    );
  }
}

class MenuCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const MenuCard({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 64,
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFDDE8FF),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B6FE8).withValues(alpha: 0.14),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A2B4A),
                letterSpacing: 0.1,
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF1A2B4A).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Color(0xFF1A2B4A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}