import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'kelas_screen.dart';
import '../../../services/academic_api_service.dart';
import '../../../database/app_database.dart';

enum TaskStatus { segera, terlambat, selesai }

/// Keys are formatted as "ClassName|TaskTitle"
class KelasProvider extends ChangeNotifier {
  static const _prefUserCompleted = 'kelas_user_completed';
  static const _prefLateTasks = 'kelas_late_tasks';
  static const _prefFiles = 'kelas_files_json';
  static const _prefLinks = 'kelas_links_json';
  static const _prefCancelled = 'kelas_cancelled';

  /// Pemisah beberapa nama file saat disimpan ke kolom file_name SQLite
  static const _sep = '||';

  // Dynamic backend tasks
  List<TaskItem> _dynamicTasks = [];
  bool _isLoading = false;

  // Tasks that are initially "selesai" - sekarang murni dari backend database
  final Set<String> _initiallyCompleted = {};

  // Tasks the user manually marked as selesai
  final Set<String> _userCompleted = {};

  // Tasks that are unsubmitted and considered late (terlambat)
  final Set<String> _lateTasks = {};

  // Tasks yang pernah dibatalkan user (supaya tidak "hidup lagi" dari data awal/backend)
  final Set<String> _cancelled = {};

  // Dokumen yang dipilih user per tugas (key -> daftar nama file)
  final Map<String, List<String>> _files = {};

  // Tautan link eksternal (Figma, Google Drive, GitHub, dll) per tugas
  final Map<String, String> _links = {};

  // URL remote untuk file submission
  final Map<String, List<String>> _fileUrls = {};

  // URL file & ID pengumpulan yang sudah tersimpan di server/Cloudinary untuk pratinjau di HP
  final Map<String, String> _submittedFileUrls = {};
  final Map<String, String> _submissionIds = {};

  // Data biner PlatformFile untuk diunggah ke Cloudinary/backend & preview lokal
  final Map<String, List<PlatformFile>> _platformFiles = {};

  Timer? _pollingTimer;

  KelasProvider() {
    _init();
  }

  /// Urutan penting: muat state lokal dulu, baru sinkron backend
  Future<void> _init() async {
    await _loadPersistedState();
    await syncWithBackend();
    // Polling ringan setiap 25 detik agar HP tetap lancar & hemat baterai
    _pollingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      syncWithBackend(isSilent: true);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  bool get isLoading => _isLoading;
  List<TaskItem> get dynamicTasks => _dynamicTasks;

  /// Daftar tugas yang dipakai SEMUA halaman (murni real-time dari backend dosen)
  List<TaskItem> get allTasks => _dynamicTasks;

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

  /// Reset seluruh state & cache tugas lokal saat ganti akun / logout agar data antar mahasiswa tidak tercampur
  Future<void> resetForUser({bool resync = false}) async {
    _dynamicTasks = [];
    _initiallyCompleted.clear();
    _userCompleted.clear();
    _lateTasks.clear();
    _cancelled.clear();
    _files.clear();
    _links.clear();
    _submittedFileUrls.clear();
    _submissionIds.clear();
    _platformFiles.clear();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefUserCompleted);
      await prefs.remove(_prefLateTasks);
      await prefs.remove(_prefFiles);
      await prefs.remove(_prefLinks);
      await prefs.remove(_prefCancelled);
    } catch (_) {}

    await AppDb.instance.clearAllUserCaches();
    notifyListeners();

