import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common_widgets.dart';
import 'kelas_provider.dart';

// ── Task detail data ───────────────────────────────────────────────────────────
class _TaskDetail {
  final String classLabel;
  final String taskName;
  final String description;
  final String deadline;

  const _TaskDetail({
    required this.classLabel,
    required this.taskName,
    required this.description,
    required this.deadline,
  });
}

const Map<String, _TaskDetail> _taskDetails = {
  // ── Segera ───────────────────────────────────────────────────────────────────
  'Web Framework|Instalasi Node.js': _TaskDetail(
    classLabel: 'T6D Web Framework',
    taskName: 'Instalasi Node.js',
    deadline: 'Hari ini, 23.59',
    description:
        'Lakukan instalasi Node.js versi LTS terbaru pada perangkat masing-masing.\n\n'
        '• Unduh installer dari https://nodejs.org\n'
        '• Pilih versi LTS (Long Term Support)\n'
        '• Setelah instalasi selesai, buka terminal / command prompt dan jalankan perintah:\n'
        '   node --version\n'
        '   npm --version\n\n'
        'Screenshot hasil output versi tersebut dan unggah sebagai bukti instalasi berhasil.',
  ),
  'IoT|Tugas 2: Sejarah Komputer': _TaskDetail(
    classLabel: 'T6D IoT',
    taskName: 'Tugas 2: Sejarah Komputer',
    deadline: 'Jumat, 11 Nov',
    description:
        'Buat rangkuman singkat (min. 300 kata) tentang perkembangan komputer dari generasi pertama hingga saat ini, '
        'dikaitkan dengan relevansi teknologi IoT masa kini.\n\n'
        '• Format pengumpulan: PDF\n'
        '• Nama file: NIM_NamaLengkap_TugasSejarahKomputer.pdf\n'
        '• Sertakan minimal 2 referensi jurnal atau buku ilmiah',
  ),
  'Pemrograman Dasar|Pengenalan JavaScript': _TaskDetail(
    classLabel: 'T6D Pemrograman Dasar',
    taskName: 'Pengenalan JavaScript',
    deadline: 'Senin, 23.59',
    description:
        'Buat program JavaScript sederhana menggunakan konsep berikut:\n\n'
        '• Variabel (var, let, const)\n'
        '• Tipe data dasar (string, number, boolean)\n'
        '• Percabangan if-else\n'
        '• Perulangan for/while\n\n'
        'Kumpulkan dalam format:\n'
        '• File .js yang bisa dijalankan di browser / Node.js\n'
        '• Screenshot hasil output program',
  ),

  // ── Selesai ──────────────────────────────────────────────────────────────────
  'UI/UX|CBL 2: Low-Fidelity': _TaskDetail(
    classLabel: 'T6D UI/UX',
    taskName: 'CBL 2: Low-Fidelity Design',
    deadline: 'Kamis, 23.59',
    description:
        'Rancang wireframe low-fidelity berbasis mobile app untuk aplikasi LMS EduInsight. '
        'Pastikan tata letak komponen dan alur navigasinya terdefinisi dengan jelas.\n\n'
        'Ketentuan pengumpulan:\n'
        '• Format: Link Figma / PDF\n'
        '• Akses link wajib diset Anyone with link',
  ),
  'Statistika dan Data|Quizziz Matriks': _TaskDetail(
    classLabel: 'T6D Statistika dan Data',
    taskName: 'Quizziz Matriks',
    deadline: 'Jumat, 23.59',
    description:
        'Kerjakan kuis Matriks melalui tautan berikut:\n'
        'https://quizizz.com/join?gc=MATRIKS2024\n\n'
        'Setelah selesai mengerjakan, screenshot hasil skor yang kamu dapatkan '
        'dan unggah pada kolom Tugas Saya di bawah sebagai bukti pengerjaan.\n\n'
        'Catatan: Kuis hanya bisa dikerjakan satu kali. Pastikan koneksi internet stabil sebelum memulai.',
  ),
  'Kecerdasan Buatan|AI Klasik dan Modern': _TaskDetail(
    classLabel: 'T6D Kecerdasan Buatan',
    taskName: 'AI Klasik dan Modern',
    deadline: 'Rabu, 23.59',
    description:
        'Buat makalah perbandingan antara pendekatan AI Klasik (rule-based, expert system) '
        'dan AI Modern (machine learning, deep learning).\n\n'
        '• Minimal 5 halaman A4, font Times New Roman 12pt, spasi 1.5\n'
        '• Sertakan contoh implementasi nyata untuk masing-masing pendekatan\n'
        '• Format pengumpulan: PDF\n'
        '• Nama file: NIM_AIKlasikModern.pdf',
  ),
  'Pemrograman Web|Tipe Data dan Method': _TaskDetail(
    classLabel: 'T6D Pemrograman Web',
    taskName: 'Tipe Data dan Method',
    deadline: 'Rabu, 23.59',
    description:
        'Implementasikan berbagai tipe data dan method bawaan JavaScript:\n\n'
        '• String methods: toUpperCase, split, includes, replace\n'
        '• Number methods: toFixed, parseInt, parseFloat\n'
        '• Array methods: map, filter, reduce, forEach\n\n'
        'Buat minimal 2 contoh penggunaan per method, unggah dalam file .js '
        'beserta screenshot output di browser/console.',
  ),
  'IoT|Pertemuan Pertama IoT': _TaskDetail(
    classLabel: 'T6D IoT',
    taskName: 'Pertemuan Pertama IoT',
    deadline: 'Rabu, 23.59',
    description:
        'Setelah mengikuti pertemuan pertama IoT, buat catatan singkat yang mencakup:\n\n'
        '• Definisi IoT dan ekosistemnya\n'
        '• Minimal 3 contoh perangkat IoT dalam kehidupan sehari-hari\n'
        '• Tantangan keamanan pada sistem IoT\n\n'
        'Unggah dalam format PDF.',
  ),
  'Pemrograman Web|Pertemuan Pertama Pemweb': _TaskDetail(
    classLabel: 'T6D Pemrograman Web',
    taskName: 'Pertemuan Pertama Pemweb',
    deadline: 'Rabu, 23.59',
    description:
        'Buat ringkasan materi pertemuan pertama Pemrograman Web yang mencakup:\n\n'
        '• Struktur dasar HTML (DOCTYPE, head, body)\n'
        '• Tag-tag umum HTML5\n'
        '• Perbedaan HTML, CSS, dan JavaScript\n\n'
        'Format: PDF, dikumpulkan maksimal H+1 setelah pertemuan.',
  ),
  'Sistem Informasi|Pertemuan Pertama Sistem Informasi': _TaskDetail(
    classLabel: 'T6D Sistem Informasi',
    taskName: 'Pertemuan Pertama Sistem Informasi',
    deadline: 'Rabu, 23.59',
    description:
        'Rangkum materi pengantar Sistem Informasi yang mencakup:\n\n'
        '• Definisi dan komponen Sistem Informasi\n'
        '• Jenis-jenis Sistem Informasi (TPS, MIS, DSS, EIS)\n'
        '• Peran Sistem Informasi dalam organisasi modern\n\n'
        'Unggah dalam format PDF, maks 2 halaman.',
  ),
};

