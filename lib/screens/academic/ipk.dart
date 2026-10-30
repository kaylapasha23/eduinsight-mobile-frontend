
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../common_widgets.dart';
import 'academic_widgets.dart';

class SemesterIpk {
  final String semester;
  final String label;
  final String ipk;
  final double? value;

  const SemesterIpk({
    required this.semester,
    required this.label,
    required this.ipk,
    this.value,
  });
}

const List<SemesterIpk> dataIpk = [
  SemesterIpk(semester: 'Semester 1', label: 'Smt 1', ipk: '3.80', value: 3.80),
  SemesterIpk(semester: 'Semester 2', label: 'Smt 2', ipk: '4.00', value: 4.00),
  SemesterIpk(semester: 'Semester 3', label: 'Smt 3', ipk: '3.90', value: 3.90),
  SemesterIpk(semester: 'Semester 4', label: 'Smt 4', ipk: '3.78', value: 3.78),
  SemesterIpk(semester: 'Semester 5', label: 'Smt 5', ipk: '-', value: null),
  SemesterIpk(semester: 'Semester 6', label: 'Smt 6', ipk: '-', value: null),
  SemesterIpk(semester: 'Semester 7', label: 'Smt 7', ipk: '-', value: null),
  SemesterIpk(semester: 'Semester 8', label: 'Smt 8', ipk: '-', value: null),
];

const List<FlSpot> titikIpkSemester = [
  FlSpot(1, 3.80),
  FlSpot(2, 4.00),
  FlSpot(3, 3.90),
  FlSpot(4, 3.78),
];

class IpkScreen extends StatelessWidget {
  const IpkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E222A) : const Color(0xFFF7F9FC);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final cardBg = isDark ? const Color(0xFF282D37) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          const BackHeaderBar(title: 'Kartu Hasil Studi (KHS)'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryBanner(isDark, cardBg),
                  const SizedBox(height: 22),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Grafik Perkembangan IPK',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2563EB).withValues(alpha: 0.25)
                              : const Color(0xFF2563EB).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: isDark
                              ? Border.all(
                                  color: const Color(0xFF60A5FA).withValues(alpha: 0.7),
                                  width: 1.2,
                                )
                              : null,
                        ),
                        child: Text(
                          'Smt 1 - 4',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? const Color(0xFF93C5FD)
                                : const Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildModernChartCard(isDark, cardBg),

                  const SizedBox(height: 24),

                  Text(
                    'Riwayat Indeks Prestasi per Semester',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSemesterListCard(isDark, cardBg),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          const BottomBar(currentIndex: 3),
        ],
      ),
    );
  }

  Widget _buildSummaryBanner(bool isDark, Color cardBg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E3A8A), const Color(0xFF172554)]
              : [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Indeks Prestasi Kumulatif',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '3.78',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    '/ 4.00',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text(
                'Predikat: Sangat Memuaskan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFEF08A),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.military_tech_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernChartCard(bool isDark, Color cardBg) {
    final Color axisTextColor =
        isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final Color gridColor =
        isDark ? Colors.white12 : const Color(0xFFE2E8F0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 20, 18, 16),
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
        height: 195,
        child: LineChart(
          LineChartData(
            minX: 0.6,
            maxX: 4.4,
            minY: 3.0,
            maxY: 4.15,
            lineTouchData: LineTouchData(
              handleBuiltInTouches: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpot) =>
                    isDark ? const Color(0xFF1E293B) : Colors.white,
                tooltipBorder: BorderSide(
                  color: isDark
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
                tooltipPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                  return touchedBarSpots.map((barSpot) {
                    final smt = barSpot.x.toInt();

                    return LineTooltipItem(
                      'Semester $smt\n',
                      TextStyle(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                      children: [
                        TextSpan(
                          text: barSpot.y.toStringAsFixed(2),
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
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
                return FlLine(color: gridColor, strokeWidth: 1);
              },
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: 0.2,
                  getTitlesWidget: (val, meta) {
                    if (val < 3.19 || val > 4.01) {
                      return const SizedBox.shrink();
                    }

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
                spots: titikIpkSemester,
                isCurved: true,
                curveSmoothness: 0.35,
                color: const Color(0xFF2563EB),
                barWidth: 3.5,
                isStrokeCapRound: true,
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2563EB).withValues(alpha: 0.3),
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
                      color: isDark
                          ? const Color(0xFF2563EB)
                          : Colors.white,
                      strokeColor:
                          isDark ? Colors.white : const Color(0xFF2563EB),
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

  Widget _buildSemesterListCard(bool isDark, Color cardBg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
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
      child: Column(
        children: List.generate(dataIpk.length, (index) {
          final item = dataIpk[index];
          final bool hasScore = item.ipk != '-';

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? (hasScore
                      ? const Color(0xFF1F2532)
                      : Colors.transparent)
                  : (hasScore
                      ? const Color(0xFFF8FAFC)
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: hasScore
                        ? (isDark
                            ? const Color(0xFF2563EB).withValues(alpha: 0.35)
                            : const Color(0xFF2563EB).withValues(alpha: 0.15))
                        : (isDark
                            ? Colors.white12
                            : const Color(0xFFE2E8F0)),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? Colors.white
                            : (hasScore
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF64748B)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.semester,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              hasScore ? FontWeight.w700 : FontWeight.w500,
                          color: hasScore
                              ? (isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A))
                              : (isDark
                                  ? Colors.white38
                                  : const Color(0xFF94A3B8)),
                        ),
                      ),
                      Text(
                        hasScore ? '22 SKS Selesai' : 'Belum Ditempuh',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.white54
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: hasScore
                        ? const Color(0xFF10B981).withValues(alpha: 0.15)
                        : (isDark
                            ? Colors.white10
                            : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.ipk,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: hasScore
                          ? (isDark
                              ? const Color(0xFF34D399)
                              : const Color(0xFF059669))
                          : (isDark
                              ? Colors.white38
                              : const Color(0xFF94A3B8)),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
