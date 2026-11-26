import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../../services/academic_api_service.dart';
import 'kelas_provider.dart';
import 'kelas_screen.dart' show TaskItem;

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
    // ignore: unused_element_parameter
    this.lecturerDocs = const [],
  });
}

const Map<String, _TaskDetail> _taskDetails = {};

class DetailTugasScreen extends StatefulWidget {
  final String taskTitle;
  final String className;
  final String? taskId;

  const DetailTugasScreen({
    super.key,
    required this.taskTitle,
    required this.className,
    this.taskId,
  });

  @override
  State<DetailTugasScreen> createState() => _DetailTugasScreenState();
}

class _DetailTugasScreenState extends State<DetailTugasScreen> {
  double? _sheetHeight;
  bool _isDragging = false;
  bool _isSubmitting = false;

  /// Buka dialog tautkan link eksternal (Figma, Drive, GitHub, dll)
  Future<void> _showAddLinkDialog(KelasProvider kelas, String key) async {
    final controller = TextEditingController(text: kelas.linkFor(key) ?? '');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF252D3A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Tautkan Link Tugas',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masukkan tautan Google Drive, Figma (Board / Prototype), GitHub Repository, atau link tugas lainnya:',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText: 'https://...',
                hintStyle: TextStyle(
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final text = controller.text.trim();
              Navigator.pop(ctx, text);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result != null) {
      kelas.setLink(key, result.isEmpty ? null : result);
    }
  }

