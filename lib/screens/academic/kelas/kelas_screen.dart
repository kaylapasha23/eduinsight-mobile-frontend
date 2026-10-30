
import 'package:flutter/material.dart';
import '../../common_widgets.dart';
import '../academic_widgets.dart';
import 'gabung_kelas_screen.dart';
import 'kelas_provider.dart';
import 'tugas_list_screen.dart';
import 'detail_tugas_screen.dart';
import 'package:provider/provider.dart';

class TaskItem {
  final String title;
  final String subtitle;
  final String status;
  final String className;
  final bool isDefaultPastDeadline;

  const TaskItem(
    this.title,
    this.subtitle,
    this.status,
    this.className, {
    this.isDefaultPastDeadline = false,
  });
}

const List<TaskItem> allSegeraTasks = [
  TaskItem('Tugas 1 - Quiziz', 'Kewirausahaan',
      'Hari ini, 23.59', 'Kewirausahaan'),
  TaskItem('Tugas 1 - Analisa Aplikasi', 'UI/UX Design',
      'Hari ini, 23.59', 'UI/UX Design'),
  TaskItem('Pertemuan Pertama', 'Internet of Things (IoT)',
      'Rabu, 23.59', 'Internet of Things (IoT)'),
];

const List<TaskItem> allSelesaiTasks = [
  TaskItem('Tugas Pengenalan AI', 'Kecerdasan Buatan',
      'Diserahkan', 'Kecerdasan Buatan',
      isDefaultPastDeadline: true),
  TaskItem('Latihan SQL Dasar', 'Basis Data',
      'Diserahkan', 'Basis Data',
      isDefaultPastDeadline: true),
  TaskItem('Tugas Array & Function', 'Pemrograman Web',
      'Diserahkan', 'Pemrograman Web',
      isDefaultPastDeadline: true),
  TaskItem('Laporan Praktikum 1', 'Internet of Things (IoT)',
      'Diserahkan', 'Internet of Things (IoT)',
      isDefaultPastDeadline: true),
];

class RingkasanTugas {
  final String label;
  final String type;

  const RingkasanTugas({required this.label, required this.type});
}

class MatkulTugasItem {
  final String nama;
  final String dosen;
  final String? tugas;
  final String? tenggat;

  const MatkulTugasItem({
    required this.nama,
    required this.dosen,
    this.tugas,
    this.tenggat,
  });
}

const List<RingkasanTugas> dataRingkasan = [
  RingkasanTugas(label: 'Segera', type: 'segera'),
  RingkasanTugas(label: 'Terlambat', type: 'terlambat'),
  RingkasanTugas(label: 'Selesai', type: 'selesai'),
];

const List<MatkulTugasItem> dataMatkulTugas = [
  MatkulTugasItem(
    nama: 'Kewirausahaan',
    dosen: 'Dr. Rini Handayani, M.M.',
    tugas: 'Tugas 1 - Quiziz',
    tenggat: 'Hari ini, 23.59',
  ),
  MatkulTugasItem(
    nama: 'UI/UX Design',
    dosen: 'Ivan Gunawan, M.Ds.',
    tugas: 'Tugas 1 - Analisa Aplikasi',
    tenggat: 'Hari ini, 23.59',
  ),
  MatkulTugasItem(
    nama: 'Internet of Things (IoT)',
    dosen: 'Teddy Indra Wijaya, M.Kom.',
    tugas: 'Pertemuan Pertama',
    tenggat: 'Rabu, 23.59',
  ),
];

class KelasScreen extends StatelessWidget {
  const KelasScreen({super.key});

