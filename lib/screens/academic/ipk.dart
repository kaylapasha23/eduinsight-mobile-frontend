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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const BackHeaderBar(title: 'IPK'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),
                  const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Text(
                      'Grafik',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildChart(),
                  const SizedBox(height: 22),
                  TitledCard(
                    title: 'Detail IPK',
                    color: kYellow,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 6,
                      ),
                      child: Column(children: _buildRows()),
                    ),
                  ),
                  const SizedBox(height: 24),
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
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBlue,
        borderRadius: BorderRadius.circular(18),
      ),
      child: LineChart(
        LineChartData(
          minY: -0.1,
          maxY: 1.1,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: titikGrafik,
              isCurved: false,
              color: Colors.black,
              barWidth: 1.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 2.5,
                    color: Colors.black,
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

  List<Widget> _buildRows() {
    List<Widget> rows = [];

    for (int i = 0; i < dataIpk.length; i++) {
      SemesterIpk item = dataIpk[i];

      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.semester,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
              Text(
                item.ipk,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ],
          ),
        ),
      );

      if (i < dataIpk.length - 1) {
        rows.add(const Divider(color: Colors.black, thickness: 0.8, height: 1));
      }
    }

    return rows;
  }
}