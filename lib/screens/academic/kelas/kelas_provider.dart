import 'dart:convert';
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
  static const _prefFiles = 'kelas_files_json';
  static const _prefCancelled = 'kelas_cancelled';

  /// Pemisah beberapa nama file saat disimpan ke kolom file_name SQLite
  static const _sep = '||';

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

  // Dokumen yang dipilih user per tugas (key -> daftar nama file)
  final Map<String, List<String>> _files = {};

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
    _cancelled.addAll(prefs.getStringList(_prefCancelled) ?? []);

    // Daftar dokumen per tugas (JSON)
    final rawFiles = prefs.getString(_prefFiles);
    if (rawFiles != null && rawFiles.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawFiles);
        if (decoded is Map) {
          decoded.forEach((k, v) {
            if (v is List) {
              final names = v.map((e) => e.toString()).toList();
              if (names.isNotEmpty) _files[k.toString()] = names;
            }
          });
        }
      } catch (_) {
        // abaikan data rusak
      }
    }

    // Muat data dari SQLite Drift (pengumpulan_tugas)
    try {
      final dbList = await AppDb.instance.getAllPengumpulan();
      for (final row in dbList) {
        final key = '${row['class_name']}|${row['task_title']}';
        final status = row['status'];
        final fileName = row['file_name'];

        // Cadangan: kalau daftar dokumen belum ada, ambil dari SQLite
        if (fileName != null &&
            fileName.isNotEmpty &&
            (_files[key] == null || _files[key]!.isEmpty)) {
          _files[key] = fileName
              .split(_sep)
              .where((e) => e.trim().isNotEmpty)
              .toList();
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
      await prefs.setStringList(_prefCancelled, _cancelled.toList());
      await prefs.setString(_prefFiles, jsonEncode(_files));
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

  /// Daftar dokumen untuk ditampilkan.
  /// Tugas bawaan yang sudah selesai memakai nama contoh.
  List<String> filesFor(String key) {
    final list = _files[key];
    if (list != null && list.isNotEmpty) return List.unmodifiable(list);
    if (_initiallyCompleted.contains(key)) return [mockFileName(key)];
    return const [];
  }

  bool hasDoc(String key) => filesFor(key).isNotEmpty;

  /// Ditandai selesai tanpa dokumen (bukan penyerahan dengan file)
  bool isMarkedOnly(String key) =>
      _userCompleted.contains(key) && (_files[key]?.isEmpty ?? true);

  /// Jumlah tugas selesai (konsisten dengan daftar yang ditampilkan)
  int get selesaiCount => countByStatus(TaskStatus.selesai);

  // ─────────────────────────────────────────
  // AKSI DOKUMEN
  // ─────────────────────────────────────────

  /// Tambah satu dokumen ke draft tugas. false kalau nama sudah ada.
  bool addDoc(String key, String fileName) {
    final list = _files.putIfAbsent(key, () => []);
    if (list.contains(fileName)) return false;
    list.add(fileName);

    notifyListeners(); // UI semua halaman langsung update
    _syncDraftToDb(key);
    _persist();
    return true;
  }

  /// Hapus satu dokumen dari draft tugas (tombol silang)
  void removeDoc(String key, String fileName) {
    final list = _files[key];
    if (list == null) return;
    list.remove(fileName);
    if (list.isEmpty) _files.remove(key);

    notifyListeners();
    _syncDraftToDb(key);
    _persist();
  }

  /// Tambah banyak dokumen sekaligus. Mengembalikan jumlah yang benar-benar baru.
  int addFiles(String key, List<String> names) {
    final list = _files.putIfAbsent(key, () => []);
    var added = 0;
    for (final n in names) {
      if (n.isNotEmpty && !list.contains(n)) {
        list.add(n);
        added++;
      }
    }
    if (list.isEmpty) _files.remove(key);

    if (added > 0) {
      notifyListeners(); // UI semua halaman langsung update
      _syncDraftToDb(key);
      _persist();
    }
    return added;
  }

  /// Nama lain dari removeDoc (dipakai tombol silang di Detail Tugas)
  void removeFile(String key, String fileName) => removeDoc(key, fileName);

  void _syncDraftToDb(String key) {
    final parts = key.split('|');
    if (parts.length < 2) return;
    final joined = (_files[key] ?? const <String>[]).join(_sep);
    // joined kosong = tidak ada dokumen lagi
    _db(() => AppDb.instance.saveDraftDoc(parts[0], parts[1], joined));
  }

  /// Kompatibilitas nama lama: menambah dokumen
  void uploadDocOnly(String key, {String? fileName}) {
    if (fileName != null && fileName.isNotEmpty) addDoc(key, fileName);
  }

  // ─────────────────────────────────────────
  // AKSI PENYERAHAN
  // ─────────────────────────────────────────

  /// SERAHKAN TUGAS (butuh minimal satu dokumen)
  void serahkanTugas(String key) {
    final files = _files[key];
    if (files == null || files.isEmpty) {
      markComplete(key); // tanpa dokumen = tandai selesai
      return;
    }

    _userCompleted.add(key);
    _lateTasks.remove(key);
    _cancelled.remove(key);

    notifyListeners(); // UI semua halaman langsung update

    final parts = key.split('|');
    if (parts.length >= 2) {
      _db(() => AppDb.instance.serahkanTugas(
            parts[0],
            parts[1],
            fileName: files.join(_sep),
            isLate: false,
          ));
    }
    _persist();
  }

  /// Legacy helper: tambah dokumen lalu langsung serahkan
  void uploadDoc(String key, {String? fileName}) {
    uploadDocOnly(key, fileName: fileName);
    serahkanTugas(key);
  }

  /// TANDAI SELESAI (tanpa dokumen)
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