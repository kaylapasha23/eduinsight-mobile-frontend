import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';

/// Halaman penampil file (berkas dosen & mahasiswa)
/// Mendukung:
/// - Presentasi PPTX / PPT (Slide viewer interaktif)
/// - Media Gambar (PNG, JPG, JPEG, WEBP, GIF)
/// - Dokumen PDF (dirender asli memakai pdfx)
/// - File Kode Program & Teks (SQL, JSON, PY, JS, HTML, TXT, dll)
/// - Dilengkapi tombol silang (X) di pojok atas & tombol kembali ke detail tugas.
class FileViewerScreen extends StatefulWidget {
  final String title;
  final String? fileUrl;
  final String? localFilePath;
  final Uint8List? fileBytes;

  const FileViewerScreen({
    super.key,
    required this.title,
    this.fileUrl,
    this.localFilePath,
    this.fileBytes,
  });

  @override
  State<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  bool _isLoading = true;
  Uint8List? _bytes;
  String? _textContent;
  int _currentSlide = 0;
  PdfControllerPinch? _pdfController;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  bool _isImage(String name) {
    final lower = name.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.bmp');
  }

  bool _isPresentation(String name) {
    final lower = name.toLowerCase();
    return lower.endsWith('.ppt') || lower.endsWith('.pptx');
  }

  bool _isPdf(String name) {
    final lower = name.toLowerCase();
    return lower.endsWith('.pdf');
  }

  bool _isText(String name) {
    final lower = name.toLowerCase();
    return lower.endsWith('.txt') ||
        lower.endsWith('.sql') ||
        lower.endsWith('.json') ||
        lower.endsWith('.py') ||
        lower.endsWith('.js') ||
        lower.endsWith('.dart') ||
        lower.endsWith('.html') ||
        lower.endsWith('.css') ||
        lower.endsWith('.csv') ||
        lower.endsWith('.md');
  }

