import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme_provider.dart';
import '../common_widgets.dart';

const Color _taskYellow = Color(0xFFFFFFBB);

// ---------- Model data ----------
class TaskItem {
  final String title;
  final String subtitle;
  final String time;
  final bool isTask;

  const TaskItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isTask,
  });
}

const List<TaskItem> daftarTugas = [
  TaskItem(
    title: 'Kecerdasan Buatan',
    subtitle: '14.00 - 15.20      Lantai 7, Ruangan 701',
    time: 'Dalam 1 Jam',
    isTask: false,
  ),
  TaskItem(
    title: 'Tugas 1 - Quiziz',
    subtitle: 'Kewirausahaan',
    time: 'Hari ini, 23.59',
    isTask: true,
  ),
  TaskItem(
    title: 'Tugas 1 - Analisa Aplikasi',
    subtitle: 'UI/UX Design',
    time: 'Hari ini, 23.59',
    isTask: true,
  ),
];

// Titik grafik contoh
const List<FlSpot> titikNilai = [
  FlSpot(0, 0.0),
  FlSpot(1, 0.29),
  FlSpot(2, 0.88),
  FlSpot(3, 0.6),
  FlSpot(4, 0.9),
  FlSpot(5, 0.55),
  FlSpot(6, 0.13),
  FlSpot(7, 1.0),
  FlSpot(8, 0.25),
  FlSpot(9, 0.11),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BoxDecoration _cardDecoration(Color color) {
    final Color shadowColor;

    if (color == _taskYellow) {
      shadowColor = const Color(0xFFD6C45A); // Bayangan kuning gelap
    } else {
      shadowColor = const Color(0xFF7896C5); // Bayangan biru gelap
    }

    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.45),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final backgroundColor =
        isDark ? const Color(0xFF23272F) : const Color(0xFFFDFDFD);
    final titleColor = isDark ? Colors.white : Colors.black;
    final blueTitleColor =
        isDark ? const Color(0xFF82B1FF) : const Color(0xFF1E2B52);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          HeaderBar(
            title: 'EduInsight',
            trailing: IconButton(
              onPressed: () {
                themeProvider.toggleTheme();
              },
              icon: Icon(
                isDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                size: 28,
                color: titleColor,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      'Selamat Pagi',
                      style: TextStyle(
                        fontSize: 16,
                        color: titleColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      'Nama Mahasiswa',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : kNavy,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Container IPK dan Kehadiran
                  Row(
                    children: [
                      Expanded(child: _buildIpkCard()),
                      const SizedBox(width: 10),
                      Expanded(child: _buildKehadiranCard()),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Kelas dan tugas terdekat
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                          Text(
                            'Kelas & Tugas Terdekat',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                            ),
                          ),
                        const SizedBox(width: 4),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFFC62828),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Column(
                    children:
                        daftarTugas.map((t) => _buildTaskCard(t)).toList(),
                  ),

                  const SizedBox(height: 10),

                  // Grafik perkembangan nilai
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      'Perkembangan Nilai',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: blueTitleColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildChart(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomBar(currentIndex: 0),
    );
  }

  // Kartu IPK
  Widget _buildIpkCard() {
    return Container(
      height: 95,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: _cardDecoration(kCardBlue),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'IPK Sementara',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 2),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '3,78',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 3),
              Text(
                '/4,00',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 3.78 / 4.0,
              minHeight: 5,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  // Kartu Kehadiran
  Widget _buildKehadiranCard() {
    return Container(
      height: 95,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: _cardDecoration(kCardBlue),
      child: Column(
        children: [
          const Text(
            'Kehadiran',
            style: TextStyle(
              fontSize: 13,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '90%',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              const SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(
                  value: 0.9,
                  strokeWidth: 4,
                  color: Colors.black,
                  backgroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // Kartu kelas dan tugas
  Widget _buildTaskCard(TaskItem t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: _cardDecoration(_taskYellow),
      child: Row(
        children: [
          if (t.isTask)
            const Icon(
              Icons.assignment_outlined,
              size: 26,
              color: Colors.black,
            ),
          if (t.isTask) const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: kCardBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              t.time,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Container grafik
  Widget _buildChart() {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(kCardBlue),
      child: LineChart(
        LineChartData(
          minY: -0.15,
          maxY: 1.15,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: titikNilai,
              isCurved: false,
              color: kNavy,
              barWidth: 1.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 2.5,
                    color: kNavy,
                    strokeWidth: 0,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}