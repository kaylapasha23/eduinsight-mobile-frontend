import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'kelas_screen.dart';
import '../../../services/academic_api_service.dart';

/// Keys are formatted as "ClassName|TaskTitle"
class KelasProvider extends ChangeNotifier {
  static const _prefUserCompleted = 'kelas_user_completed';
  static const _prefLateTasks = 'kelas_late_tasks';

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

  // Tasks that have a document uploaded
  final Set<String> _docUploaded = {};

  KelasProvider() {
    _loadPersistedState();
    syncWithBackend();
  }

  bool get isLoading => _isLoading;
  List<TaskItem> get dynamicTasks => _dynamicTasks;

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
          if (item['category'] == 'selesai') {
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

  /// Load persisted state dari SharedPreferences
  Future<void> _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();

    final savedCompleted = prefs.getStringList(_prefUserCompleted) ?? [];
    _userCompleted.addAll(savedCompleted);

    final savedLate = prefs.getStringList(_prefLateTasks) ?? [];
    _lateTasks.addAll(savedLate);

    // Sync: hapus dari _initiallyCompleted kalau sudah diunsubmit
    for (final key in _lateTasks) {
      _initiallyCompleted.remove(key);
    }
    for (final key in _userCompleted) {
      _initiallyCompleted.remove(key); // user-completed override initial state jika ada unsubmit
    }

    notifyListeners();
  }

  /// Simpan state ke SharedPreferences
  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefUserCompleted, _userCompleted.toList());
    await prefs.setStringList(_prefLateTasks, _lateTasks.toList());
  }

  Set<String> get completedKeys => {..._initiallyCompleted, ..._userCompleted};

  bool isCompleted(String key) => completedKeys.contains(key);
  bool isLate(String key) => _lateTasks.contains(key);
  bool hasDoc(String key) =>
      _docUploaded.contains(key) ||
      _initiallyCompleted.contains(key) ||
      _userCompleted.contains(key);

  int get selesaiCount => completedKeys.length;

  void uploadDoc(String key) {
    _docUploaded.add(key);
    _userCompleted.add(key);
    _lateTasks.remove(key);
    _persist();
    notifyListeners();
  }

  void markComplete(String key) {
    _userCompleted.add(key);
    _lateTasks.remove(key);
    _persist();
    notifyListeners();
  }

  /// Saat unsubmit (Batalkan Pengiriman):
  /// Jika tugas yang diunsub sudah lewat deadline → ditandai terlambat.
  /// Jika belum lewat deadline → kembali ke kategori segera.
  void cancelSubmission(String key, {bool isPastDeadline = false}) {
    _initiallyCompleted.remove(key);
    _userCompleted.remove(key);
    _docUploaded.remove(key);

    if (isPastDeadline || _isKeyPastDeadline(key)) {
      _lateTasks.add(key);
    } else {
      _lateTasks.remove(key);
    }

    _persist();
    notifyListeners();
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