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
  AppDb() : super(driftDatabase(name: 'eduinsight'));

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
}