  /// Buka tautan eksternal (Figma / Google Drive / GitHub / URL berkas) di browser / viewer HP
  Future<void> _launchExternalUrl(String rawUrl) async {
    final messenger = ScaffoldMessenger.of(context);
    final normalized = rawUrl.startsWith('http://') || rawUrl.startsWith('https://')
        ? rawUrl
        : 'https://$rawUrl';
    final uri = Uri.tryParse(normalized);
    if (uri == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Format tautan tidak valid.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka tautan di perangkat ini.'),
            backgroundColor: Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Gagal membuka tautan: $e'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Resolusi URL publik berkas tugas yang sudah tersimpan di server/Cloudinary
  String? _resolveRemoteFileUrl(KelasProvider kelas, String key) {
    final raw = kelas.submittedFileUrlFor(key);
    final subId = kelas.submissionIdFor(key);
    final origin = AcademicApiService.productionBaseUrl.replaceAll(RegExp(r'/api/?$'), '');
    if (raw != null && raw.isNotEmpty) {
      if (raw.startsWith('http://') || raw.startsWith('https://')) {
        return raw;
      }
      return '$origin${raw.startsWith('/') ? raw : '/$raw'}';
    }
    if (subId != null && subId.isNotEmpty) {
      return '${AcademicApiService.productionBaseUrl}/pengumpulan-tugas/$subId/file';
    }
    return null;
  }

  /// Modal pratinjau untuk semua jenis media & dokumen (Gambar, Teks/Kode, PDF, Video, Audio, Office, Arsip)
  Future<void> _openFilePreview(
    KelasProvider kelas,
    String key,
    String fileName,
  ) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
    final localFile = kelas.platformFileFor(key, fileName);
    final remoteUrl = _resolveRemoteFileUrl(kelas, key);

    final isImage = ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp'].contains(ext);
    final isText = ['txt', 'csv', 'json', 'sql', 'py', 'js', 'ts', 'html', 'css', 'dart', 'md', 'xml'].contains(ext);
    final isPdf = ext == 'pdf';
    final isVideo = ['mp4', 'mov', 'mkv', 'avi', 'webm'].contains(ext);
    final isAudio = ['mp3', 'wav', 'm4a', 'aac', 'ogg'].contains(ext);

    Uint8List? localBytes;
    if (localFile != null && (isImage || isText)) {
      try {
        localBytes = await localFile.readAsBytes();
      } catch (_) {}
    }

    String? textContent;
    if (isText) {
      if (localBytes != null) {
        textContent = utf8.decode(localBytes, allowMalformed: true);
      } else if (remoteUrl != null) {
        try {
          final res = await http.get(Uri.parse(remoteUrl)).timeout(const Duration(seconds: 8));
          if (res.statusCode == 200) {
            textContent = utf8.decode(res.bodyBytes, allowMalformed: true);
          }
        } catch (_) {}
      }
    }

    if (!mounted) return;

    // Untuk PDF yang di-host di Cloudinary /image/upload/, kita bisa menampilkan pratinjau gambar halaman 1
    String? cloudinaryPdfThumb;
    if (isPdf && remoteUrl != null && remoteUrl.contains('res.cloudinary.com') && remoteUrl.contains('/image/upload/') && remoteUrl.toLowerCase().endsWith('.pdf')) {
      cloudinaryPdfThumb = '${remoteUrl.substring(0, remoteUrl.length - 4)}.jpg';
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final modalBg = isDark ? const Color(0xFF1E2532) : Colors.white;
        final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
        final subColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

        return Container(
          height: MediaQuery.of(ctx).size.height * 0.78,
          decoration: BoxDecoration(
            color: modalBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Pratinjau
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 12, 12),
                child: Row(
                  children: [
                    Icon(_iconForExt(ext), color: _colorForExt(ext), size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: titleColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Pratinjau ${_labelForExt(ext)}',
                            style: TextStyle(fontSize: 11, color: subColor),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: subColor),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),

              // Konten Pratinjau
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: isImage
                      ? Center(
                          child: InteractiveViewer(
                            minScale: 0.8,
                            maxScale: 4.0,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: localBytes != null
                                  ? Image.memory(localBytes, fit: BoxFit.contain)
                                  : (remoteUrl != null
                                      ? Image.network(
                                          remoteUrl,
                                          fit: BoxFit.contain,
                                          loadingBuilder: (_, child, progress) => progress == null
                                              ? child
                                              : const Center(child: CircularProgressIndicator()),
                                          errorBuilder: (_, __, ___) => Text(
                                            'Gagal memuat pratinjau gambar.',
                                            style: TextStyle(color: subColor),
                                          ),
                                        )
                                      : Text('Gambar belum tersedia.', style: TextStyle(color: subColor))),
                            ),
                          ),
                        )
                      : isText && textContent != null
                          ? Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: SingleChildScrollView(
                                child: SelectableText(
                                  textContent.length > 15000
                                      ? '${textContent.substring(0, 15000)}\n\n... (terpotong)'
                                      : textContent,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                    height: 1.5,
                                    color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                            )
                          : (cloudinaryPdfThumb != null
                              ? Center(
                                  child: InteractiveViewer(
                                    minScale: 0.8,
                                    maxScale: 3.5,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.network(
                                        cloudinaryPdfThumb,
                                        fit: BoxFit.contain,
                                        loadingBuilder: (_, child, progress) => progress == null
                                            ? child
                                            : const Center(child: CircularProgressIndicator()),
                                        errorBuilder: (_, __, ___) => _genericPreviewPlaceholder(
                                          ext: ext,
                                          fileName: fileName,
                                          isVideo: isVideo,
                                          isAudio: isAudio,
                                          hasRemoteUrl: remoteUrl != null,
                                          isDark: isDark,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : _genericPreviewPlaceholder(
                                  ext: ext,
                                  fileName: fileName,
                                  isVideo: isVideo,
                                  isAudio: isAudio,
                                  hasRemoteUrl: remoteUrl != null,
                                  isDark: isDark,
                                )),
                ),
              ),

              // Tombol Aksi Bawah (Buka Full di Viewer HP / Browser)
              if (remoteUrl != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: Text(
                      isPdf
                          ? 'Buka PDF Lengkap di Browser / Viewer'
                          : isVideo
                              ? 'Putar Video'
                              : isAudio
                                  ? 'Putar Audio'
                                  : 'Buka / Unduh Berkas',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    onPressed: () => _launchExternalUrl(remoteUrl),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _genericPreviewPlaceholder({
    required String ext,
    required String fileName,
    required bool isVideo,
    required bool isAudio,
    required bool hasRemoteUrl,
    required bool isDark,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: _colorForExt(ext).withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(_iconForExt(ext), size: 52, color: _colorForExt(ext)),
            ),
            const SizedBox(height: 16),
            Text(
              fileName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasRemoteUrl
                  ? 'Ketuk tombol di bawah untuk membuka ${isVideo ? 'video' : isAudio ? 'audio' : 'dokumen'} ini menggunakan aplikasi viewer bawaan HP.'
                  : 'Berkas siap diserahkan. Setelah klik "Serahkan", berkas ini juga bisa dibuka penuh kapan saja lewat cloud.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForExt(String ext) {
    if (ext == 'pdf') return Icons.picture_as_pdf_rounded;
    if (['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp'].contains(ext)) return Icons.image_rounded;
    if (['mp4', 'mov', 'mkv', 'avi', 'webm'].contains(ext)) return Icons.videocam_rounded;
    if (['mp3', 'wav', 'm4a', 'aac', 'ogg'].contains(ext)) return Icons.audiotrack_rounded;
    if (['xls', 'xlsx', 'csv'].contains(ext)) return Icons.table_chart_rounded;
    if (['ppt', 'pptx'].contains(ext)) return Icons.slideshow_rounded;
    if (['zip', 'rar', '7z', 'tar', 'gz'].contains(ext)) return Icons.folder_zip_rounded;
    if (['sql', 'json', 'py', 'js', 'ts', 'html', 'css', 'dart'].contains(ext)) return Icons.code_rounded;
    return Icons.description_rounded;
  }

  Color _colorForExt(String ext) {
    if (ext == 'pdf') return const Color(0xFFEF4444);
    if (['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp'].contains(ext)) return const Color(0xFF14B8A6);
    if (['mp4', 'mov', 'mkv', 'avi', 'webm'].contains(ext)) return const Color(0xFF9333EA);
    if (['mp3', 'wav', 'm4a', 'aac', 'ogg'].contains(ext)) return const Color(0xFF6366F1);
    if (['xls', 'xlsx', 'csv'].contains(ext)) return const Color(0xFF10B981);
    if (['ppt', 'pptx'].contains(ext)) return const Color(0xFFF59E0B);
    if (['zip', 'rar', '7z', 'tar', 'gz'].contains(ext)) return const Color(0xFF64748B);
    return const Color(0xFF2563EB);
  }

  String _labelForExt(String ext) {
    if (ext == 'pdf') return 'Dokumen PDF';
    if (['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp'].contains(ext)) return 'Gambar';
    if (['mp4', 'mov', 'mkv', 'avi', 'webm'].contains(ext)) return 'Video';
    if (['mp3', 'wav', 'm4a', 'aac', 'ogg'].contains(ext)) return 'Audio';
    if (['xls', 'xlsx', 'csv'].contains(ext)) return 'Spreadsheet';
    if (['ppt', 'pptx'].contains(ext)) return 'Presentasi';
    if (['zip', 'rar', '7z', 'tar', 'gz'].contains(ext)) return 'Arsip';
    return 'Berkas (${ext.toUpperCase()})';
  }

  /// Buka pemilih file perangkat, mendukung dokumen, media, arsip, spreadsheet, dll
  Future<void> _pickAndUpload(KelasProvider kelas, String key) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          // Dokumen, Spreadsheet, Presentasi
          'pdf', 'doc', 'docx', 'xls', 'xlsx', 'csv', 'ppt', 'pptx', 'txt', 'rtf',
          // Arsip
          'zip', 'rar', '7z', 'tar', 'gz',
          // Gambar
          'jpg', 'jpeg', 'png', 'webp', 'gif', 'svg', 'bmp',
          // Video
          'mp4', 'mov', 'mkv', 'avi', 'webm',
          // Audio
          'mp3', 'wav', 'm4a', 'aac', 'ogg',
          // Kode / Basis Data
          'sql', 'json', 'py', 'js', 'html', 'css',
        ],
      );

      if (files.isEmpty) return; // user batal

      const maxBytes = 25 * 1024 * 1024; // 25 MB per file
      final List<PlatformFile> validFiles = [];

      for (final file in files) {
        final size = file.lengthSync() ?? await file.length() ?? 0;
        if (size > maxBytes) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                  'File "${file.name}" melebihi batas 25 MB dan dilewati.'),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (file.name.isNotEmpty) {
          validFiles.add(file);
        }
      }

      if (validFiles.isEmpty) return;

      final added = kelas.addPlatformFiles(key, validFiles);
      messenger.showSnackBar(
        SnackBar(
          content: Text(added == 0
              ? 'File tersebut sudah ditambahkan sebelumnya.'
              : added == 1
                  ? '1 file siap dikumpulkan.'
                  : '$added file siap dikumpulkan.'),
          backgroundColor: added == 0
              ? const Color(0xFFF59E0B)
              : const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Gagal memilih file: $e'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Dialog konfirmasi sebelum menghapus file dari draft tugas
  Future<void> _confirmDeleteFile(
    KelasProvider kelas,
    String key,
    String fileName,
  ) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF252D3A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Hapus file?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'Yakin ingin menghapus "$fileName" dari tugas ini?',
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? const Color(0xFFCBD5E1)
                    : const Color(0xFF475569),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Hapus',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    kelas.removeFile(key, fileName);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('File "$fileName" dihapus.'),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final key = '${widget.className}|${widget.taskTitle}';
    final detail = _taskDetails[key];

    return Consumer<KelasProvider>(
      builder: (context, kelas, _) {
        // Cari tugas di dynamicTasks jika ada
        TaskItem? dynamicMatch;
        try {
          if (widget.taskId != null && widget.taskId!.isNotEmpty) {
            dynamicMatch = kelas.dynamicTasks.firstWhere((t) => t.id == widget.taskId);
          } else {
            dynamicMatch = kelas.dynamicTasks.firstWhere(
              (t) => (t.className == widget.className && t.title == widget.taskTitle) ||
                     t.title.toLowerCase() == widget.taskTitle.toLowerCase(),
            );
          }
        } catch (_) {}

        final resolvedTaskId = widget.taskId ?? dynamicMatch?.id;

        final classLabel = detail?.classLabel ?? dynamicMatch?.className ?? widget.className;
        final taskName = detail?.taskName ?? dynamicMatch?.title ?? widget.taskTitle;
        final description = detail?.description ??
            'Tugas perkuliahan semester berjalan. Silakan pelajari instruksi dan kumpulkan dokumen pekerjaan Anda.';
        final deadline = dynamicMatch?.status ?? detail?.deadline ?? 'Rabu, 23.59';
        final lecturerDocs = detail?.lecturerDocs ?? const <String>[];
        final isGraded = dynamicMatch?.isGraded ?? false;
        final score = dynamicMatch?.score;
        final isCompleted = kelas.isCompleted(key);
        final isLate = kelas.isLate(key);
        final fileList = kelas.filesFor(key);
        final hasDoc = fileList.isNotEmpty;
        final submittedLink = kelas.linkFor(key);
        final hasLink = submittedLink != null && submittedLink.isNotEmpty;

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
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF7F1D1D).withValues(alpha: 0.45)
                                              : const Color(0xFFEF4444).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: isDark
                                              ? Border.all(color: const Color(0xFFF87171))
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
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isGraded
                                              ? (isDark
                                                  ? const Color(0xFF1E3A8A).withValues(alpha: 0.4)
                                                  : const Color(0xFF2563EB).withValues(alpha: 0.1))
                                              : (isDark
                                                  ? const Color(0xFF334155).withValues(alpha: 0.4)
                                                  : const Color(0xFFF1F5F9)),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isGraded
                                                ? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB))
                                                : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isGraded ? Icons.grade_rounded : Icons.pending_actions_rounded,
                                              size: 14,
                                              color: isGraded
                                                  ? (isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB))
                                                  : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              isGraded ? 'Sudah Dinilai (${score?.toStringAsFixed(0) ?? score ?? 85})' : 'Belum Dinilai',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isGraded
                                                    ? (isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB))
                                                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
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
                                      if (kelas.isMarkedOnly(key))
                                        _markedChip(isDark)
                                      else ...[
                                        ...fileList.map((fn) => _docChip(
                                              fn,
                                              isDark,
                                              onTap: () => _openFilePreview(kelas, key, fn),
                                              onDelete: null,
                                            )),
                                        if (hasLink)
                                          _linkChip(
                                            submittedLink,
                                            isDark,
                                            onTap: () => _launchExternalUrl(submittedLink),
                                            onDelete: null,
                                          ),
                                      ],
                                      const SizedBox(height: 18),
                                      _fullWidthButton(
                                        kelas.isMarkedOnly(key)
                                            ? 'Batalkan Tanda Selesai'
                                            : 'Batalkan Pengiriman',
                                        color: const Color(0xFFEF4444),
                                        textColor: Colors.white,
                                        onTap: () async {
                                          kelas.cancelSubmission(key, taskId: resolvedTaskId);

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
                                      if (!hasDoc && !hasLink)
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
                                                  'Belum ada dokumen atau tautan link',
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
                                      else ...[
                                        ...fileList.map((fn) => _docChip(
                                              fn,
                                              isDark,
                                              onTap: () => _openFilePreview(kelas, key, fn),
                                              onDelete: () =>
                                                  _confirmDeleteFile(
                                                      kelas, key, fn),
                                            )),
                                        if (hasLink)
                                          _linkChip(
                                            submittedLink,
                                            isDark,
                                            onTap: () => _launchExternalUrl(submittedLink),
                                            onDelete: () => kelas.setLink(key, null),
                                          ),
                                      ],
                                      const SizedBox(height: 14),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _fullWidthButton(
                                              'Tambah File / Media',
                                              icon: Icons.upload_file_rounded,
                                              color: isDark
                                                  ? const Color(0xFF354258)
                                                  : const Color(0xFFEFF6FF),
                                              textColor: isDark
                                                  ? const Color(0xFFBFDBFE)
                                                  : const Color(0xFF2563EB),
                                              borderColor:
                                                  const Color(0xFF60A5FA),
                                              onTap: () =>
                                                  _pickAndUpload(kelas, key),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: _fullWidthButton(
                                              'Tautkan Link',
                                              icon: Icons.link_rounded,
                                              color: isDark
                                                  ? const Color(0xFF354258)
                                                  : const Color(0xFFF0FDF4),
                                              textColor: isDark
                                                  ? const Color(0xFF86EFAC)
                                                  : const Color(0xFF16A34A),
                                              borderColor:
                                                  const Color(0xFF4ADE80),
                                              onTap: () => _showAddLinkDialog(kelas, key),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      _isSubmitting
                                          ? const Padding(
                                              padding: EdgeInsets.symmetric(vertical: 12),
                                              child: Center(child: CircularProgressIndicator()),
                                            )
                                          : ((hasDoc || hasLink)
                                              ? _fullWidthButton(
                                                  'Serahkan',
                                                  color: const Color(0xFF2563EB),
                                                  textColor: Colors.white,
                                                  onTap: () async {
                                                    final messenger = ScaffoldMessenger.of(context);
                                                    setState(() => _isSubmitting = true);
                                                    final success = await kelas.serahkanTugas(
                                                      key,
                                                      taskId: resolvedTaskId,
                                                      linkRepo: submittedLink,
                                                    );
                                                    if (mounted) {
                                                      setState(() => _isSubmitting = false);
                                                      messenger.showSnackBar(
                                                        SnackBar(
                                                          content: Text(success
                                                              ? 'Tugas berhasil diunggah dan diserahkan!'
                                                              : 'Tugas diserahkan secara lokal.'),
                                                          backgroundColor: const Color(0xFF10B981),
                                                          behavior: SnackBarBehavior.floating,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                )
                                              : _fullWidthButton(
                                                  'Tandai Sebagai Selesai',
                                                  color: const Color(0xFF2563EB),
                                                  textColor: Colors.white,
                                                  onTap: () async {
                                                    final messenger = ScaffoldMessenger.of(context);
                                                    setState(() => _isSubmitting = true);
                                                    final success = await kelas.markComplete(key, taskId: resolvedTaskId);
                                                    if (mounted) {
                                                      setState(() => _isSubmitting = false);
                                                      messenger.showSnackBar(
                                                        SnackBar(
                                                          content: Text(success
                                                              ? 'Tugas berhasil ditandai selesai!'
                                                              : 'Tugas ditandai selesai secara lokal.'),
                                                          backgroundColor: const Color(0xFF10B981),
                                                          behavior: SnackBarBehavior.floating,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                )),
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

  Widget _docChip(
    String fileName,
    bool isDark, {
    VoidCallback? onTap,
    VoidCallback? onDelete,
  }) {
    final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
    final extColor = _colorForExt(ext);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
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
            Icon(
              _iconForExt(ext),
              color: extColor,
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
                    '${_labelForExt(ext)} • Ketuk untuk pratinjau',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? const Color(0xFF93C5FD)
                          : const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ),
            if (onDelete != null)
              IconButton(
                tooltip: 'Hapus lampiran',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.close_rounded,
                  color: isDark ? const Color(0xFFF87171) : const Color(0xFFEF4444),
                  size: 20,
                ),
                onPressed: onDelete,
              )
            else
              const Icon(
                Icons.visibility_rounded,
                color: Color(0xFF34D399),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _linkChip(
    String url,
    bool isDark, {
    required VoidCallback onTap,
    VoidCallback? onDelete,
  }) {
    final lower = url.toLowerCase();
    final String label = lower.contains('figma.com')
        ? 'Tautan Figma'
        : (lower.contains('drive.google.com') || lower.contains('docs.google.com'))
            ? 'Tautan Google Drive'
            : (lower.contains('github.com') || lower.contains('gitlab.com'))
                ? 'Repositori GitHub'
                : 'Tautan Link Tugas';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2E384D) : const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF3B82F6),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.link_rounded, color: Color(0xFF2563EB), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    url,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onDelete != null)
              IconButton(
                tooltip: 'Hapus tautan',
                icon: const Icon(Icons.close_rounded, size: 20),
                color: const Color(0xFFEF4444),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onDelete,
              )
            else
              const Icon(
                Icons.open_in_new_rounded,
                color: Color(0xFF34D399),
                size: 19,
              ),
          ],
        ),
      ),
    );
  }

  Widget _markedChip(bool isDark) {
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
            Icons.task_alt_rounded,
            color: Color(0xFF34D399),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ditandai selesai (tanpa dokumen)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? Colors.white
                    : const Color(0xFF0F172A),
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
    IconData? icon,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: textColor),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}