// ─────────────────────────────────────────────────────────────────────────────

class DetailTugasScreen extends StatelessWidget {
  final String taskTitle;
  final String className;

  const DetailTugasScreen({
    super.key,
    required this.taskTitle,
    required this.className,
  });

  @override
  Widget build(BuildContext context) {
    final key = '$className|$taskTitle';
    final detail = _taskDetails[key];
    final classLabel = detail?.classLabel ?? className;
    final taskName = detail?.taskName ?? taskTitle;
    final description = detail?.description ?? 'Detail tugas belum tersedia.';
    final deadline = detail?.deadline ?? '-';

    return Consumer<KelasProvider>(builder: (context, kelas, _) {
      final isCompleted = kelas.isCompleted(key);
      final isInitial = kelas.isInitiallyCompleted(key);
      final hasDoc = kelas.hasDoc(key);
      final fileName = kelas.mockFileName(key);

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
        ),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // ── Main scrollable content ─────────────────────────────
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Yellow header
                        Container(
                          color: kActive,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(classLabel,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                              const SizedBox(height: 4),
                              Text(taskName,
                                  style: const TextStyle(fontSize: 14, color: Colors.black)),
                            ],
                          ),
                        ),
                        // Blue body
                        Container(
                          color: kCardBlue,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                const Icon(Icons.access_time,
                                    size: 14, color: Colors.black54),
                                const SizedBox(width: 6),
                                Text('Tenggat: $deadline',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500)),
                              ]),
                              const SizedBox(height: 12),
                              Text(description,
                                  style: const TextStyle(
                                      fontSize: 12, height: 1.6, color: Colors.black)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── DraggableScrollableSheet ───────────────────────────
                  DraggableScrollableSheet(
                    initialChildSize: 0.22,
                    minChildSize: 0.18,
                    maxChildSize: isCompleted ? 0.55 : 0.75,
                    snap: true,
                    snapSizes: isCompleted ? [0.22, 0.55] : [0.22, 0.75],
                    builder: (ctx, scrollController) {
                      return Container(
                        decoration: const BoxDecoration(
                          color: kCardBlue,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: ListView(
                          controller: scrollController,
                          padding: EdgeInsets.zero,
                          children: [
                            // ── Drag handle ──────────────────────────────
                            Center(
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 10),
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),

                            // ── Tugas Saya header ────────────────────────
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Tugas Saya',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black)),
                                  Text(
                                    isCompleted ? 'Diserahkan' : 'Belum Diserahkan',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isCompleted
                                          ? Colors.green[700]
                                          : Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            if (isCompleted) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                child: _docChip(fileName),
                              ),
                              const SizedBox(height: 8),
                              if (!isInitial)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 20),
                                  child: _fullWidthButton(
                                    'Batalkan Pengiriman',
                                    color: const Color(0xFFFFD0D0),
                                    textColor: Colors.red[700]!,
                                    onTap: () => kelas.cancelSubmission(key),
                                  ),
                                ),
                              const SizedBox(height: 20),
                            ] else ...[
                              if (!hasDoc)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                                  child: Container(
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white
                                          .withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(12),
                                      border:
                                          Border.all(color: Colors.black12),
                                    ),
                                    child: const Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.cloud_upload_outlined,
                                              color: Colors.black26, size: 28),
                                          SizedBox(height: 4),
                                          Text(
                                            'Belum ada dokumen yang diunggah',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.black38),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                                  child: _docChip(fileName),
                                ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20),
                                child: _fullWidthButton(
                                  '+ Unggah Dokumen Di Sini',
                                  onTap: () => kelas.uploadDoc(key),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20),
                                child: _fullWidthButton(
                                  'Tandai Selesai',
                                  onTap: () => kelas.markComplete(key),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── BottomBar di luar Stack ─────────────────────────────────
            const BottomBar(currentIndex: 1),
          ],
        ),
      );
    });
  }

  Widget _docChip(String fileName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.description_outlined, color: Colors.black54, size: 20),
          const SizedBox(width: 8),
          Text(fileName, style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _fullWidthButton(
    String text, {
    required VoidCallback onTap,
    Color color = Colors.white,
    Color textColor = Colors.black54,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.7),
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(text, style: TextStyle(fontSize: 14, color: textColor)),
        ),
      ),
    );
  }
}
