import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'kelas_screen.dart';
import '../../../services/academic_api_service.dart';
import '../../../database/app_database.dart';

enum TaskStatus { segera, terlambat, selesai }

/// Keys are formatted as "ClassName|TaskTitle"
class KelasProvider extends ChangeNotifier {
  static const _prefUserCompleted = 'kelas_user_completed';
  static const _prefLateTasks = 'kelas_late_tasks';
  static const _prefDocUploaded = 'kelas_doc_uploaded';
  static const _prefCancelled = 'kelas_cancelled';

  // Dynamic backend tasks
  List<TaskItem> _dynamicTasks = [];
  bool _isLoading = false;

  // Tasks that are initially "selesai" (pre-submitted default tasks)
  final Set<String> _initiallyCompleted = {
    'Kecerdasan Buatan|Tugas Pengenalan AI',
    'Basis Data|Latihan SQL Dasar',
    'Pemrograman Web|Tugas Array & Function',
    'Internet of Things (IoT)|Laporan Praktikum 1',
    'UI/UX|CBL 2: Low-Fidelity',
    'Statistika dan Data|Quizziz Matriks',
    'Kecerdasan Buatan|AI Klasik dan Modern',
    'Pemrograman Web|Tipe Data dan Method',
    'Internet of Things (IoT)|Pertemuan Pertama IoT',
    'Pemrograman Web|Pertemuan Pertama Pemweb',
    'Sistem Informasi|Pertemuan Pertama Sistem Informasi',
  };

  // Tasks the user manually marked as selesai
  final Set<String> _userCompleted = {};

  // Tasks that are unsubmitted and considered late (terlambat)
  final Set<String> _lateTasks = {};

  // Tasks yang pernah dibatalkan user (supaya tidak "hidup lagi" dari data awal/backend)
  final Set<String> _cancelled = {};

  // Tasks that have a document uploaded
  final Set<String> _docUploaded = {};

  // Nama file asli yang dipilih user dari perangkat (key -> nama file)
  final Map<String, String> _uploadedFileNames = {};

  KelasProvider() {
    _init();
  }

  /// Urutan penting: muat state lokal dulu, baru sinkron backend
  Future<void> _init() async {
    await _loadPersistedState();
    await syncWithBackend();
  }

  bool get isLoading => _isLoading;
  List<TaskItem> get dynamicTasks => _dynamicTasks;

  /// Daftar tugas yang dipakai SEMUA halaman (backend, atau data default)
  List<TaskItem> get allTasks => _dynamicTasks.isNotEmpty
      ? _dynamicTasks
      : [...allSegeraTasks, ...allSelesaiTasks];

  // ─────────────────────────────────────────
  // STATUS TUNGGAL (dipakai semua halaman)
  // ─────────────────────────────────────────

  static String keyOf(TaskItem t) => '${t.className}|${t.title}';

  TaskStatus statusOf(String key) {
    if (isCompleted(key)) return TaskStatus.selesai;
    if (isLate(key)) return TaskStatus.terlambat;
    return TaskStatus.segera;
  }

  List<TaskItem> tasksByStatus(TaskStatus s) =>
      allTasks.where((t) => statusOf(keyOf(t)) == s).toList();

  int countByStatus(TaskStatus s) => tasksByStatus(s).length;

  /// Tugas "Segera" berikutnya untuk satu mata kuliah (null kalau tidak ada)
  TaskItem? nextTaskFor(String className) {
    for (final t in allTasks) {
      if (t.className == className && statusOf(keyOf(t)) == TaskStatus.segera) {
        return t;
      }
    }
    return null;
  }

  // ─────────────────────────────────────────
  // LOAD / SYNC
  // ─────────────────────────────────────────

