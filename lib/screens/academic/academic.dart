import 'package:flutter/material.dart';
import './../common_widgets.dart';
import 'academic_widgets.dart'; // kYellow
import 'ipk.dart';
import 'kehadiran.dart';
import 'nilai.dart';
import 'kelas/kelas_screen.dart';

class MenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget page;

  const MenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.page,
  });
}

const List<MenuItem> hasilStudi = [
  MenuItem(
    title: 'IPK',
    subtitle: '4 Semester',
    icon: Icons.show_chart,
    color: kCardBlue,
    page: IpkScreen(),
  ),
  MenuItem(
    title: 'Nilai',
    subtitle: '6 Mata Kuliah',
    icon: Icons.assignment_outlined,
    color: kYellow,
    page: NilaiScreen(),
  ),
];

const List<MenuItem> perkuliahan = [
  MenuItem(
    title: 'Kehadiran',
    subtitle: '6 dari 6 Pertemuan hadir',
    icon: Icons.calendar_today_outlined,
    color: kCardBlue,
    page: KehadiranScreen(),
  ),
  MenuItem(
    title: 'Kelas',
    subtitle: '2 Tugas Belum Terselesaikan',
    icon: Icons.school_outlined,
    color: kYellow,
    page: KelasScreen(),
  ),
];

class AcademicScreen extends StatelessWidget {
  const AcademicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor =
        isDark ? const Color(0xFF23272F) : const Color(0xFFFDFDFD);

    final sectionColor =
        isDark ? Colors.white70 : const Color(0xFF444444);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          const HeaderBar(),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        'Hasil Studi',
                        style: TextStyle(
                          fontSize: 19,
                          color: sectionColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: hasilStudi
                          .map((item) => _buildCard(context, item))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        'Perkuliahan',
                        style: TextStyle(
                          fontSize: 19,
                          color: sectionColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: perkuliahan
                          .map((item) => _buildCard(context, item))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const BottomBar(currentIndex: 1),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, MenuItem item) {
    return MenuCard(
      title: item.title,
      subtitle: item.subtitle,
      icon: item.icon,
      color: item.color,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => item.page),
        );
      },
    );
  }
}

class MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const MenuCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shadowColor = color == kYellow
        ? const Color(0xFFD6C45A)
        : const Color(0xFF7896C5);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 62,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.45),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 25,
              color: Colors.black,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward,
              size: 18,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}