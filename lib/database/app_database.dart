import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// Tabel = kelas Dart yang meng-extend Table
class CompletedTasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get className => text()();
  TextColumn get title => text()();
  IntColumn get completedAt => integer()(); // UTC millis

  @override
  List<Set<Column>> get uniqueKeys => [
        {className, title},
      ];
}

@DriftDatabase(tables: [CompletedTasks])
class AppDb extends _$AppDb {
  AppDb()
    : super(
        driftDatabase(
          name: 'eduinsight',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  static final AppDb instance = AppDb();

  @override
  int get schemaVersion => 1;

  // Stream: berubah otomatis tiap tabel berubah
  Stream<List<CompletedTask>> watchCompleted() =>
      (select(completedTasks)
            ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
          .watch();

  // Tambah tugas yang diserahkan
  Future<int> addCompleted(String className, String title) =>
      into(completedTasks).insert(
        CompletedTasksCompanion.insert(
          className: className,
          title: title,
          completedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
        ),
        mode: InsertMode.insertOrIgnore,
      );

  // Batalkan penyerahan
  Future<int> removeCompleted(String className, String title) =>
      (delete(completedTasks)
            ..where((t) => t.className.equals(className) & t.title.equals(title)))
          .go();

  // ══════════════════════════════════════════════════════════════════
  // TABEL SQLITE DRIFT UNTUK KEHADIRAN & NILAI (OFFLINE CACHE / SYNC)
  // ══════════════════════════════════════════════════════════════════

  Future<void> initAcademicTables() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS kehadiran_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        matkul_name TEXT NOT NULL,
        matkul_jadwal TEXT NOT NULL,
        nomor INTEGER NOT NULL,
        topik TEXT NOT NULL,
        tanggal TEXT NOT NULL,
        status TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      );
    ''');

    await customStatement('''
      CREATE TABLE IF NOT EXISTS nilai_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        semester_judul TEXT NOT NULL,
        tahun_ajaran TEXT NOT NULL,
        ips REAL NOT NULL,
        total_sks INTEGER NOT NULL,
        matkul_nomor INTEGER NOT NULL,
        matkul_nama TEXT NOT NULL,
        matkul_kode TEXT NOT NULL,
        matkul_sks INTEGER NOT NULL,
        matkul_grade TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      );
    ''');

    await customStatement('''
      CREATE TABLE IF NOT EXISTS pengumpulan_tugas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        class_name TEXT NOT NULL,
        task_title TEXT NOT NULL,
        file_name TEXT,
        file_path TEXT,
        status TEXT NOT NULL, -- 'draft', 'diserahkan', 'terlambat'
        submitted_at INTEGER,
        created_at INTEGER NOT NULL,
        UNIQUE(class_name, task_title)
      );
    ''');
  }

  // ─── PENGUMPULAN TUGAS SQLITE OPERATIONS ───

  /// Simpan draft dokumen lampiran tugas (belum diserahkan)
  Future<void> saveDraftDoc(String className, String taskTitle, String fileName, {String? filePath}) async {
    await initAcademicTables();
    final now = DateTime.now().millisecondsSinceEpoch;
    await customStatement('''
      INSERT INTO pengumpulan_tugas (class_name, task_title, file_name, file_path, status, submitted_at, created_at)
      VALUES (?, ?, ?, ?, 'draft', NULL, ?)
      ON CONFLICT(class_name, task_title) DO UPDATE SET
        file_name = excluded.file_name,
        file_path = excluded.file_path,
        created_at = excluded.created_at;
    ''', [className, taskTitle, fileName, filePath, now]);
  }

  /// Serahkan tugas (mengubah status menjadi 'diserahkan' atau 'terlambat')
  Future<void> serahkanTugas(String className, String taskTitle, {String? fileName, bool isLate = false}) async {
    await initAcademicTables();
    final now = DateTime.now().millisecondsSinceEpoch;
    final status = isLate ? 'terlambat' : 'diserahkan';
    await customStatement('''
      INSERT INTO pengumpulan_tugas (class_name, task_title, file_name, status, submitted_at, created_at)
      VALUES (?, ?, ?, ?, ?, ?)
      ON CONFLICT(class_name, task_title) DO UPDATE SET
        status = excluded.status,
        submitted_at = excluded.submitted_at,
        file_name = COALESCE(excluded.file_name, pengumpulan_tugas.file_name);
    ''', [className, taskTitle, fileName, status, now, now]);
  }

  /// Batalkan penyerahan tugas (kembalikan ke status draft jika ada file, atau hapus)
  Future<void> batalkanPengumpulan(String className, String taskTitle) async {
    await initAcademicTables();
    await customStatement('''
      UPDATE pengumpulan_tugas
      SET status = 'draft', submitted_at = NULL
      WHERE class_name = ? AND task_title = ?;
    ''', [className, taskTitle]);
  }

  /// Ambil riwayat pengumpulan tugas berdasarkan class_name dan task_title
  Future<Map<String, dynamic>?> getPengumpulan(String className, String taskTitle) async {
    await initAcademicTables();
    final rows = await customSelect(
      'SELECT * FROM pengumpulan_tugas WHERE class_name = ? AND task_title = ? LIMIT 1',
      variables: [Variable.withString(className), Variable.withString(taskTitle)],
    ).get();

    if (rows.isEmpty) return null;
    final r = rows.first;
    return {
      'id': r.read<int>('id'),
      'class_name': r.read<String>('class_name'),
      'task_title': r.read<String>('task_title'),
      'file_name': r.readNullable<String>('file_name'),
      'file_path': r.readNullable<String>('file_path'),
      'status': r.read<String>('status'),
      'submitted_at': r.readNullable<int>('submitted_at'),
      'created_at': r.read<int>('created_at'),
    };
  }

  /// Ambil semua tugas yang sudah diserahkan dari SQLite
  Future<List<Map<String, dynamic>>> getAllPengumpulan() async {
    await initAcademicTables();
    final rows = await customSelect(
      'SELECT * FROM pengumpulan_tugas ORDER BY id DESC',
    ).get();

    return rows.map((r) => {
      'id': r.read<int>('id'),
      'class_name': r.read<String>('class_name'),
      'task_title': r.read<String>('task_title'),
      'file_name': r.readNullable<String>('file_name'),
      'file_path': r.readNullable<String>('file_path'),
      'status': r.read<String>('status'),
      'submitted_at': r.readNullable<int>('submitted_at'),
      'created_at': r.read<int>('created_at'),
    }).toList();
  }

  // ─── KEHADIRAN SQLITE OPERATIONS ───

  Future<void> saveKehadiranToDrift(List<Map<String, dynamic>> matkulList) async {
    await initAcademicTables();
    await customStatement('DELETE FROM kehadiran_cache');

    final now = DateTime.now().millisecondsSinceEpoch;
    for (final mk in matkulList) {
      final String matkulName = mk['nama'] ?? '';
      final String jadwal = mk['jadwal'] ?? '';
      final List riwayat = mk['riwayat'] as List? ?? [];

      for (final p in riwayat) {
        await customInsert(
          'INSERT INTO kehadiran_cache (matkul_name, matkul_jadwal, nomor, topik, tanggal, status, updated_at) '
          'VALUES (?, ?, ?, ?, ?, ?, ?)',
          variables: [
            Variable.withString(matkulName),
            Variable.withString(jadwal),
            Variable.withInt(p['nomor'] ?? 0),
            Variable.withString(p['topik'] ?? ''),
            Variable.withString(p['tanggal'] ?? ''),
            Variable.withString(p['status'] ?? 'Hadir'),
            Variable.withInt(now),
          ],
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> getKehadiranFromDrift() async {
    await initAcademicTables();
    final rows = await customSelect(
      'SELECT * FROM kehadiran_cache ORDER BY matkul_name ASC, nomor DESC',
    ).get();

    if (rows.isEmpty) return [];

    final Map<String, Map<String, dynamic>> grouped = {};
    for (final row in rows) {
      final name = row.read<String>('matkul_name');
      final jadwal = row.read<String>('matkul_jadwal');

      grouped.putIfAbsent(name, () => {
        'nama': name,
        'jadwal': jadwal,
        'riwayat': <Map<String, dynamic>>[],
      });

      (grouped[name]!['riwayat'] as List<Map<String, dynamic>>).add({
        'nomor': row.read<int>('nomor'),
        'topik': row.read<String>('topik'),
        'tanggal': row.read<String>('tanggal'),
        'status': row.read<String>('status'),
      });
    }

    return grouped.values.toList();
  }

  // ─── NILAI SQLITE OPERATIONS ───

  Future<void> saveNilaiToDrift(List<Map<String, dynamic>> semesterList) async {
    await initAcademicTables();
    await customStatement('DELETE FROM nilai_cache');

    final now = DateTime.now().millisecondsSinceEpoch;
    for (final s in semesterList) {
      final String judul = s['judul'] ?? '';
      final String tahunAjaran = s['tahunAjaran'] ?? '';
      final double ips = (s['ips'] as num?)?.toDouble() ?? 0.0;
      final int totalSks = s['totalSks'] ?? 0;
      final List matkul = s['matkul'] as List? ?? [];

      for (final m in matkul) {
        await customInsert(
          'INSERT INTO nilai_cache (semester_judul, tahun_ajaran, ips, total_sks, matkul_nomor, matkul_nama, matkul_kode, matkul_sks, matkul_grade, updated_at) '
          'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          variables: [
            Variable.withString(judul),
            Variable.withString(tahunAjaran),
            Variable.withReal(ips),
            Variable.withInt(totalSks),
            Variable.withInt(m['nomor'] ?? 0),
            Variable.withString(m['nama'] ?? ''),
            Variable.withString(m['kode'] ?? ''),
            Variable.withInt(m['sks'] ?? 0),
            Variable.withString(m['grade'] ?? 'A'),
            Variable.withInt(now),
          ],
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> getNilaiFromDrift() async {
    await initAcademicTables();
    final rows = await customSelect(
      'SELECT * FROM nilai_cache ORDER BY id ASC',
    ).get();

    if (rows.isEmpty) return [];

    final Map<String, Map<String, dynamic>> grouped = {};
    for (final row in rows) {
      final judul = row.read<String>('semester_judul');
      final tahun = row.read<String>('tahun_ajaran');
      final ips = row.read<double>('ips');
      final totalSks = row.read<int>('total_sks');

      grouped.putIfAbsent(judul, () => {
        'judul': judul,
        'tahunAjaran': tahun,
        'ips': ips,
        'totalSks': totalSks,
        'matkul': <Map<String, dynamic>>[],
      });

      (grouped[judul]!['matkul'] as List<Map<String, dynamic>>).add({
        'nomor': row.read<int>('matkul_nomor'),
        'nama': row.read<String>('matkul_nama'),
        'kode': row.read<String>('matkul_kode'),
        'sks': row.read<int>('matkul_sks'),
        'grade': row.read<String>('matkul_grade'),
      });
    }

    return grouped.values.toList();
  }
}
