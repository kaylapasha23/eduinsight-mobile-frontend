import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme_provider.dart';
import 'splash_screen.dart'; // for LogoWidget

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Dark mode colors for Beranda
    final backgroundColor = isDark ? const Color(0xFF333333) : const Color(0xFFF5F5F5);
    final sectionTitleColor = isDark ? const Color(0xFF82B1FF) : Colors.black87;
    final nameColor = isDark ? Colors.white : Colors.black;
    final appBarColor = isDark ? const Color(0xFF2C3E50) : const Color(0xFF1E293B);
    final bottomNavColor = isDark ? const Color(0xFF2C3E50) : const Color(0xFF1E293B);
    
    // Cards are always light colored with black text
    const lightBlueCard = Color(0xFFC4D7FF);
    const yellowCard = Color(0xFFFFF9C4);
    const cardTextColor = Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Row(
          children: [
            const SizedBox(
              width: 30,
              height: 30,
              child: FittedBox(child: LogoWidget()),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EduInsight',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'Tagline Aplikasi',
                  style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Pagi',
              style: TextStyle(fontSize: 14, color: sectionTitleColor),
            ),
            const SizedBox(height: 4),
            Text(
              'Nama Mahasiswa',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: nameColor),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: lightBlueCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'IPK Sementara',
                          style: TextStyle(fontSize: 12, color: cardTextColor),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '3,78',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: cardTextColor),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: lightBlueCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Kehadiran',
                          style: TextStyle(fontSize: 12, color: cardTextColor),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '90%',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: cardTextColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Divider(color: isDark ? Colors.grey[600] : Colors.grey[300]),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Kelas & Tugas Terdekat',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: sectionTitleColor),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            _buildTaskCard('Kecerdasan Buatan', '14.00 - 15.20 Lantai 7, Ruangan 701', 'Dalam 1 Jam', yellowCard, cardTextColor),
            const SizedBox(height: 12),
            _buildTaskCard('Tugas 1 - Quiziz\nKewirausahaan', '', 'Hari ini, 23.59', yellowCard, cardTextColor),
            const SizedBox(height: 12),
            _buildTaskCard('Tugas 1 - Analisa Aplikasi\nUI/UX Design', '', 'Hari ini, 23.59', yellowCard, cardTextColor),
            const SizedBox(height: 24),
            Divider(color: isDark ? Colors.grey[600] : Colors.grey[300]),
            const SizedBox(height: 8),
            Text(
              'Perkembangan Nilai',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: sectionTitleColor),
            ),
            const SizedBox(height: 16),
            Container(
              height: 150,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lightBlueCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 1),
                        FlSpot(1, 1.5),
                        FlSpot(2, 2.5),
                        FlSpot(3, 2.0),
                        FlSpot(4, 2.6),
                        FlSpot(5, 2.1),
                        FlSpot(6, 1.5),
                        FlSpot(7, 2.7),
                        FlSpot(8, 1.8),
                        FlSpot(9, 1.6),
                      ],
                      isCurved: false,
                      color: const Color(0xFF1E293B), // Dark line inside light blue chart
                      barWidth: 1.5,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 2,
                            color: const Color(0xFF1E293B),
                            strokeWidth: 0,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/academic');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/ai');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: bottomNavColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.school_outlined), label: 'Academic'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_outlined), label: 'AI'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildTaskCard(String title, String subtitle, String time, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.8)),
                  ),
                ],
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(fontSize: 12, color: textColor),
          ),
        ],
      ),
    );
  }
}
