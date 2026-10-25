import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../common_widgets.dart';
import '../academic/kelas/detail_tugas_screen.dart';

// ---------- Model data ----------
class ClassScheduleItem {
  final String title;
  final String time;
  final String room;
  final String countdown;
  final String lecturer;

  const ClassScheduleItem({
    required this.title,
    required this.time,
    required this.room,
    required this.countdown,
    this.lecturer = 'Dosen Pengampu',
  });
}

class UpcomingTaskItem {
  final String title;
  final String course;
  final String deadline;
  final String tag;
  final String taskKey; // "className|taskTitle" untuk navigasi ke detail

  const UpcomingTaskItem({
    required this.title,
    required this.course,
    required this.deadline,
    this.tag = 'Segera',
    this.taskKey = '',
  });
}

const List<ClassScheduleItem> daftarKelasTerdekat = [
  ClassScheduleItem(
    title: 'Kecerdasan Buatan',
    time: '14.00 - 15.20 WIB',
    room: 'Lantai 7, Ruangan 701',
    countdown: 'Dalam 1 Jam',
    lecturer: 'Dr. Ahmad Sahroni, M.Kom.',
  ),
  ClassScheduleItem(
    title: 'Pemrograman Web',
    time: '08.00 - 10.00 WIB (Besok)',
    room: 'Lantai 5, Ruang 502',
    countdown: 'Besok Pagi',
    lecturer: 'Ir. Tri Astuti, M.T.',
  ),
];

const List<UpcomingTaskItem> daftarTugasMendatang = [
  UpcomingTaskItem(
    title: 'Tugas 1 - Quiziz',
    course: 'Kewirausahaan',
    deadline: 'Hari ini, 23.59',
    tag: 'Tenggat Dekat',
    taskKey: 'Kewirausahaan|Tugas 1 - Quiziz',
  ),
  UpcomingTaskItem(
    title: 'Tugas 1 - Analisa Aplikasi',
    course: 'UI/UX Design',
    deadline: 'Hari ini, 23.59',
    tag: 'Tenggat Dekat',
    taskKey: 'UI/UX Design|Tugas 1 - Analisa Aplikasi',
  ),
  UpcomingTaskItem(
    title: 'Pertemuan Pertama',
    course: 'Internet of Things (IoT)',
    deadline: 'Rabu, 23.59',
    tag: '2 Hari Lagi',
    taskKey: 'Internet of Things (IoT)|Pertemuan Pertama',
  ),
];

