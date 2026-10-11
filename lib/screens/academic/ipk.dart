import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../common_widgets.dart';
import 'academic_widgets.dart';

class SemesterIpk {
  final String semester;
  final String ipk;

  const SemesterIpk({required this.semester, required this.ipk});
}

const List<SemesterIpk> dataIpk = [
  SemesterIpk(semester: 'Semester 1', ipk: '3.80'),
  SemesterIpk(semester: 'Semester 2', ipk: '4.00'),
  SemesterIpk(semester: 'Semester 3', ipk: '3.90'),
  SemesterIpk(semester: 'Semester 4', ipk: '3.78'),
  SemesterIpk(semester: 'Semester 5', ipk: '-'),
  SemesterIpk(semester: 'Semester 6', ipk: '-'),
  SemesterIpk(semester: 'Semester 7', ipk: '-'),
  SemesterIpk(semester: 'Semester 8', ipk: '-'),
];

const List<FlSpot> titikGrafik = [
  FlSpot(0, 0.0),
  FlSpot(1, 0.3),
  FlSpot(2, 0.88),
  FlSpot(3, 0.6),
  FlSpot(4, 0.9),
  FlSpot(5, 0.56),
  FlSpot(6, 0.13),
  FlSpot(7, 1.0),
  FlSpot(8, 0.26),
  FlSpot(9, 0.12),
];

class IpkScreen extends StatelessWidget {
  const IpkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [
          const BackHeaderBar(title: 'IPK'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text(
                      'Grafik',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A2B4A),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildChart(),
                  const SizedBox(height: 24),
                  _buildDetailCard(),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
          const BottomBar(currentIndex: 1),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Container(
      width: double.infinity,
      height: 170,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFDDE8FF),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B6FE8).withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          minY: -0.05,
          maxY: 1.15,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 0.35,
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
              spots: titikGrafik,
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
                    radius: 4,
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
    );
  }

  Widget _buildDetailCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2B52).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Kartu Detail IPK
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A2547), Color(0xFF253672)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Detail IPK',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2B4A),
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Riwayat Nilai Semester 1 - 8',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5C6B8A),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9DB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFEE87)),
                  ),
                  child: const Text(
                    'IPK: 3,78',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7A6500),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: const Color(0xFF1E2B52).withValues(alpha: 0.08),
            thickness: 1,
            height: 1,
          ),
          // List Semester dengan tile modern
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              children: List.generate(dataIpk.length, (index) {
                final item = dataIpk[index];
                final bool hasScore = item.ipk != '-';
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: hasScore ? const Color(0xFFF7FAFF) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: hasScore
                              ? const Color(0xFF1A2547).withValues(alpha: 0.08)
                              : Colors.grey.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: hasScore ? const Color(0xFF1A2547) : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.semester,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: hasScore ? FontWeight.w600 : FontWeight.normal,
                            color: hasScore ? const Color(0xFF1A2B4A) : const Color(0xFF8EA3BF),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: hasScore
                              ? const Color(0xFF34C759).withValues(alpha: 0.14)
                              : Colors.grey.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.ipk,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: hasScore ? const Color(0xFF248A3D) : const Color(0xFF8EA3BF),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}