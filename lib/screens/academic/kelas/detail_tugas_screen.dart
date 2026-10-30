import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'kelas_provider.dart';

class _NoScrollbarBehavior extends ScrollBehavior {
  const _NoScrollbarBehavior();

  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

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
  'Kewirausahaan|Tugas 1 - Quiziz': _TaskDetail(
    classLabel: 'Kewirausahaan',
    taskName: 'Tugas 1 - Quiziz',
    deadline: 'Hari ini, 23.59',
    description:
        'Kerjakan kuis Kewirausahaan melalui Quizizz materi BMC (Business Model Canvas).\n\n'
        '• Kerjakan tepat waktu sebelum tenggat\n'
        '• Screenshot nilai akhir kuis dan lampirkan sebagai bukti pengerjaan tugas.',
    lecturerDocs: ['Panduan_Kuis_Kewirausahaan.pdf'],
  ),
  'UI/UX Design|Tugas 1 - Analisa Aplikasi': _TaskDetail(
    classLabel: 'UI/UX Design',
    taskName: 'Tugas 1 - Analisa Aplikasi',
    deadline: 'Hari ini, 23.59',
    description:
        'Lakukan analisa heuristik pada aplikasi mobile EduTech pilihanmu.\n\n'
        '• Identifikasi 5 masalah usability beserta rekomendasi perbaikannya\n'
        '• Kumpulkan dalam format PDF rangkuman laporan.',
    lecturerDocs: ['Template_Analisa_Heuristik.pdf'],
  ),
  'Internet of Things (IoT)|Pertemuan Pertama': _TaskDetail(
    classLabel: 'Internet of Things (IoT)',
    taskName: 'Pertemuan Pertama',
    deadline: 'Rabu, 23.59',
    description:
        'Buat rangkuman singkat mengenai komponen mikrokontroler ESP32 dan protokol MQTT.\n\n'
        '• Format: PDF (maksimal 2 halaman)\n'
        '• Unggah dokumen hasil resume pada bagian Tugas Saya di bawah.',
  ),
  'Kecerdasan Buatan|Tugas Pengenalan AI': _TaskDetail(
    classLabel: 'Kecerdasan Buatan',
    taskName: 'Tugas Pengenalan AI',
    deadline: 'Minggu Lalu, 23.59',
    description:
        'Rangkuman pengantar AI, perbedaan antara machine learning dan deep learning, serta implementasi agen cerdas.\n\n'
        'Status: Sudah diserahkan tepat waktu.',
    lecturerDocs: ['Modul_Pengenalan_AI.pdf'],
  ),
  'Basis Data|Latihan SQL Dasar': _TaskDetail(
    classLabel: 'Basis Data Terdistribusi',
    taskName: 'Latihan SQL Dasar',
    deadline: 'Minggu Lalu, 23.59',
    description:
        'Latihan query DDL & DML, join relasi tabel, dan agregasi data pada MySQL / PostgreSQL.\n\n'
        'Status: Sudah diserahkan tepat waktu.',
  ),
  'Pemrograman Web|Tugas Array & Function': _TaskDetail(
    classLabel: 'Pemrograman Web',
    taskName: 'Tugas Array & Function',
    deadline: '2 Minggu Lalu, 23.59',
    description:
        'Implementasi logika manipulasi array dan closure function pada JavaScript ES6+.\n\n'
        'Status: Sudah diserahkan tepat waktu.',
  ),
  'Internet of Things (IoT)|Laporan Praktikum 1': _TaskDetail(
    classLabel: 'Internet of Things (IoT)',
    taskName: 'Laporan Praktikum 1',
    deadline: '2 Minggu Lalu, 23.59',
    description:
        'Laporan hasil pembacaan sensor DHT22 ke serial monitor dan simulasi Wokwi.\n\n'
        'Status: Sudah diserahkan tepat waktu.',
  ),
};

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
    final description = detail?.description ??
        'Tugas perkuliahan semester berjalan. Silakan pelajari instruksi dan kumpulkan dokumen pekerjaan Anda.';
    final deadline = detail?.deadline ?? 'Rabu, 23.59';
    final lecturerDocs = detail?.lecturerDocs ?? const <String>[];

    return Consumer<KelasProvider>(
      builder: (context, kelas, _) {
        final isCompleted = kelas.isCompleted(key);
        final isLate = kelas.isLate(key);
        final hasDoc = kelas.hasDoc(key);
        final fileName = kelas.mockFileName(key);

        final isDark =
            Theme.of(context).brightness == Brightness.dark;

        final bgColor = isDark
            ? const Color(0xFF171C26)
            : const Color(0xFFF7F9FC);

        final cardBg = isDark
            ? const Color(0xFF252D3A)
            : Colors.white;

        final secondaryBg = isDark
            ? const Color(0xFF354258)
            : const Color(0xFFF1F5F9);

        final borderColor = isDark
            ? const Color(0xFF52627A)
            : const Color(0xFFE2E8F0);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: Container(
              color: const Color(0xFF1E2B52),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Detail Tugas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final totalHeight = constraints.maxHeight;

              final minHeight =
                  (totalHeight * 0.28).clamp(160.0, 240.0);

              final maxHeight =
                  (totalHeight * 0.92).clamp(
                minHeight + 60.0,
                totalHeight,
              );

              if (_sheetHeight == null) {
                _sheetHeight = minHeight;
              } else {
                _sheetHeight =
                    _sheetHeight!.clamp(minHeight, maxHeight);
              }

              void onDragStart(DragStartDetails details) {
                _isDragging = true;
              }

              void onDragUpdate(DragUpdateDetails details) {
                setState(() {
                  _sheetHeight = ((_sheetHeight ?? minHeight) -
                          details.delta.dy)
                      .clamp(minHeight, maxHeight);
                });
              }

              void onDragEnd(DragEndDetails details) {
                _isDragging = false;

                setState(() {
                  final velocity = details.primaryVelocity ?? 0;

                  if (velocity < -200) {
                    _sheetHeight = maxHeight;
                  } else if (velocity > 200) {
                    _sheetHeight = minHeight;
                  } else {
                    _sheetHeight =
                        (_sheetHeight! > (minHeight + maxHeight) / 2)
                            ? maxHeight
                            : minHeight;
                  }
                });
              }

              void toggleSheet() {
                setState(() {
                  _sheetHeight =
                      (_sheetHeight! < (minHeight + maxHeight) / 2)
                          ? maxHeight
                          : minHeight;
                });
              }

              final isExpanded =
                  _sheetHeight! > (minHeight + maxHeight) / 2;

              return Stack(
                children: [
                  Positioned.fill(
                    bottom: _sheetHeight,
                    child: ScrollConfiguration(
                      behavior: const _NoScrollbarBehavior(),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                            20, 20, 20, 20),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius:
                                    BorderRadius.circular(20),
                                border: Border.all(
                                  color: borderColor,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: isDark ? 0.3 : 0.04,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF1D4ED8)
                                              .withValues(alpha: 0.35)
                                          : const Color(0xFF2563EB)
                                              .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                      border: isDark
                                          ? Border.all(
                                              color: const Color(
                                                  0xFF60A5FA),
                                            )
                                          : null,
                                    ),
                                    child: Text(
                                      classLabel,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? const Color(0xFFBFDBFE)
                                            : const Color(0xFF2563EB),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    taskName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius:
                                    BorderRadius.circular(20),
                                border: Border.all(
                                  color: borderColor,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: isDark ? 0.3 : 0.04,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF7F1D1D)
                                              .withValues(alpha: 0.45)
                                          : const Color(0xFFEF4444)
                                              .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      border: isDark
                                          ? Border.all(
                                              color: const Color(
                                                  0xFFF87171),
                                            )
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 14,
                                          color: isDark
                                              ? const Color(0xFFFCA5A5)
                                              : const Color(0xFFDC2626),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Tenggat: $deadline',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? const Color(0xFFFECACA)
                                                : const Color(0xFFDC2626),
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    description,
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.6,
                                      color: isDark
                                          ? const Color(0xFFE2E8F0)
                                          : const Color(0xFF334155),
                                    ),
                                  ),
                                  if (lecturerDocs.isNotEmpty) ...[
                                    const SizedBox(height: 20),
                                    Divider(
                                      color: isDark
                                          ? const Color(0xFF52627A)
                                          : const Color(0xFFE2E8F0),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.attachment_rounded,
                                          size: 16,
                                          color: isDark
                                              ? const Color(0xFFBFDBFE)
                                              : const Color(0xFF1E293B),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Lampiran dari Pengajar',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight:
                                                FontWeight.w700,
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF0F172A),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ...lecturerDocs.map(
                                      (doc) => Container(
                                        margin: const EdgeInsets.only(
                                            bottom: 8),
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: secondaryBg,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          border: Border.all(
                                            color: borderColor,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.file_present_rounded,
                                              size: 20,
                                              color: Color(0xFF60A5FA),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                doc,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  color: isDark
                                                      ? Colors.white
                                                      : const Color(0xFF1E293B),
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              Icons.download_rounded,
                                              size: 18,
                                              color: isDark
                                                  ? const Color(0xFFBFDBFE)
                                                  : const Color(0xFF64748B),
                                            ),
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
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: _sheetHeight,
                    child: AnimatedContainer(
                      duration: _isDragging
                          ? Duration.zero
                          : const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                        border: Border(
                          top: BorderSide(
                            color: isDark
                                ? const Color(0xFF52627A)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.5 : 0.15,
                            ),
                            blurRadius: 30,
                            offset: const Offset(0, -6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onVerticalDragStart: onDragStart,
                            onVerticalDragUpdate: onDragUpdate,
                            onVerticalDragEnd: onDragEnd,
                            onTap: toggleSheet,
                            child: Column(
                              children: [
                                Center(
                                  child: Container(
                                    margin:
                                        const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    width: 48,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : Colors.black26,
                                      borderRadius:
                                          BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Tugas Saya',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight:
                                                  FontWeight.w800,
                                              color: isDark
                                                  ? Colors.white
                                                  : const Color(0xFF0F172A),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            isExpanded
                                                ? Icons.keyboard_arrow_down_rounded
                                                : Icons.keyboard_arrow_up_rounded,
                                            color: isDark
                                                ? const Color(0xFFCBD5E1)
                                                : const Color(0xFF64748B),
                                            size: 22,
                                          ),
                                        ],
                                      ),
                                      _statusBadge(
                                          isCompleted, isLate, isDark),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ScrollConfiguration(
                              behavior: const _NoScrollbarBehavior(),
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 8,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (isCompleted) ...[
                                      _docChip(fileName, isDark),
                                      const SizedBox(height: 18),
                                      _fullWidthButton(
                                        'Batalkan Pengiriman',
                                        color: const Color(0xFFEF4444),
                                        textColor: Colors.white,
                                        onTap: () {
                                          kelas.cancelSubmission(key);

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                kelas.isLate(key)
                                                    ? 'Pengiriman dibatalkan. Tugas ditandai Terlambat karena telah melewati deadline.'
                                                    : 'Pengiriman dibatalkan. Tugas kembali ke kategori Segera.',
                                              ),
                                              backgroundColor:
                                                  kelas.isLate(key)
                                                      ? const Color(0xFFDC2626)
                                                      : const Color(0xFFF59E0B),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        },
                                      ),
                                    ] else ...[
                                      if (!hasDoc)
                                        Container(
                                          height: 96,
                                          decoration: BoxDecoration(
                                            color: secondaryBg,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: borderColor,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.cloud_upload_outlined,
                                                  color: Color(0xFF60A5FA),
                                                  size: 30,
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  'Belum ada dokumen yang diunggah',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isDark
                                                        ? const Color(0xFFCBD5E1)
                                                        : const Color(0xFF64748B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      else
                                        _docChip(fileName, isDark),
                                      const SizedBox(height: 14),
                                      _fullWidthButton(
                                        '+ Unggah Dokumen Di Sini',
                                        color: isDark
                                            ? const Color(0xFF354258)
                                            : const Color(0xFFEFF6FF),
                                        textColor: isDark
                                            ? const Color(0xFFBFDBFE)
                                            : const Color(0xFF2563EB),
                                        borderColor:
                                            const Color(0xFF60A5FA),
                                        onTap: () => kelas.uploadDoc(key),
                                      ),
                                      const SizedBox(height: 10),
                                      _fullWidthButton(
                                        'Tandai Selesai',
                                        color: const Color(0xFF2563EB),
                                        textColor: Colors.white,
                                        onTap: () =>
                                            kelas.markComplete(key),
                                      ),
                                    ],
                                    const SizedBox(height: 24),
                                  ],
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
      },
    );
  }

  Widget _statusBadge(bool isCompleted, bool isLate, bool isDark) {
    final Color badgeColor = isCompleted
        ? (isDark
            ? const Color(0xFF6EE7B7)
            : const Color(0xFF10B981))
        : isLate
            ? (isDark
                ? const Color(0xFFFCA5A5)
                : const Color(0xFFEF4444))
            : (isDark
                ? const Color(0xFFFDE68A)
                : const Color(0xFFD97706));

    final badgeBg = isCompleted
        ? const Color(0xFF065F46).withValues(alpha: isDark ? 0.5 : 0.12)
        : isLate
            ? const Color(0xFF7F1D1D).withValues(alpha: isDark ? 0.5 : 0.12)
            : const Color(0xFF78350F).withValues(alpha: isDark ? 0.5 : 0.12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? badgeBg : badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: badgeColor.withValues(alpha: isDark ? 0.85 : 0.3),
          width: 1.2,
        ),
      ),
      child: Text(
        isCompleted
            ? 'Diserahkan'
            : isLate
                ? 'Terlambat'
                : 'Belum Diserahkan',
        style: TextStyle(
          fontSize: 11,
          color: badgeColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _docChip(String fileName, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF354258)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF64748B)
              : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.description_rounded,
            color: Color(0xFF60A5FA),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? Colors.white
                        : const Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Lampiran Tugas Mahasiswa',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF34D399),
            size: 18,
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: borderColor != null
              ? Border.all(color: borderColor)
              : null,
          boxShadow: [
            BoxShadow(
              color: color == const Color(0xFFEF4444)
                  ? const Color(0xFFEF4444)
                      .withValues(alpha: 0.28)
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
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}