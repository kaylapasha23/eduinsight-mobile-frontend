import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common_widgets.dart';
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
        // Selesai = total completed tasks tracked in provider
        final selesaiCount = kelas.selesaiCount;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor = isDark ? const Color(0xFF23272F) : const Color(0xFFF0F4FF);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A2547), Color(0xFF253672)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x551E2B52),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  'Kelas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (context) => const GabungKelasScreen())),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: kActive.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Gabung Kelas',
                        style: TextStyle(
                          color: kActive,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ringkasan Tugas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1A2B4A),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9DB),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4A300)
                                  .withValues(alpha: 0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryCard(context, '${segeraTasks.length}',
                                'Segera', 'segera'),
                            _buildSummaryCard(
                                context, '0', 'Terlambat', 'terlambat'),
                            _buildSummaryCard(
                                context, '$selesaiCount', 'Selesai', 'selesai'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      _buildClassCard(context, 'Keamanan Siber',
                          'Gibran Rakabuming', 'Tidak Ada Tugas Terdekat', '', null),
                      _buildClassCard(context, 'Pemrograman Web',
                          'Ahmad Sahroni', 'Tidak Ada Tugas Terdekat', '', null),
                      _buildClassCard(context, 'Sistem Informasi',
                          'Bahlil Lahadalia', 'Tidak Ada Tugas Terdekat', '', null),
                      _buildClassCard(
                          context,
                          'IoT',
                          'Teddy Indra Wijaya',
                          kelas.isCompleted('IoT|Tugas 2: Sejarah Komputer')
                              ? 'Tidak Ada Tugas Terdekat'
                              : 'Tugas 2: Sejarah Komputer',
                          kelas.isCompleted('IoT|Tugas 2: Sejarah Komputer')
                              ? ''
                              : 'Jumat, 11 Nov',
                          kelas.isCompleted('IoT|Tugas 2: Sejarah Komputer')
                              ? null
                              : allSegeraTasks
                                  .firstWhere((t) => t.className == 'IoT')),
                      _buildClassCard(context, 'Kecerdasan Buatan',
                          'Rocky Gerung', 'Tidak Ada Tugas Terdekat', '', null),
                      _buildClassCard(context, 'UI/UX', 'Ivan Gunawan',
                          'Tidak Ada Tugas Terdekat', '', null),
                      _buildClassCard(
                          context,
                          'Web Framework',
                          'Windah Basudara',
                          kelas.isCompleted('Web Framework|Instalasi Node.js')
                              ? 'Tidak Ada Tugas Terdekat'
                              : 'Instalasi Node.js',
                          kelas.isCompleted('Web Framework|Instalasi Node.js')
                              ? ''
                              : 'Hari ini, 23.59',
                          kelas.isCompleted('Web Framework|Instalasi Node.js')
                              ? null
                              : allSegeraTasks.firstWhere(
                                  (t) => t.className == 'Web Framework')),
                      _buildClassCard(context, 'Statistika dan Data',
                          'Nadiem Makarim', 'Tidak Ada Tugas Terdekat', '', null),
                      _buildClassCard(
                          context,
                          'Pemrograman Dasar',
                          'Deddy Corbuzier',
                          kelas.isCompleted(
                                  'Pemrograman Dasar|Pengenalan JavaScript')
                              ? 'Tidak Ada Tugas Terdekat'
                              : 'Pengenalan JavaScript',
                          kelas.isCompleted(
                                  'Pemrograman Dasar|Pengenalan JavaScript')
                              ? ''
                              : 'Senin, 23.59',
                          kelas.isCompleted(
                                  'Pemrograman Dasar|Pengenalan JavaScript')
                              ? null
                              : allSegeraTasks.firstWhere(
                                  (t) => t.className == 'Pemrograman Dasar')),
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

  Widget _buildSummaryCard(
      BuildContext context, String count, String label, String type) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (context) => TugasListScreen(type: type))),
      child: Container(
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2B4A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF5C6B8A),
                fontWeight: FontWeight.w500,
              ),
            ),
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
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A2B4A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF5C6B8A),
                      ),
                    ),
                  ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFDDE8FF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    taskInfo,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: taskInfo.startsWith('Tidak')
                          ? FontStyle.italic
                          : FontStyle.normal,
                      color: taskInfo.startsWith('Tidak')
                          ? const Color(0xFF7A8FAB)
                          : const Color(0xFF1A2B4A),
                      fontWeight: taskInfo.startsWith('Tidak')
                          ? FontWeight.normal
                          : FontWeight.w600,
                    ),
                  ),
                  if (timeInfo.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        timeInfo,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF1A2B4A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