// Titik grafik IPS per semester (Semester 1 = 3.80, Semester 2 = 4.00, Semester 3 = 3.90, Semester 4 = 3.78)
const List<FlSpot> titikNilaiSemester = [
  FlSpot(1, 3.80),
  FlSpot(2, 4.00),
  FlSpot(3, 3.90),
  FlSpot(4, 3.78),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi 🌤️';
    if (hour < 15) return 'Selamat Siang ☀️';
    if (hour < 18) return 'Selamat Sore 🌆';
    return 'Selamat Malam 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final backgroundColor =
        isDark ? const Color(0xFF1E222A) : const Color(0xFFF7F9FC);
    final titleColor = isDark ? Colors.white : const Color(0xFF1A2238);
    final subtitleColor = isDark ? const Color(0xFF9AA4B8) : const Color(0xFF6B7280);
    final cardBg = isDark ? const Color(0xFF282D37) : Colors.white;

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
                size: 26,
                color: titleColor,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting & Student Name Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: subtitleColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            authProvider.userName,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF323B4C) : const Color(0xFFE8EEFB),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Semester 4',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Container IPK dan Kehadiran Modern Metric Cards
                  Row(
                    children: [
                      Expanded(child: _buildModernIpkCard(isDark, cardBg)),
                      const SizedBox(width: 14),
                      Expanded(child: _buildModernKehadiranCard(isDark, cardBg)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ================= SECTION 1: KELAS TERDEKAT =================
                  _buildSectionHeader(
                    title: 'Jadwal Kelas Hari Ini',
                    badgeText: '${daftarKelasTerdekat.length} Kelas',
                    badgeColor: const Color(0xFF2563EB),
                    titleColor: titleColor,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: daftarKelasTerdekat
                        .map((item) => _buildClassScheduleCard(item, isDark, cardBg))
                        .toList(),
                  ),

                  const SizedBox(height: 22),

                  // ================= SECTION 2: TUGAS MENDATANG =================
                  _buildSectionHeader(
                    title: 'Tugas Mendatang',
                    badgeText: '${daftarTugasMendatang.length} Tugas',
                    badgeColor: const Color(0xFFE11D48),
                    titleColor: titleColor,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: daftarTugasMendatang
                        .map((task) => _buildUpcomingTaskCard(task, isDark, cardBg))
                        .toList(),
                  ),

                  const SizedBox(height: 24),

                  // ================= SECTION 3: GRAFIK PERKEMBANGAN NILAI =================
                  _buildSectionHeader(
                    title: 'Perkembangan Nilai',
                    badgeText: 'Stabil',
                    badgeColor: const Color(0xFF059669),
                    titleColor: titleColor,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildModernChartCard(isDark, cardBg),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomBar(currentIndex: 0),
    );
  }

  // Header Tiap Section dengan Pill Badge
  Widget _buildSectionHeader({
    required String title,
    required String badgeText,
    required Color badgeColor,
    required Color titleColor,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: titleColor,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: badgeColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Modern IPK Card
  Widget _buildModernIpkCard(bool isDark, Color cardBg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'IPK Sementara',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : const Color(0xFF64748B),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  size: 16,
                  color: Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '3,78',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '/ 4.00',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: 3.78 / 4.0,
              minHeight: 6,
              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
            ),
          ),
        ],
      ),
    );
  }

  // Modern Kehadiran Card
  Widget _buildModernKehadiranCard(bool isDark, Color cardBg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kehadiran',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : const Color(0xFF64748B),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 16,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '90%',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  value: 0.90,
                  strokeWidth: 4,
                  strokeCap: StrokeCap.round,
                  backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Target min. 80% terpenuhi',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF059669),
            ),
          ),
        ],
      ),
    );
  }

  // Card Kelas Terdekat (Modern Education Tile)
  Widget _buildClassScheduleCard(ClassScheduleItem item, bool isDark, Color cardBg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.countdown,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.time,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.meeting_room_outlined,
                      size: 13,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.room,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Card Tugas Mendatang
  Widget _buildUpcomingTaskCard(UpcomingTaskItem task, bool isDark, Color cardBg) {
    return GestureDetector(
      onTap: task.taskKey.isNotEmpty
          ? () {
              final parts = task.taskKey.split('|');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailTugasScreen(
                    taskTitle: parts.length > 1 ? parts[1] : task.title,
                    className: parts[0],
                  ),
                ),
              );
            }
          : null,
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.assignment_turned_in_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  task.course,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  task.tag,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                task.deadline,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white54 : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  // Modern Chart Card dengan keterangan tiap semester & tooltip kontras tinggi
  Widget _buildModernChartCard(bool isDark, Color cardBg) {
    // Warna angka dan label yang sangat kontras (terbaca di light maupun dark mode)
    final Color axisTextColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final Color gridLineColor = isDark ? Colors.white12 : const Color(0xFFE2E8F0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 20, 18, 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        height: 190,
        child: LineChart(
          LineChartData(
            minX: 0.6,
            maxX: 4.4,
            minY: 3.0,
            maxY: 4.15,
            lineTouchData: LineTouchData(
              handleBuiltInTouches: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpot) => isDark ? const Color(0xFF1E293B) : Colors.white,
                tooltipBorder: BorderSide(
                  color: isDark ? const Color(0xFF3B82F6) : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
                tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                  return touchedBarSpots.map((barSpot) {
                    final smt = barSpot.x.toInt();
                    return LineTooltipItem(
                      'Smt $smt\n',
                      TextStyle(
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                      children: [
                        TextSpan(
                          text: barSpot.y.toStringAsFixed(2),
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    );
                  }).toList();
                },
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 0.2,
              getDrawingHorizontalLine: (val) {
                return FlLine(
                  color: gridLineColor,
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: 0.2,
                  getTitlesWidget: (val, meta) {
                    if (val < 3.19 || val > 4.01) return const SizedBox.shrink();
                    return Text(
                      val.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: axisTextColor,
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: 1,
                  getTitlesWidget: (val, meta) {
                    final int index = val.toInt();
                    if (val == index.toDouble() && index >= 1 && index <= 4) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Smt $index',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: axisTextColor,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: titikNilaiSemester,
                isCurved: true,
                curveSmoothness: 0.35,
                color: const Color(0xFF2563EB),
                barWidth: 3.5,
                isStrokeCapRound: true,
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2563EB).withValues(alpha: 0.28),
                      const Color(0xFF2563EB).withValues(alpha: 0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 5,
                      color: isDark ? const Color(0xFF2563EB) : Colors.white,
                      strokeColor: isDark ? Colors.white : const Color(0xFF2563EB),
                      strokeWidth: 2.5,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