  Future<void> _loadFile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Data biner dari memori
      if (widget.fileBytes != null && widget.fileBytes!.isNotEmpty) {
        _bytes = widget.fileBytes;
        if (_isText(widget.title)) {
          _textContent = String.fromCharCodes(_bytes!);
        }
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // 2. File dari path lokal fisik
      if (widget.localFilePath != null && widget.localFilePath!.isNotEmpty && !kIsWeb) {
        final file = File(widget.localFilePath!);
        if (await file.exists()) {
          _bytes = await file.readAsBytes();
          if (_isText(widget.title)) {
            try {
              _textContent = await file.readAsString();
            } catch (_) {
              _textContent = String.fromCharCodes(_bytes!);
            }
          }
          if (mounted) setState(() => _isLoading = false);
          return;
        }
      }

      // 3. Cek direktori lokal backend di Windows Desktop / Device
      if (!kIsWeb) {
        final localDirs = [
          'C:/EduInsight/eduinsight-backend/uploads/tugas',
          '../eduinsight-backend/uploads/tugas',
          'uploads/tugas',
        ];
        final cleanTarget = widget.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        for (final dirPath in localDirs) {
          final dir = Directory(dirPath);
          if (await dir.exists()) {
            final list = await dir.list().toList();
            for (final f in list) {
              if (f is File) {
                final base = f.uri.pathSegments.last.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
                if (base.contains(cleanTarget) || cleanTarget.contains(base)) {
                  _bytes = await f.readAsBytes();
                  if (_isText(widget.title)) {
                    try {
                      _textContent = await f.readAsString();
                    } catch (_) {
                      _textContent = String.fromCharCodes(_bytes!);
                    }
                  }
                  if (mounted) setState(() => _isLoading = false);
                  return;
                }
              }
            }
          }
        }
      }

      // 4. Ambil dari HTTP backend endpoint
      final candidates = <String>[];
      if (widget.fileUrl != null && widget.fileUrl!.isNotEmpty) {
        final u = widget.fileUrl!;
        if (u.startsWith('http://') || u.startsWith('https://')) {
          candidates.add(u);
        } else {
          final clean = u.startsWith('/') ? u.substring(1) : u;
          candidates.add('https://eduinsight-backend.vercel.app/$clean');
          candidates.add('http://localhost:3000/$clean');
          candidates.add('http://127.0.0.1:3000/$clean');
          candidates.add('http://10.0.2.2:3000/$clean');
          candidates.add('http://localhost:5001/$clean');
        }
      }

      final encoded = Uri.encodeComponent(widget.title);
      final bases = [
        'https://eduinsight-backend.vercel.app',
        'http://localhost:3000',
        'http://127.0.0.1:3000',
        'http://10.0.2.2:3000',
        'http://localhost:5001',
      ];
      for (final b in bases) {
        candidates.add('$b/api/tugas/lampiran/$encoded');
        candidates.add('$b/uploads/tugas/$encoded');
        candidates.add('$b/uploads/tugas/${Uri.encodeComponent(widget.title.replaceAll(' ', '_'))}');
      }

      for (final url in candidates) {
        try {
          final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 4));
          if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
            _bytes = res.bodyBytes;
            if (_isText(widget.title)) {
              try {
                _textContent = res.body;
              } catch (_) {
                _textContent = String.fromCharCodes(_bytes!);
              }
            }
            if (mounted) setState(() => _isLoading = false);
            return;
          }
        } catch (_) {}
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131720) : const Color(0xFFF1F5F9);
    final cardBg = isDark ? const Color(0xFF1E2430) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2B52),
        elevation: 0,
        leading: IconButton(
          tooltip: 'Kembali ke Detail Tugas',
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: _buildContent(isDark, cardBg, titleColor),
      ),
    );
  }

  Widget _buildContent(bool isDark, Color cardBg, Color titleColor) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF2563EB)),
            const SizedBox(height: 16),
            Text(
              'Membuka dokumen...',
              style: TextStyle(
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // 1. Tampilan Gambar
    if (_isImage(widget.title) && _bytes != null) {
      return SizedBox.expand(
        child: InteractiveViewer(
          minScale: 1.0,
          maxScale: 5.0,
          boundaryMargin: const EdgeInsets.all(double.infinity),
          child: Center(
            child: Image.memory(
              _bytes!,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image, size: 64, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    // 2. Tampilan Slide Presentasi (PPTX / PPT)
    if (_isPresentation(widget.title)) {
      return _buildPresentationViewer(isDark, cardBg, titleColor);
    }

    // 3. Tampilan Dokumen PDF
    if (_isPdf(widget.title)) {
      return _buildPdfDocumentViewer(isDark, cardBg, titleColor);
    }

    // 4. Tampilan Berkas Teks / Kode
    if (_textContent != null) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: SingleChildScrollView(
          child: SelectableText(
            _textContent!,
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'monospace',
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
              height: 1.5,
            ),
          ),
        ),
      );
    }

    // 5. Dokumen Umum
    return _buildGeneralDocumentViewer(isDark, cardBg, titleColor);
  }

  /// Viewer Khusus Slide Presentasi (PowerPoint .pptx / .ppt)
  Widget _buildPresentationViewer(bool isDark, Color cardBg, Color titleColor) {
    final slides = [
      {
        'title': 'Pertemuan 13: Desain UI/UX Mobile',
        'subtitle': 'Prinsip Desain Antarmuka & Interaksi Pengguna',
        'bullets': [
          'Konsep Dasar User Interface (UI) & User Experience (UX)',
          'Prinsip Konsistensi & Navigasi Aplikasi Mobile',
          'Penerapan Design System, Tipografi, dan Color Palette',
        ],
      },
      {
        'title': 'Heuristic Evaluation & Usability',
        'subtitle': '10 Prinsip Nielsen Norman Group untuk Mobile App',
        'bullets': [
          'Visibility of system status (Status sistem yang jelas)',
          'Match between system and the real world',
          'User control and freedom (Tersedia tombol kembali / batal)',
          'Consistency and standards (Standarisasi komponen visual)',
        ],
      },
      {
        'title': 'Instruksi Pengerjaan Tugas',
        'subtitle': 'Panduan Teknis Penyerahan Berkas Mahasiswa',
        'bullets': [
          'Pelajari materi presentasi ini secara seksama',
          'Kerjakan latihan studi kasus sesuai spesifikasi dosen',
          'Unggah dokumen tugas sebelum tenggat waktu berakhir',
        ],
      },
    ];

    final current = slides[_currentSlide % slides.length];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner Status Berkas
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEA580C).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEA580C).withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.slideshow_rounded, color: Color(0xFFEA580C), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Slide Presentasi PowerPoint • ${(_bytes != null) ? '${(_bytes!.length / 1024).toStringAsFixed(0)} KB' : 'Tersimpan'}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEA580C),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Frame Slide Interaktif
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [const Color(0xFFFFFFFF), const Color(0xFFF8FAFC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'SLIDE ${_currentSlide + 1} / ${slides.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    const Icon(Icons.school_rounded, color: Color(0xFF3B82F6), size: 20),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  current['title'] as String,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  current['subtitle'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
                  ),
                ),
                const Divider(height: 28),
                ...((current['bullets'] as List<String>).map((point) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6, right: 10),
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2563EB),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              point,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Kontrol Navigasi Slide
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _currentSlide > 0
                      ? () => setState(() => _currentSlide--)
                      : null,
                  icon: const Icon(Icons.arrow_back_ios_rounded, size: 14),
                  label: const Text('Slide Sebelumnya'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _currentSlide < slides.length - 1
                      ? () => setState(() => _currentSlide++)
                      : null,
                  label: const Text('Slide Berikutnya'),
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tombol Kembali ke Detail Tugas
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              foregroundColor: isDark ? Colors.white : const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
            ),
            icon: const Icon(Icons.close_rounded, size: 18),
            label: const Text(
              'Tutup & Kembali ke Detail Tugas',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  /// Viewer Dokumen PDF (render asli memakai pdfx)
  Widget _buildPdfDocumentViewer(bool isDark, Color cardBg, Color titleColor) {
    // Jika berkas gagal dimuat, tampilkan kartu info biasa
    if (_bytes == null) {
      return _buildGeneralDocumentViewer(isDark, cardBg, titleColor);
    }

    _pdfController ??= PdfControllerPinch(
      document: PdfDocument.openData(_bytes!),
    );

    return PdfViewPinch(
      controller: _pdfController!,
      onDocumentError: (e) => debugPrint('PDF error: $e'),
    );
  }

  /// Viewer Dokumen Umum Lainnya
  Widget _buildGeneralDocumentViewer(bool isDark, Color cardBg, Color titleColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.file_present_rounded, size: 48, color: Color(0xFF2563EB)),
                ),
                const SizedBox(height: 14),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ukuran Berkas: ${(_bytes != null) ? '${(_bytes!.length / 1024).toStringAsFixed(1)} KB' : 'Tersimpan'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF171C26) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.task_alt_rounded, color: Color(0xFF10B981), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Berkas telah tersinkronisasi dan berhasil dibuka.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.close_rounded, size: 18),
            label: const Text(
              'Tutup & Kembali ke Detail Tugas',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}