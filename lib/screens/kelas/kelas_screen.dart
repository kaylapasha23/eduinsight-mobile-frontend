import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common_widgets.dart';
import 'gabung_kelas_screen.dart';
import 'tugas_list_screen.dart';
import 'detail_tugas_screen.dart';
import 'kelas_provider.dart';

class TaskItem {
  final String title;
  final String subtitle;
  final String status;
  final String className;
  TaskItem(this.title, this.subtitle, this.status, this.className);
}

final List<TaskItem> allSegeraTasks = [
  TaskItem('Instalasi Node.js', 'T6D Web Framework', 'Hari ini, 23.59', 'Web Framework'),
  TaskItem('Tugas 2: Sejarah Komputer', 'T6D IoT', 'Jumat, 11 Nov', 'IoT'),
  TaskItem('Pengenalan JavaScript', 'T6D Pemrograman Dasar', 'Senin, 23.59', 'Pemrograman Dasar'),
];

final List<TaskItem> allSelesaiTasks = [
  TaskItem('CBL 2: Low-Fidelity', 'T6D UI/UX', 'Diserahkan', 'UI/UX'),
  TaskItem('Quizziz Matriks', 'T6D Statistika dan Data', 'Diserahkan', 'Statistika dan Data'),
  TaskItem('AI Klasik dan Modern', 'T6D Kecerdasan Buatan', 'Diserahkan', 'Kecerdasan Buatan'),
  TaskItem('Tipe Data dan Method', 'T6D Pemrograman Web', 'Diserahkan', 'Pemrograman Web'),
  TaskItem('Pertemuan Pertama IoT', 'T6D IoT', 'Diserahkan', 'IoT'),
  TaskItem('Pertemuan Pertama Pemweb', 'T6D Pemrograman Web', 'Diserahkan', 'Pemrograman Web'),
  TaskItem('Pertemuan Pertama Sistem Informasi', 'T6D Sistem Informasi', 'Diserahkan', 'Sistem Informasi'),
];

class KelasScreen extends StatelessWidget {
  const KelasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<KelasProvider>(
      builder: (context, kelas, _) {
        // Segera = initial 3 minus any user completed
        final segeraTasks = allSegeraTasks
            .where((t) => !kelas.isCompleted('${t.className}|${t.title}'))
            .toList();
        // Selesai = initial selesai + user completed segera tasks
        final selesaiCount = kelas.selesaiCount +
            allSegeraTasks
                .where((t) => kelas.isCompleted('${t.className}|${t.title}'))
                .length;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: kNavy,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Kelas',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            actions: [
              TextButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const GabungKelasScreen())),
                child: const Text('Gabung Kelas',
                    style: TextStyle(color: kActive, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ringkasan Tugas',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        decoration: BoxDecoration(
                          color: kActive,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryCard(context, '${segeraTasks.length}', 'Segera', 'segera'),
                            _buildSummaryCard(context, '0', 'Terlambat', 'terlambat'),
                            _buildSummaryCard(context, '$selesaiCount', 'Selesai', 'selesai'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildClassCard(context, 'Keamanan Siber', 'Gibran Rakabuming',
                          'Tidak Ada Tugas Terdekat', '', null),
                      _buildClassCard(context, 'Pemrograman Web', 'Ahmad Sahroni',
                          'Tidak Ada Tugas Terdekat', '', null),
                      _buildClassCard(context, 'Sistem Informasi', 'Bahlil Lahadalia',
                          'Tidak Ada Tugas Terdekat', '', null),
                      _buildClassCard(context, 'IoT', 'Teddy Indra Wijaya',
                          kelas.isCompleted('IoT|Tugas 2: Sejarah Komputer')
                              ? 'Tidak Ada Tugas Terdekat'
                              : 'Tugas 2: Sejarah Komputer',
                          kelas.isCompleted('IoT|Tugas 2: Sejarah Komputer') ? '' : 'Jumat, 11 Nov',
                          kelas.isCompleted('IoT|Tugas 2: Sejarah Komputer')
                              ? null
                              : allSegeraTasks.firstWhere((t) => t.className == 'IoT')),
                      _buildClassCard(context, 'Kecerdasan Buatan', 'Rocky Gerung',
                          'Tidak Ada Tugas Terdekat', '', null),
                      _buildClassCard(context, 'UI/UX', 'Ivan Gunawan',
                          'Tidak Ada Tugas Terdekat', '', null),
                      _buildClassCard(context, 'Web Framework', 'Windah Basudara',
                          kelas.isCompleted('Web Framework|Instalasi Node.js')
                              ? 'Tidak Ada Tugas Terdekat'
                              : 'Instalasi Node.js',
                          kelas.isCompleted('Web Framework|Instalasi Node.js')
                              ? ''
                              : 'Hari ini, 23.59',
                          kelas.isCompleted('Web Framework|Instalasi Node.js')
                              ? null
                              : allSegeraTasks.firstWhere((t) => t.className == 'Web Framework')),
                      _buildClassCard(context, 'Statistika dan Data', 'Nadiem Makarim',
                          'Tidak Ada Tugas Terdekat', '', null),
                      _buildClassCard(context, 'Pemrograman Dasar', 'Deddy Corbuzier',
                          kelas.isCompleted('Pemrograman Dasar|Pengenalan JavaScript')
                              ? 'Tidak Ada Tugas Terdekat'
                              : 'Pengenalan JavaScript',
                          kelas.isCompleted('Pemrograman Dasar|Pengenalan JavaScript')
                              ? ''
                              : 'Senin, 23.59',
                          kelas.isCompleted('Pemrograman Dasar|Pengenalan JavaScript')
                              ? null
                              : allSegeraTasks
                                  .firstWhere((t) => t.className == 'Pemrograman Dasar')),
                    ],
                  ),
                ),
              ),
              const BottomBar(currentIndex: 1),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(BuildContext context, String count, String label, String type) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => TugasListScreen(type: type))),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFFFEFFEE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(count,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, String title, String subtitle,
      String taskInfo, String timeInfo, TaskItem? task) {
    return GestureDetector(
      onTap: task != null
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailTugasScreen(
                    taskTitle: task.title,
                    className: task.className,
                  ),
                ),
              )
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: kCardBlue,
                borderRadius:
                    BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(taskInfo,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle:
                            taskInfo.startsWith('Tidak') ? FontStyle.italic : FontStyle.normal,
                        color: Colors.black87,
                      )),
                  if (timeInfo.isNotEmpty)
                    Text(timeInfo,
                        style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
