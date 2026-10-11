import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'kelas_provider.dart';

// ── Custom ScrollBehavior to completely remove scrollbars on all platforms ──
class _NoScrollbarBehavior extends ScrollBehavior {
  const _NoScrollbarBehavior();

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

// ── Task detail data ───────────────────────────────────────────────────────────
class _TaskDetail {
  final String classLabel;
  final String taskName;
  final String description;
  final String deadline;
  final List<String> lecturerDocs;

  const _TaskDetail({
    required this.classLabel,
    required this.taskName,
    required this.description,
    required this.deadline,
    this.lecturerDocs = const [],
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
    lecturerDocs: [
      'Panduan_Instalasi_NodeJS.pdf',
      'Modul_Praktikum_01.pdf',
    ],
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
    lecturerDocs: [
      'Design_System_Brief.pdf',
      'Template_Wireframe_Mobile.fig',
    ],
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

class DetailTugasScreen extends StatefulWidget {
  final String taskTitle;
  final String className;

  const DetailTugasScreen({
    super.key,
    required this.taskTitle,
    required this.className,
  });

  @override
  State<DetailTugasScreen> createState() => _DetailTugasScreenState();
}

class _DetailTugasScreenState extends State<DetailTugasScreen> {
  double? _sheetHeight;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final key = '${widget.className}|${widget.taskTitle}';
    final detail = _taskDetails[key];
    final classLabel = detail?.classLabel ?? widget.className;
    final taskName = detail?.taskName ?? widget.taskTitle;
    final description = detail?.description ?? 'Detail tugas belum tersedia.';
    final deadline = detail?.deadline ?? '-';
    final lecturerDocs = detail?.lecturerDocs ?? const <String>[];

    return Consumer<KelasProvider>(builder: (context, kelas, _) {
      final isCompleted = kelas.isCompleted(key);
      final hasDoc = kelas.hasDoc(key);
      final fileName = kelas.mockFileName(key);

      return Scaffold(
        backgroundColor: const Color(0xFFF0F4FF),
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
                'Detail Tugas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final totalHeight = constraints.maxHeight;
            const minHeight = 220.0;
            final maxHeight = (totalHeight * 0.94).clamp(minHeight, totalHeight);
            _sheetHeight ??= minHeight;

            void onDragStart(DragStartDetails details) {
              _isDragging = true;
            }

            void onDragUpdate(DragUpdateDetails details) {
              setState(() {
                _sheetHeight = ((_sheetHeight ?? minHeight) - details.delta.dy)
                    .clamp(minHeight, maxHeight);
              });
            }

            void onDragEnd(DragEndDetails details) {
              _isDragging = false;
              setState(() {
                if (details.primaryVelocity != null && details.primaryVelocity! < -200) {
                  _sheetHeight = maxHeight;
                } else if (details.primaryVelocity != null && details.primaryVelocity! > 200) {
                  _sheetHeight = minHeight;
                } else {
                  if ((_sheetHeight ?? minHeight) > (minHeight + maxHeight) / 2) {
                    _sheetHeight = maxHeight;
                  } else {
                    _sheetHeight = minHeight;
                  }
                }
              });
            }

            void toggleSheet() {
              setState(() {
                if ((_sheetHeight ?? minHeight) < (minHeight + maxHeight) / 2) {
                  _sheetHeight = maxHeight;
                } else {
                  _sheetHeight = minHeight;
                }
              });
            }

            final isExpanded = (_sheetHeight ?? minHeight) > (minHeight + maxHeight) / 2;

            return Stack(
              children: [
                // ── Main scrollable task content ─────────────────────────────
                ScrollConfiguration(
                  behavior: const _NoScrollbarBehavior(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 260),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header info card
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9DB),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4A300).withValues(alpha: 0.14),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                classLabel,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF7A6500),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                taskName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A2B4A),
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Body task card
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDE8FF),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3B6FE8).withValues(alpha: 0.12),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.access_time_rounded,
                                        size: 14, color: Color(0xFF1A2B4A)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Tenggat: $deadline',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF1A2B4A),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                description,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.6,
                                  color: Color(0xFF1A2B4A),
                                ),
                              ),
                              // Lampiran dari Dosen jika ada
                              if (lecturerDocs.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                Divider(
                                  color: const Color(0xFF1E2B52).withValues(alpha: 0.12),
                                  thickness: 1,
                                  height: 1,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: const [
                                    Icon(Icons.attachment_rounded,
                                        size: 16, color: Color(0xFF1A2B4A)),
                                    SizedBox(width: 6),
                                    Text(
                                      'Lampiran dari Pengajar',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A2B4A),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ...lecturerDocs.map(
                                  (doc) => Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.black.withValues(alpha: 0.06)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.file_present_rounded,
                                            size: 20, color: Color(0xFF3A6BBF)),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            doc,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1A2B4A),
                                            ),
                                          ),
                                        ),
                                        const Icon(Icons.download_rounded,
                                            size: 18, color: Color(0xFF5C6B8A)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Interactive Bottom Sheet: "Tugas Saya" ─────────────────────
                // Can be dragged with mouse or touch, or tapped to expand to full screen!
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: _sheetHeight,
                  child: AnimatedContainer(
                    duration: _isDragging ? Duration.zero : const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E2B52).withValues(alpha: 0.24),
                          blurRadius: 30,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Drag Handle & Header bar with full mouse/touch drag support
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onVerticalDragStart: onDragStart,
                          onVerticalDragUpdate: onDragUpdate,
                          onVerticalDragEnd: onDragEnd,
                          onTap: toggleSheet,
                          child: Container(
                            color: Colors.transparent,
                            child: Column(
                              children: [
                                // Visual drag handle
                                Center(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 12),
                                    width: 52,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            'Tugas Saya',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1A2B4A),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            isExpanded
                                                ? Icons.keyboard_arrow_down_rounded
                                                : Icons.keyboard_arrow_up_rounded,
                                            color: const Color(0xFF5C6B8A),
                                            size: 22,
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: isCompleted
                                              ? const Color(0xFF34C759).withValues(alpha: 0.14)
                                              : const Color(0xFFFF9F0A).withValues(alpha: 0.14),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          isCompleted ? 'Diserahkan' : 'Belum Diserahkan',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isCompleted
                                                ? const Color(0xFF248A3D)
                                                : const Color(0xFFC97A00),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),

                        // Inner content
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onVerticalDragStart: !isExpanded ? onDragStart : null,
                            onVerticalDragUpdate: !isExpanded ? onDragUpdate : null,
                            onVerticalDragEnd: !isExpanded ? onDragEnd : null,
                            child: ScrollConfiguration(
                              behavior: const _NoScrollbarBehavior(),
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    if (isCompleted) ...[
                                      if (hasDoc)
                                        _docChip(fileName)
                                      else
                                        Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF4F7FF),
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(color: const Color(0xFFDDE8FF)),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.check_circle_outline_rounded,
                                                  color: Color(0xFF34C759), size: 22),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  'Ditandai selesai (tanpa dokumen lampiran)',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF1A2B4A),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      const SizedBox(height: 16),
                                      // Button Batalkan Pengiriman: SELALU TAMPIL DENGAN WARNA MERAH SOLID KONSISTEN
                                      _fullWidthButton(
                                        'Batalkan Pengiriman',
                                        color: const Color(0xFFE5484D),
                                        textColor: Colors.white,
                                        onTap: () => kelas.cancelSubmission(key),
                                      ),
                                      const SizedBox(height: 28),
                                    ] else ...[
                                      if (!hasDoc)
                                        Container(
                                          height: 96,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF4F7FF),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                                color: const Color(0xFFDDE8FF), width: 1.5),
                                          ),
                                          child: const Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.cloud_upload_outlined,
                                                    color: Color(0xFF3A6BBF), size: 30),
                                                SizedBox(height: 6),
                                                Text(
                                                  'Belum ada dokumen yang diunggah',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF5C6B8A),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      else
                                        _docChip(fileName),
                                      const SizedBox(height: 14),
                                      _fullWidthButton(
                                        '+ Unggah Dokumen Di Sini',
                                        color: const Color(0xFFF0F4FF),
                                        textColor: const Color(0xFF1E2B52),
                                        borderColor: const Color(0xFFDDE8FF),
                                        onTap: () => kelas.uploadDoc(key),
                                      ),
                                      const SizedBox(height: 10),
                                      _fullWidthButton(
                                        'Tandai Selesai',
                                        color: const Color(0xFF1A2547),
                                        textColor: Colors.white,
                                        onTap: () => kelas.markComplete(key),
                                      ),
                                      const SizedBox(height: 28),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    });
  }

  Widget _docChip(String fileName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDE8FF), width: 1.2),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, color: Color(0xFF3A6BBF), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A2B4A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fullWidthButton(
    String text, {
    required VoidCallback onTap,
    Color color = Colors.white,
    Color textColor = Colors.black54,
    Color? borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: borderColor != null ? Border.all(color: borderColor) : null,
          boxShadow: [
            BoxShadow(
              color: color == const Color(0xFFE5484D)
                  ? const Color(0xFFE5484D).withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
