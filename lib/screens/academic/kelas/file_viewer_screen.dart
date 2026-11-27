import 'dart:convert';
import 'dart:io' show File, Directory;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Halaman penampil file (berkas dosen & mahasiswa), satu file untuk semua platform.
///
/// - PDF     -> pdfx (Android, iOS, Web)
/// - Office  -> WebView Office Online (butuh URL publik https)
/// - Gambar  -> dirender langsung dari bytes
/// - Teks    -> dirender langsung dari bytes
///
/// Syarat di web:
///  1. web/index.html berisi skrip pdf.js (lihat panduan).
///  2. pubspec.yaml punya `webview_flutter_web`.
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
  static const _backendBase = 'https://eduinsight-backend.vercel.app';
  static const _timeout = Duration(seconds: 10);

  bool _isLoading = true;
  Uint8List? _bytes;
  String? _textContent;
  PdfControllerPinch? _pdfController;
  WebViewController? _webController;

  /// URL absolut untuk dibuka di tab baru / aplikasi lain.
  String? _externalUrl;

  /// Log percobaan pemuatan (ditampilkan saat gagal).
  final List<String> _attempts = [];

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

  // ───────────────────────── Deteksi tipe ─────────────────────────

  bool _isImage(String n) {
    final l = n.toLowerCase();
    return l.endsWith('.png') ||
        l.endsWith('.jpg') ||
        l.endsWith('.jpeg') ||
        l.endsWith('.webp') ||
        l.endsWith('.gif') ||
        l.endsWith('.bmp');
  }

  bool _isOffice(String n) {
    final l = n.toLowerCase();
    return l.endsWith('.ppt') ||
        l.endsWith('.pptx') ||
        l.endsWith('.doc') ||
        l.endsWith('.docx') ||
        l.endsWith('.xls') ||
        l.endsWith('.xlsx');
  }

  bool _isPdf(String n) => n.toLowerCase().endsWith('.pdf');

  bool _isText(String n) {
    final l = n.toLowerCase();
    return l.endsWith('.txt') ||
        l.endsWith('.sql') ||
        l.endsWith('.json') ||
        l.endsWith('.py') ||
        l.endsWith('.js') ||
        l.endsWith('.dart') ||
        l.endsWith('.html') ||
        l.endsWith('.css') ||
        l.endsWith('.csv') ||
        l.endsWith('.md');
  }

  bool get _hasRemoteUrl {
    final u = widget.fileUrl;
    return u != null && (u.startsWith('http://') || u.startsWith('https://'));
  }

  bool get _hasLocalPath =>
      widget.localFilePath != null && widget.localFilePath!.isNotEmpty;

  /// URL publik (https, bukan localhost) yang bisa dibaca Office Online.
  String? get _publicUrl {
    final u = _externalUrl;
    if (u == null || !u.startsWith('https://')) return null;
    if (u.contains('localhost') || u.contains('127.0.0.1') || u.contains('10.0.2.2')) {
      return null;
    }
    return u;
  }

  // ───────────────────────── Util ─────────────────────────

  /// Server kadang membalas 200 tapi isinya HTML error, bukan file asli.
  bool _looksValid(Uint8List data) {
    if (data.isEmpty) return false;
    if (_isPdf(widget.title)) {
      return String.fromCharCodes(data.take(1024)).contains('%PDF-');
    }
    return true;
  }

  void _setBytes(Uint8List data) {
    _bytes = data;
    if (_isText(widget.title)) {
      _textContent = utf8.decode(data, allowMalformed: true);
    }
  }

  // ───────────────────────── Pemuatan ─────────────────────────

  Future<void> _loadFile() async {
    setState(() {
      _isLoading = true;
      _bytes = null;
      _textContent = null;
      _attempts.clear();
    });
    _pdfController?.dispose();
    _pdfController = null;
    _webController = null;

    debugPrint('VIEWER INIT: title=${widget.title}, url=${widget.fileUrl}, '
        'local=${widget.localFilePath}, bytes=${widget.fileBytes?.length}, web=$kIsWeb');

    // URL absolut cadangan
    final raw = widget.fileUrl;
    if (_hasRemoteUrl) {
      _externalUrl = raw;
    } else if (raw != null && raw.isNotEmpty) {
      _externalUrl = '$_backendBase/${raw.startsWith('/') ? raw.substring(1) : raw}';
    }

    try {
      final hasLocal =
          (widget.fileBytes != null && widget.fileBytes!.isNotEmpty) || _hasLocalPath;

      // 0. Office + URL publik: cukup render lewat Office Online, tanpa unduh.
      if (_isOffice(widget.title) && !hasLocal && _publicUrl != null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // 1. Bytes dari memori
      if (widget.fileBytes != null && widget.fileBytes!.isNotEmpty) {
        _setBytes(widget.fileBytes!);
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      _attempts.add('Memori: tidak ada bytes');

      // 2. Path lokal (non-web)
      if (_hasLocalPath && !kIsWeb) {
        final file = File(widget.localFilePath!);
        if (await file.exists()) {
          _setBytes(await file.readAsBytes());
          if (mounted) setState(() => _isLoading = false);
          return;
        }
        _attempts.add('Path lokal tidak ditemukan: ${widget.localFilePath}');
      } else {
        _attempts.add('Path lokal: tidak ada${kIsWeb ? ' (web)' : ''}');
      }

      // 3. Folder backend lokal (desktop, debug)
      if (!kIsWeb && kDebugMode && !_hasRemoteUrl) {
        final dirs = [
          'C:/EduInsight/eduinsight-backend/uploads/tugas',
          '../eduinsight-backend/uploads/tugas',
          'uploads/tugas',
        ];
        final target =
            widget.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        for (final d in dirs) {
          final dir = Directory(d);
          if (await dir.exists()) {
            for (final f in await dir.list().toList()) {
              if (f is File) {
                final base = f.uri.pathSegments.last
                    .toLowerCase()
                    .replaceAll(RegExp(r'[^a-z0-9]'), '');
                if (base.contains(target) || target.contains(base)) {
                  _setBytes(await f.readAsBytes());
                  if (mounted) setState(() => _isLoading = false);
                  return;
                }
              }
            }
          }
        }
      }

      // 4. HTTP
      final candidates = <String>[];
      if (raw != null && raw.isNotEmpty) {
        if (_hasRemoteUrl) {
          candidates.add(raw);
        } else {
          final clean = raw.startsWith('/') ? raw.substring(1) : raw;
          candidates.add('$_backendBase/$clean');
          if (kDebugMode) {
            candidates.add('http://localhost:5001/$clean');
            candidates.add('http://localhost:3000/$clean');
            candidates.add('http://127.0.0.1:3000/$clean');
            if (!kIsWeb) candidates.add('http://10.0.2.2:3000/$clean');
          }
        }
      } else {
        _attempts.add('fileUrl kosong/null (pemanggil tidak mengirim URL)');
        final enc = Uri.encodeComponent(widget.title);
        final bases = <String>[
          _backendBase,
          if (kDebugMode) ...[
            'http://localhost:5001',
            'http://localhost:3000',
          ],
        ];
        for (final b in bases) {
          candidates.add('$b/api/tugas/lampiran/$enc');
          candidates.add('$b/uploads/tugas/$enc');
        }
      }

      for (final url in candidates) {
        try {
          final res = await http.get(Uri.parse(url)).timeout(_timeout);
          debugPrint('VIEWER: $url -> ${res.statusCode} (${res.bodyBytes.length} B)');
          if (res.statusCode == 200 && _looksValid(res.bodyBytes)) {
            _externalUrl = url;
            _setBytes(res.bodyBytes);
            if (mounted) setState(() => _isLoading = false);
            return;
          }
          _attempts.add(res.statusCode == 200
              ? '$url -> 200 tapi isinya bukan ${_isPdf(widget.title) ? 'PDF' : 'berkas valid'}'
              : '$url -> ${res.statusCode}');
        } catch (e) {
          debugPrint('VIEWER ERROR: $url -> $e');
          if (e is http.ClientException) {
            _attempts.add('$url -> gagal${kIsWeb ? ' (kemungkinan CORS)' : ''}');
          } else if (e.toString().contains('TimeoutException')) {
            _attempts.add('$url -> timeout ${_timeout.inSeconds} dtk (server tidak merespons)');
          } else {
            _attempts.add('$url -> gagal: ${e.runtimeType}');
          }
        }
      }
    } catch (e) {
      debugPrint('VIEWER FATAL: $e');
      _attempts.add('Error tak terduga: $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // ───────────────────────── Buka eksternal ─────────────────────────

  Future<void> _openExternally() async {
    final messenger = ScaffoldMessenger.of(context);

    if (!kIsWeb) {
      String? path = widget.localFilePath;
      if ((path == null || path.isEmpty || !File(path).existsSync()) &&
          _bytes != null) {
        final dir = await getTemporaryDirectory();
        final f = File('${dir.path}/${widget.title}');
        await f.writeAsBytes(_bytes!);
        path = f.path;
      }
      if (path != null && path.isNotEmpty) {
        await OpenFilex.open(path);
        return;
      }
    }

    if (_externalUrl != null) {
      final ok = await launchUrl(
        Uri.parse(_externalUrl!),
        mode: LaunchMode.externalApplication,
      );
      if (ok) return;
    }

    messenger.showSnackBar(
      const SnackBar(
        content: Text('Berkas belum tersedia untuk dibuka.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ───────────────────────── UI ─────────────────────────

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
        actions: [
          if (_externalUrl != null || _bytes != null || _hasLocalPath)
            IconButton(
              tooltip: kIsWeb ? 'Buka di tab baru' : 'Buka dengan aplikasi HP',
              icon: const Icon(Icons.open_in_new_rounded, color: Colors.white),
              onPressed: _openExternally,
            ),
        ],
      ),
      body: SafeArea(child: _buildContent(isDark, cardBg, titleColor)),
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

    // 1. Gambar
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

    // 2. Office
    if (_isOffice(widget.title)) {
      return _buildOfficeViewer(isDark, cardBg, titleColor);
    }

    // 3. PDF
    if (_isPdf(widget.title)) {
      return _buildPdfDocumentViewer(isDark, cardBg, titleColor);
    }

    // 4. Teks / kode
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

    // 5. Umum
    return _buildGeneralDocumentViewer(isDark, cardBg, titleColor);
  }

  /// URL yang ditampilkan lewat WebView (iframe di web), tanpa perlu mengunduh bytes.
  /// - Office : Office Online
  /// - PDF    : web -> URL langsung (viewer PDF bawaan browser)
  ///            mobile -> Google Docs viewer (WebView Android tidak bisa render PDF)
  String? get _embedUrl {
    final pub = _publicUrl;
    if (pub == null) return null;
    if (_isOffice(widget.title)) {
      return 'https://view.officeapps.live.com/op/embed.aspx?src=${Uri.encodeComponent(pub)}';
    }
    if (_isPdf(widget.title)) {
      return kIsWeb
          ? pub
          : 'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(pub)}';
    }
    return null;
  }

  Widget _buildWebEmbed(String url) {
    _webController ??= WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));

    return Column(
      children: [
        Expanded(child: WebViewWidget(controller: _webController!)),
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _openExternally,
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: Text(
                kIsWeb ? 'Buka di tab baru' : 'Buka dengan aplikasi HP',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Office: WebView Office Online untuk URL publik.
  Widget _buildOfficeViewer(bool isDark, Color cardBg, Color titleColor) {
    final hasLocal = _bytes != null || _hasLocalPath;
    final url = _embedUrl;
    if (url != null && !hasLocal) return _buildWebEmbed(url);
    return _buildGeneralDocumentViewer(isDark, cardBg, titleColor);
  }

  /// PDF: pdfx jika bytes berhasil diunduh, kalau gagal jatuh ke WebView.
  Widget _buildPdfDocumentViewer(bool isDark, Color cardBg, Color titleColor) {
    if (_bytes == null) {
      final url = _embedUrl;
      if (url != null) return _buildWebEmbed(url);
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

  /// Kartu info + diagnosis, tampil hanya kalau berkas tidak bisa dirender.
  Widget _buildGeneralDocumentViewer(bool isDark, Color cardBg, Color titleColor) {
    final loaded = _bytes != null;
    final canOpen = loaded || _hasLocalPath || _externalUrl != null;
    final subColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final panelBg = isDark ? const Color(0xFF171C26) : const Color(0xFFF8FAFC);

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
                  child: const Icon(Icons.file_present_rounded,
                      size: 48, color: Color(0xFF2563EB)),
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
                  loaded
                      ? 'Ukuran Berkas: ${(_bytes!.length / 1024).toStringAsFixed(1)} KB'
                      : 'Berkas tidak berhasil dimuat dari server.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: subColor),
                ),
                if (!loaded && _attempts.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: panelBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SelectableText(
                      'Detail:\n${_attempts.join('\n')}',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: subColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (canOpen)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: Text(
                kIsWeb ? 'Buka di tab baru' : 'Buka dengan aplikasi HP',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              onPressed: _openExternally,
            ),
          if (!loaded) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                side: const BorderSide(color: Color(0xFF2563EB)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'Coba lagi',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              onPressed: _loadFile,
            ),
          ],
          const SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
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
}