  void _bukaGabungMatkul(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const GabungKelasScreen(),
    );
  }

  int _hitungJumlah(String type, KelasProvider kelas) {
    final userCompletedSegeraCount = allSegeraTasks
        .where((t) => kelas.isCompleted('${t.className}|${t.title}'))
        .length;

    final activeSelesaiCount = allSelesaiTasks
        .where((t) => kelas.isCompleted('${t.className}|${t.title}'))
        .length;

    final totalSelesai =
        activeSelesaiCount + userCompletedSegeraCount;

    final lateFromSegera = allSegeraTasks
        .where((t) => kelas.isLate('${t.className}|${t.title}'))
        .length;

    final lateFromSelesai = allSelesaiTasks
        .where((t) =>
            !kelas.isCompleted('${t.className}|${t.title}') &&
            kelas.isLate('${t.className}|${t.title}'))
        .length;

    final totalTerlambat = lateFromSegera + lateFromSelesai;

    final totalSegera = allSegeraTasks
            .where((t) =>
                !kelas.isCompleted('${t.className}|${t.title}') &&
                !kelas.isLate('${t.className}|${t.title}'))
            .length +
        allSelesaiTasks
            .where((t) =>
                !kelas.isCompleted('${t.className}|${t.title}') &&
                !kelas.isLate('${t.className}|${t.title}'))
            .length;

    if (type == 'segera') return totalSegera;
    if (type == 'terlambat') return totalTerlambat;
    if (type == 'selesai') return totalSelesai;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark
        ? const Color(0xFF1E222A)
        : const Color(0xFFF7F9FC);

    final cardBg = isDark
        ? const Color(0xFF282D37)
        : Colors.white;

    final titleColor = isDark
        ? Colors.white
        : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          BackHeaderBar(
            title: 'Tugas Kuliah',
            trailing: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
              ),
              onPressed: () => _bukaGabungMatkul(context),
              icon: const Icon(
                Icons.add_link_rounded,
                size: 16,
                color: Colors.white,
              ),
              label: const Text(
                'Gabung Mata Kuliah',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<KelasProvider>(
              builder: (context, kelas, _) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildModernRingkasan(
                            context,
                            kelas,
                            isDark,
                            cardBg,
                          ),
                          const SizedBox(height: 22),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Daftar Tugas per Mata Kuliah',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: titleColor,
                                ),
                              ),
                              Text(
                                '${dataMatkulTugas.length} Matkul',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? const Color(0xFF9AA4B8)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Column(
                            children: dataMatkulTugas
                                .map(
                                  (k) => _buildModernMatkulTugasCard(
                                    context,
                                    k,
                                    isDark,
                                    cardBg,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const BottomBar(currentIndex: 1),
        ],
      ),
    );
  }

  Widget _buildModernRingkasan(
    BuildContext context,
    KelasProvider kelas,
    bool isDark,
    Color cardBg,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? const Color(0xFF3B4555)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.16 : 0.04,
            ),
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
                'Ringkasan Tugas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? Colors.white
                      : const Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF323B4C)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Semester 4',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFF93C5FD)
                        : const Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: dataRingkasan.map((r) {
              final Color badgeColor;
              final Color badgeBg;

              if (r.type == 'segera') {
                badgeColor = isDark
                    ? const Color(0xFFFBBF24)
                    : const Color(0xFFF59E0B);
                badgeBg = isDark
                    ? const Color(0xFF3A352B)
                    : const Color(0xFFFFF8E8);
              } else if (r.type == 'selesai') {
                badgeColor = isDark
                    ? const Color(0xFF34D399)
                    : const Color(0xFF10B981);
                badgeBg = isDark
                    ? const Color(0xFF293B38)
                    : const Color(0xFFECFDF5);
              } else {
                badgeColor = isDark
                    ? const Color(0xFFF87171)
                    : const Color(0xFFEF4444);
                badgeBg = isDark
                    ? const Color(0xFF3D3035)
                    : const Color(0xFFFEF2F2);
              }

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TugasListScreen(type: r.type),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: badgeColor.withValues(
                            alpha: isDark ? 0.45 : 0.3,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${_hitungJumlah(r.type, kelas)}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: badgeColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            r.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildModernMatkulTugasCard(
    BuildContext context,
    MatkulTugasItem item,
    bool isDark,
    Color cardBg,
  ) {
    final hasTask = item.tugas != null && item.tenggat != null;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? const Color(0xFF3B4555)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.14 : 0.03,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF323B4C)
                        : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    color: isDark
                        ? const Color(0xFF93C5FD)
                        : const Color(0xFF2563EB),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.nama,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.dosen,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFF9AA4B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: hasTask
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailTugasScreen(
                          taskTitle: item.tugas!,
                          className: item.nama,
                        ),
                      ),
                    );
                  }
                : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF323B4C)
                    : const Color(0xFFF1F5F9),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: hasTask
                  ? Row(
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 15,
                          color: isDark
                              ? const Color(0xFF93C5FD)
                              : const Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.tugas!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF334155),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF3D3035)
                                : const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.tenggat!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? const Color(0xFFF87171)
                                  : const Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 14,
                          color: isDark
                              ? const Color(0xFF9AA4B8)
                              : Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Tidak Ada Tugas Terdekat',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: isDark
                                ? const Color(0xFF9AA4B8)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
