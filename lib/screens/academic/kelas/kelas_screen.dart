import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common_widgets.dart';
import '../academic_widgets.dart';
import 'gabung_kelas_screen.dart';
import 'kelas_provider.dart';
import 'tugas_list_screen.dart';

// ---------- Model tugas (dipakai tugas_list_screen & detail tugas) ----------
class TaskItem {
  final String title;
  final String subtitle;
  final String status;
  final String className;

  const TaskItem(this.title, this.subtitle, this.status, this.className);
}

// Data contoh: ganti dengan data aslimu
const List<TaskItem> allSegeraTasks = [
  TaskItem('Tugas 1 - Quiziz', 'Kewirausahaan', 'Hari ini, 23.59', 'Kewirausahaan'),
  TaskItem('Tugas 1 - Analisa Aplikasi', 'UI/UX Design', 'Hari ini, 23.59', 'UI/UX Design'),
  TaskItem('Pertemuan Pertama', 'IoT', 'Rabu, 23.59', 'IoT'),
];

const List<TaskItem> allSelesaiTasks = [
  TaskItem('Tugas Pengenalan AI', 'Kecerdasan Buatan', 'Diserahkan', 'Kecerdasan Buatan'),
  TaskItem('Latihan SQL Dasar', 'Basis Data', 'Diserahkan', 'Basis Data'),
  TaskItem('Tugas Array & Function', 'Pemrograman Web', 'Diserahkan', 'Pemrograman Web'),
  TaskItem('Laporan Praktikum 1', 'IoT', 'Diserahkan', 'IoT'),
];

// ---------- Model tampilan ----------
class RingkasanTugas {
  final String label;
  final String type; // 'segera' / 'terlambat' / 'selesai' (dipakai TugasListScreen)

  const RingkasanTugas({required this.label, required this.type});
}

class KelasItem {
  final String nama;
  final String dosen;
  final String? tugas; // null = tidak ada tugas terdekat
  final String? tenggat;

  const KelasItem({
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

// Data contoh (IoT & Kecerdasan Buatan mengikuti desain)
const List<KelasItem> dataKelas = [
  KelasItem(
    nama: 'Pemrograman Web',
    dosen: 'Nama Dosen',
    tugas: 'Pertemuan Pertama',
    tenggat: 'Rabu, 23.59',
  ),
  KelasItem(
    nama: 'IoT',
    dosen: 'Teddy Indra Wijaya',
    tugas: 'Pertemuan Pertama',
    tenggat: 'Rabu, 23.59',
  ),
  KelasItem(nama: 'Kecerdasan Buatan', dosen: 'Rocky Gerung'),
];

// ---------- Halaman ----------
class KelasScreen extends StatelessWidget {
  const KelasScreen({super.key});

  // "Gabung Kelas" tampil sebagai notifikasi (dialog) di atas halaman
  void _bukaGabungKelas(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const GabungKelasScreen(),
    );
  }

  // Jumlah tugas segera = tugas segera yang belum diserahkan
  int _hitungSegera(KelasProvider kelas) {
    int jumlah = 0;
    for (TaskItem t in allSegeraTasks) {
      if (!kelas.isCompleted('${t.className}|${t.title}')) {
        jumlah = jumlah + 1;
      }
    }
    return jumlah;
  }

  int _hitungJumlah(String type, KelasProvider kelas) {
    int segera = _hitungSegera(kelas);
    if (type == 'segera') return segera;
    if (type == 'selesai') {
      return allSelesaiTasks.length + (allSegeraTasks.length - segera);
    }
    return 0; // terlambat
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF23272F) : const Color(0xFFFDFDFD);
    final double lebar = MediaQuery.of(context).size.width;
    final double pad = lebar < 360 ? 14 : 20;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          BackHeaderBar(
            title: 'Kelas',
            trailing: TextButton(
              onPressed: () => _bukaGabungKelas(context),
              child: const Text(
                'Gabung Kelas',
                style: TextStyle(
                  color: kActive,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<KelasProvider>(
              builder: (context, kelas, _) {
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(pad, 18, pad, 12),
                  // batas lebar supaya tetap rapi di tablet
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        children: [
                          _buildRingkasan(context, kelas),
                          const SizedBox(height: 16),
                          Column(
                            children: dataKelas
                                .map((k) => _KelasCard(kelas: k))
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

  Widget _buildRingkasan(BuildContext context, KelasProvider kelas) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: kYellow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Tugas',
            style: TextStyle(fontSize: 17, color: Color(0xFF5E5D45)),
          ),
          const SizedBox(height: 10),
          Row(
            children: dataRingkasan.map((r) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _CountTile(
                    label: r.label,
                    jumlah: _hitungJumlah(r.type, kelas),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TugasListScreen(type: r.type),
                        ),
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CountTile extends StatelessWidget {
  final String label;
  final int jumlah;
  final VoidCallback onTap;

  const _CountTile({
    required this.label,
    required this.jumlah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFF0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              '$jumlah',
              style: const TextStyle(fontSize: 18, color: Color(0xFF5E5D45)),
            ),
            const SizedBox(
              width: 48,
              child: Divider(color: Color(0xFF8C8A7A), thickness: 1, height: 8),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF5E5D45)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Kartu kelas: nama + dosen, lalu strip biru tugas terdekat ----------
class _KelasCard extends StatelessWidget {
  final KelasItem kelas;

  const _KelasCard({required this.kelas});

  @override
  Widget build(BuildContext context) {
    final String? tugas = kelas.tugas;
    final String? tenggat = kelas.tenggat;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kelas.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
                Text(
                  kelas.dosen,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A8A)),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: const Color(0xFFDCE6FF),
            child: (tugas != null && tenggat != null)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          tugas,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A8A)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tenggat,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A8A)),
                      ),
                    ],
                  )
                : const Center(
                    child: Text(
                      'Tidak Ada Tugas Terdekat',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF8A8A8A),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}