  /// Load tasks from Backend API
  Future<void> syncWithBackend() async {
    _isLoading = true;
    notifyListeners();

    try {
      final list = await AcademicApiService.fetchTugas();
      if (list != null && list.isNotEmpty) {
        _dynamicTasks = list.map((item) {
          final title = item['title']?.toString() ?? 'Tugas';
          final className = item['class_name']?.toString() ?? 'Mata Kuliah';
          final deadline = item['deadline_text']?.toString() ?? 'Hari ini, 23.59';
          final category = item['category']?.toString() ?? 'segera';
          return TaskItem(
            title,
            className,
            deadline,
            className,
            isDefaultPastDeadline: category == 'selesai' || category == 'terlambat',
          );
        }).toList();

        for (final item in list) {
          final key = '${item['class_name']}|${item['title']}';
          // Jangan hidupkan lagi tugas yang sudah dibatalkan user
          if (item['category'] == 'selesai' && !_cancelled.contains(key)) {
            _initiallyCompleted.add(key);
          }
        }
      }
    } catch (_) {
      // offline fallback
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load persisted state dari SQLite Drift dan SharedPreferences
  Future<void> _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();

    _userCompleted.addAll(prefs.getStringList(_prefUserCompleted) ?? []);
    _lateTasks.addAll(prefs.getStringList(_prefLateTasks) ?? []);
    _docUploaded.addAll(prefs.getStringList(_prefDocUploaded) ?? []);
    _cancelled.addAll(prefs.getStringList(_prefCancelled) ?? []);

    // Muat data dari SQLite Drift (pengumpulan_tugas)
    try {
      final dbList = await AppDb.instance.getAllPengumpulan();
      for (final row in dbList) {
        final key = '${row['class_name']}|${row['task_title']}';
        final status = row['status'];
        final fileName = row['file_name'];

        if (fileName != null && fileName.isNotEmpty) {
          _uploadedFileNames[key] = fileName;
          _docUploaded.add(key);
        }

        if (status == 'diserahkan') {
          _userCompleted.add(key);
          _lateTasks.remove(key);
          _cancelled.remove(key);
        } else if (status == 'terlambat') {
          _lateTasks.add(key);
        }
      }
    } catch (e) {
      debugPrint('Drift belum siap (abaikan di web): $e');
    }

    // Sync: tugas yang dibatalkan / terlambat tidak boleh dianggap selesai awal
    for (final key in _cancelled) {
      _initiallyCompleted.remove(key);
    }
    for (final key in _lateTasks) {
      _initiallyCompleted.remove(key);
    }
    for (final key in _userCompleted) {
      _initiallyCompleted.remove(key);
    }

    notifyListeners();
  }

  /// Simpan state ke SharedPreferences
  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefUserCompleted, _userCompleted.toList());
      await prefs.setStringList(_prefLateTasks, _lateTasks.toList());
      await prefs.setStringList(_prefDocUploaded, _docUploaded.toList());
      await prefs.setStringList(_prefCancelled, _cancelled.toList());
    } catch (e) {
      debugPrint('Gagal menyimpan state: $e');
    }
  }

  /// Jalankan operasi database tanpa pernah merusak UI.
  /// Kalau Drift error (mis. belum disetup di web), UI tetap sinkron.
  void _db(Future<void> Function() action) {
    try {
      action().catchError((Object e) {
        debugPrint('DB error: $e');
      });
    } catch (e) {
      debugPrint('DB error: $e');
    }
  }

  // ─────────────────────────────────────────
  // GETTER
  // ─────────────────────────────────────────

  Set<String> get completedKeys => {..._initiallyCompleted, ..._userCompleted};

  bool isCompleted(String key) => completedKeys.contains(key);
  bool isLate(String key) => _lateTasks.contains(key);
  bool hasDoc(String key) =>
      _docUploaded.contains(key) ||
      _initiallyCompleted.contains(key) ||
      _userCompleted.contains(key);

  /// Ditandai selesai tanpa dokumen (bukan penyerahan dengan file)
  bool isMarkedOnly(String key) =>
      _userCompleted.contains(key) && !_docUploaded.contains(key);

  /// Jumlah tugas selesai (konsisten dengan daftar yang ditampilkan)
  int get selesaiCount => countByStatus(TaskStatus.selesai);

  /// Nama file untuk ditampilkan: file asli yang diunggah, atau nama mock
  String fileNameFor(String key) => _uploadedFileNames[key] ?? mockFileName(key);

  // ─────────────────────────────────────────
  // AKSI
  // ─────────────────────────────────────────

  /// 1. UNGGAH DOKUMEN SAJA (Draft ke SQLite, belum diserahkan)
  void uploadDocOnly(String key, {String? fileName}) {
    if (fileName != null && fileName.isNotEmpty) {
      _uploadedFileNames[key] = fileName;
    }
    _docUploaded.add(key);

    notifyListeners(); // UI semua halaman langsung update

    final parts = key.split('|');
    if (parts.length >= 2) {
      _db(() => AppDb.instance
          .saveDraftDoc(parts[0], parts[1], fileName ?? 'Tugas.pdf'));
    }
    _persist();
  }

  /// 2. SERAHKAN TUGAS (Simpan status 'diserahkan' ke SQLite Drift)
  void serahkanTugas(String key) {
    _userCompleted.add(key);
    _lateTasks.remove(key);
    _cancelled.remove(key);

    notifyListeners(); // UI semua halaman langsung update

    final parts = key.split('|');
    if (parts.length >= 2) {
      final fileName = _uploadedFileNames[key];
      _db(() => AppDb.instance.serahkanTugas(
            parts[0],
            parts[1],
            fileName: fileName,
            isLate: false,
          ));
    }
    _persist();
  }

  /// Legacy helper uploadDoc (sekarang serahkan tugas langsung jika dipanggil)
  void uploadDoc(String key, {String? fileName}) {
    uploadDocOnly(key, fileName: fileName);
    serahkanTugas(key);
  }

  /// TANDAI SELESAI (tanpa dokumen). Kalau sudah ada dokumen, pakai serahkanTugas.
  void markComplete(String key) {
    _userCompleted.add(key);
    _lateTasks.remove(key);
    _cancelled.remove(key);

    notifyListeners(); // UI semua halaman langsung update

    final parts = key.split('|');
    if (parts.length >= 2) {
      _db(() => AppDb.instance.serahkanTugas(
            parts[0],
            parts[1],
            fileName: null,
            isLate: false,
          ));
    }
    _persist();
  }

  /// Saat unsubmit (Batalkan Pengiriman):
  /// Jika tugas yang diunsub sudah lewat deadline → ditandai terlambat.
  /// Jika belum lewat deadline → kembali ke kategori segera.
  void cancelSubmission(String key, {bool isPastDeadline = false}) {
    _initiallyCompleted.remove(key);
    _userCompleted.remove(key);
    _cancelled.add(key);
    // dokumen draft tetap ada jika user ingin menyerahkan kembali

    if (isPastDeadline || _isKeyPastDeadline(key)) {
      _lateTasks.add(key);
    } else {
      _lateTasks.remove(key);
    }

    notifyListeners(); // UI semua halaman langsung update

    final parts = key.split('|');
    if (parts.length >= 2) {
      _db(() => AppDb.instance.batalkanPengumpulan(parts[0], parts[1]));
    }
    _persist();
  }

  bool _isKeyPastDeadline(String key) {
    if (key.contains('Latihan SQL') ||
        key.contains('Array & Function') ||
        key.contains('Laporan Praktikum 1') ||
        key.contains('Pengenalan AI') ||
        key.contains('CBL 2') ||
        key.contains('Matriks') ||
        key.contains('AI Klasik')) {
      return true;
    }
    return false;
  }

  String mockFileName(String key) {
    if (key.contains('Quizziz') || key.contains('Quiziz')) return 'Screenshot_Skor.png';
    if (key.contains('Low-Fidelity') || key.contains('Analisa')) return 'Laporan_Analisa_UIUX.pdf';
    if (key.contains('JavaScript') || key.contains('Array')) return 'Tugas_Array_Function.zip';
    if (key.contains('Node.js') || key.contains('CRUD')) return 'Dokumen_CRUD_Pemweb.pdf';
    if (key.contains('SQL')) return 'Query_Praktikum_BasisData.sql';
    if (key.contains('AI')) return 'Tugas_Pengenalan_AI.pdf';
    if (key.contains('IoT') || key.contains('ESP32') || key.contains('Praktikum')) {
      return 'Laporan_Sensor_ESP32.pdf';
    }
    return 'Dokumen_Tugas_Mahasiswa.pdf';
  }
}