    if (resync) {
      await syncWithBackend();
    }
  }

  /// Load tasks from Backend API
  Future<void> syncWithBackend({bool isSilent = false}) async {
    if (!isSilent) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final list = await AcademicApiService.fetchTugas();
      if (list != null) {
        _dynamicTasks = list.map((item) {
          final title = item['title']?.toString() ?? 'Tugas';
          final className = item['class_name']?.toString() ?? 'Mata Kuliah';
          final deadline = item['deadline_text']?.toString() ?? 'Hari ini, 23.59';
          final category = item['category']?.toString() ?? 'segera';
          final bool isGraded = item['is_graded'] == true || item['isGraded'] == true;
          final num? score = item['score'] ?? item['nilai'];
          final String? id = item['id']?.toString();
          final String? attachmentName = item['attachment_name']?.toString() ??
              item['lampiran_nama']?.toString() ??
              item['lampiran']?.toString();
          final String? attachmentUrl = item['attachment_url']?.toString() ??
              item['lampiran_url']?.toString() ??
              item['lampiranUrl']?.toString();
          final String? rawDeadline = item['deadline']?.toString() ??
              item['dueDate']?.toString() ??
              item['deadline_text']?.toString();

          return TaskItem(
            title,
            className,
            deadline,
            className,
            isDefaultPastDeadline: category == 'selesai' || category == 'terlambat',
            isGraded: isGraded,
            score: score,
            id: id,
            attachmentName: attachmentName,
            attachmentUrl: attachmentUrl,
            rawDeadline: rawDeadline,
          );
        }).toList();

        // Sinkronisasi status pengumpulan murni milik mahasiswa yang sedang login dari backend
        for (final item in list) {
          final key = '${item['class_name']}|${item['title']}';
          final mySub = item['mySubmission'];
          if (mySub is Map) {
            _userCompleted.add(key);
            _lateTasks.remove(key);
            _cancelled.remove(key);
            final fn = mySub['fileName']?.toString();
            final fu = mySub['fileUrl']?.toString();
            if (fn != null && fn.isNotEmpty) {
              _files[key] = [fn];
            } else {
              _files.remove(key);
            }
            final lr = mySub['linkRepo']?.toString().trim();
            if (lr != null && lr.isNotEmpty) {
              _links[key] = lr;
            } else {
              _links.remove(key);
            }
            final fu = mySub['fileUrl']?.toString().trim();
            if (fu != null && fu.isNotEmpty) {
              _submittedFileUrls[key] = fu;
            } else {
              _submittedFileUrls.remove(key);
            }
            final subId = mySub['id']?.toString().trim();
            if (subId != null && subId.isNotEmpty) {
              _submissionIds[key] = subId;
            } else {
              _submissionIds.remove(key);
            }
            if (fu != null && fu.isNotEmpty) {
              _fileUrls[key] = [fu];
            }
          } else {
            // Belum dikumpulkan oleh akun mahasiswa ini
            _userCompleted.remove(key);
            _initiallyCompleted.remove(key);
            _submittedFileUrls.remove(key);
            _submissionIds.remove(key);
            // Jangan hapus draft lokal jika mahasiswa baru saja memilih file sebelum klik serahkan
            if (_platformFiles[key] == null || _platformFiles[key]!.isEmpty) {
              _files.remove(key);
              _fileUrls.remove(key);
            }
          }
        }
        _persist();
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

    // Daftar tautan link per tugas (JSON)
    final rawLinks = prefs.getString(_prefLinks);
    if (rawLinks != null && rawLinks.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawLinks);
        if (decoded is Map) {
          decoded.forEach((k, v) {
            final link = v?.toString().trim() ?? '';
            if (link.isNotEmpty) _links[k.toString()] = link;
          });
        }
      } catch (_) {}
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
      await prefs.setString(_prefLinks, jsonEncode(_links));
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

  /// URL file yang tersimpan di backend (jika ada)
  List<String> fileUrlsFor(String key) {
    final list = _fileUrls[key];
    if (list != null && list.isNotEmpty) return List.unmodifiable(list);
    return const [];
  }

  /// PlatformFile yang baru saja dipilih di perangkat
  List<PlatformFile> platformFilesFor(String key) {
    final list = _platformFiles[key];
    if (list != null && list.isNotEmpty) return List.unmodifiable(list);
    return const [];
  }

  bool hasDoc(String key) => filesFor(key).isNotEmpty;

  String? linkFor(String key) => _links[key];
  bool hasLink(String key) => (_links[key] ?? '').trim().isNotEmpty;
  String? submittedFileUrlFor(String key) => _submittedFileUrls[key];
  String? submissionIdFor(String key) => _submissionIds[key];

  PlatformFile? platformFileFor(String key, String fileName) {
    final pList = _platformFiles[key];
    if (pList == null) return null;
    for (final f in pList) {
      if (f.name == fileName) return f;
    }
    return null;
  }

  /// Simpan atau hapus tautan link eksternal per tugas
  void setLink(String key, String? url) {
    final clean = url?.trim() ?? '';
    if (clean.isEmpty) {
      _links.remove(key);
    } else {
      _links[key] = clean;
    }
    notifyListeners();
    _persist();
  }

  /// Ditandai selesai tanpa dokumen DAN tanpa tautan link
  bool isMarkedOnly(String key) =>
      _userCompleted.contains(key) &&
      (_files[key]?.isEmpty ?? true) &&
      (_links[key]?.trim().isEmpty ?? true);

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

    final pList = _platformFiles[key];
    if (pList != null) {
      pList.removeWhere((f) => f.name == fileName);
      if (pList.isEmpty) _platformFiles.remove(key);
    }

    notifyListeners();
    _syncDraftToDb(key);
    _persist();
  }

  /// Tambah banyak dokumen PlatformFile sekaligus (menyimpan nama dan byte biner untuk upload)
  int addPlatformFiles(String key, List<PlatformFile> files) {
    final list = _files.putIfAbsent(key, () => []);
    final pList = _platformFiles.putIfAbsent(key, () => []);
    var added = 0;
    for (final f in files) {
      if (f.name.isNotEmpty && !list.contains(f.name)) {
        list.add(f.name);
        pList.add(f);
        added++;
      }
    }
    if (list.isEmpty) _files.remove(key);
    if (pList.isEmpty) _platformFiles.remove(key);

    if (added > 0) {
      notifyListeners();
      _syncDraftToDb(key);
      _persist();
    }
    return added;
  }

  /// Tambah banyak dokumen sekaligus (nama file string)
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

  /// SERAHKAN TUGAS (bisa berupa dokumen berkas, tautan link, atau keduanya)
  Future<bool> serahkanTugas(String key, {String? taskId, String? linkRepo}) async {
    final files = _files[key];
    final pFiles = _platformFiles[key];
    final effectiveLink = (linkRepo ?? _links[key])?.trim();

    if ((files == null || files.isEmpty) && (effectiveLink == null || effectiveLink.isEmpty)) {
      return markComplete(key, taskId: taskId); // tanpa dokumen / link = tandai selesai
    }

    if (effectiveLink != null && effectiveLink.isNotEmpty) {
      _links[key] = effectiveLink;
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
            fileName: files?.join(_sep),
            isLate: false,
          ));
    }
    _persist();

    // Resolusi Task ID
    String? resolvedId = taskId;
    if (resolvedId == null || resolvedId.isEmpty) {
      for (final t in _dynamicTasks) {
        if ('${t.className}|${t.title}' == key && t.id != null) {
          resolvedId = t.id;
          break;
        }
      }
      if (resolvedId == null && parts.length >= 2) {
        for (final t in _dynamicTasks) {
          if (t.title.toLowerCase() == parts[1].toLowerCase() && t.id != null) {
            resolvedId = t.id;
            break;
          }
        }
      }
    }

    if (resolvedId != null && resolvedId.isNotEmpty) {
      PlatformFile? primaryFile;
      if (pFiles != null && pFiles.isNotEmpty) {
        primaryFile = pFiles.first;
      }

      List<int>? fileBytes;
      if (primaryFile != null) {
        try {
          fileBytes = await primaryFile.readAsBytes();
        } catch (_) {}
      }

      final ok = await AcademicApiService.submitPengumpulan(
        taskId: resolvedId,
        fileName: primaryFile?.name ?? files?.firstOrNull,
        fileBytes: fileBytes,
        filePath: primaryFile?.path,
        linkRepo: effectiveLink,
      );
      if (ok) {
        // Tarik ulang metadata fileUrl (Cloudinary) & submissionId agar preview langsung tersedia
        unawaited(syncWithBackend(isSilent: true));
      }
      return ok;
    }
    return false;
  }

  /// Legacy helper: tambah dokumen lalu langsung serahkan
  void uploadDoc(String key, {String? fileName}) {
    uploadDocOnly(key, fileName: fileName);
    serahkanTugas(key);
  }

  /// TANDAI SELESAI (tanpa dokumen)
  Future<bool> markComplete(String key, {String? taskId}) async {
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

    // Resolusi Task ID
    String? resolvedId = taskId;
    if (resolvedId == null || resolvedId.isEmpty) {
      for (final t in _dynamicTasks) {
        if ('${t.className}|${t.title}' == key && t.id != null) {
          resolvedId = t.id;
          break;
        }
      }
      if (resolvedId == null && parts.length >= 2) {
        for (final t in _dynamicTasks) {
          if (t.title.toLowerCase() == parts[1].toLowerCase() && t.id != null) {
            resolvedId = t.id;
            break;
          }
        }
      }
    }

    if (resolvedId != null && resolvedId.isNotEmpty) {
      return await AcademicApiService.submitPengumpulan(
        taskId: resolvedId,
      );
    }
    return false;
  }

  /// Saat unsubmit (Batalkan Pengiriman):
  /// Jika tugas yang diunsub sudah lewat deadline → ditandai terlambat.
  /// Jika belum lewat deadline → kembali ke kategori segera.
  void cancelSubmission(String key, {bool isPastDeadline = false, String? taskId}) {
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

    // Hapus juga pengumpulan di database backend
    String? resolvedId = taskId;
    if (resolvedId == null || resolvedId.isEmpty) {
      for (final t in _dynamicTasks) {
        if ('${t.className}|${t.title}' == key && t.id != null) {
          resolvedId = t.id;
          break;
        }
      }
    }
    if (resolvedId != null && resolvedId.isNotEmpty) {
      AcademicApiService.deletePengumpulan(taskId: resolvedId);
    }
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