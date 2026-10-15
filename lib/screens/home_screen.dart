import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme_provider.dart';
import 'common_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Dark mode colors for Beranda
    final backgroundColor = isDark ? const Color(0xFF23272F) : const Color(0xFFF0F4FF);
    final sectionTitleColor = isDark ? const Color(0xFF82B1FF) : const Color(0xFF1E2B52);
    final nameColor = isDark ? Colors.white : const Color(0xFF0D1B40);
    final greetingColor = isDark ? Colors.white60 : const Color(0xFF5C6B8A);

    // Cards are always light colored with black text
    const lightBlueCard = Color(0xFFDDE8FF);
    const yellowCard = Color(0xFFFFF3CD);
    const cardTextColor = Color(0xFF1A2B4A);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          HeaderBar(
            title: 'EduInsight',
            trailing: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            Text(
              'Selamat Pagi',
              style: TextStyle(
                fontSize: 14,
                color: greetingColor,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Nama Mahasiswa',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: nameColor,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
                    decoration: BoxDecoration(
                      color: lightBlueCard,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B6FE8).withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: const [
                        Text(
                          'IPK Sementara',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF3A5A9B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '3,78',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: cardTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
                    decoration: BoxDecoration(
                      color: lightBlueCard,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B6FE8).withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: const [
                        Text(
                          'Kehadiran',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF3A5A9B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '90%',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: cardTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Text(
                  'Kelas & Tugas Terdekat',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: sectionTitleColor,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF4757),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildTaskCard('Kecerdasan Buatan', '14.00 - 15.20 Lantai 7, Ruangan 701', 'Dalam 1 Jam', yellowCard, cardTextColor),
            const SizedBox(height: 10),
            _buildTaskCard('Tugas 1 - Quiziz\nKewirausahaan', '', 'Hari ini, 23.59', yellowCard, cardTextColor),
            const SizedBox(height: 10),
            _buildTaskCard('Tugas 1 - Analisa Aplikasi\nUI/UX Design', '', 'Hari ini, 23.59', yellowCard, cardTextColor),
            const SizedBox(height: 30),
            Text(
              'Perkembangan Nilai',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: sectionTitleColor,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              height: 160,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: lightBlueCard,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B6FE8).withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: LineChart(
                LineChartData(
                  minY: 0.5,
                  maxY: 3.2,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 0.8,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: const Color(0xFF1E2B52).withValues(alpha: 0.08),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 1.2),
                        FlSpot(1, 1.6),
                        FlSpot(2, 2.4),
                        FlSpot(3, 2.1),
                        FlSpot(4, 2.7),
                        FlSpot(5, 2.3),
                        FlSpot(6, 1.8),
                        FlSpot(7, 2.8),
                        FlSpot(8, 2.2),
                        FlSpot(9, 2.5),
                      ],
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: const Color(0xFF1E2B52),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF1E2B52).withValues(alpha: 0.25),
                            const Color(0xFF1E2B52).withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 3.5,
                            color: Colors.white,
                            strokeColor: const Color(0xFF1E2B52),
                            strokeWidth: 2.5,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    ),
  ],
),
bottomNavigationBar: const BottomBar(currentIndex: 0),
);
  }

  Widget _buildTaskCard(String title, String subtitle, String time, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4A300).withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
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
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.7)),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
