// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CompletedTasksTable extends CompletedTasks
    with TableInfo<$CompletedTasksTable, CompletedTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompletedTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _classNameMeta = const VerificationMeta(
    'className',
  );
  @override
  late final GeneratedColumn<String> className = GeneratedColumn<String>(
    'class_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, className, title, completedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'completed_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompletedTask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('class_name')) {
      context.handle(
        _classNameMeta,
        className.isAcceptableOrUnknown(data['class_name']!, _classNameMeta),
      );
    } else if (isInserting) {
      context.missing(_classNameMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {className, title},
  ];
  @override
  CompletedTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompletedTask(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      className: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_name'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $CompletedTasksTable createAlias(String alias) {
    return $CompletedTasksTable(attachedDatabase, alias);
  }
}

class CompletedTask extends DataClass implements Insertable<CompletedTask> {
  final int id;
  final String className;
  final String title;
  final int completedAt;
  const CompletedTask({
    required this.id,
    required this.className,
    required this.title,
    required this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['class_name'] = Variable<String>(className);
    map['title'] = Variable<String>(title);
    map['completed_at'] = Variable<int>(completedAt);
    return map;
  }

  CompletedTasksCompanion toCompanion(bool nullToAbsent) {
    return CompletedTasksCompanion(
      id: Value(id),
      className: Value(className),
      title: Value(title),
      completedAt: Value(completedAt),
    );
  }

  factory CompletedTask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompletedTask(
      id: serializer.fromJson<int>(json['id']),
      className: serializer.fromJson<String>(json['className']),
      title: serializer.fromJson<String>(json['title']),
      completedAt: serializer.fromJson<int>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'className': serializer.toJson<String>(className),
      'title': serializer.toJson<String>(title),
      'completedAt': serializer.toJson<int>(completedAt),
    };
  }

  CompletedTask copyWith({
    int? id,
    String? className,
    String? title,
    int? completedAt,
  }) => CompletedTask(
    id: id ?? this.id,
    className: className ?? this.className,
    title: title ?? this.title,
    completedAt: completedAt ?? this.completedAt,
  );
  CompletedTask copyWithCompanion(CompletedTasksCompanion data) {
    return CompletedTask(
      id: data.id.present ? data.id.value : this.id,
      className: data.className.present ? data.className.value : this.className,
      title: data.title.present ? data.title.value : this.title,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompletedTask(')
          ..write('id: $id, ')
          ..write('className: $className, ')
          ..write('title: $title, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, className, title, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompletedTask &&
          other.id == this.id &&
          other.className == this.className &&
          other.title == this.title &&
          other.completedAt == this.completedAt);
}

class CompletedTasksCompanion extends UpdateCompanion<CompletedTask> {
  final Value<int> id;
  final Value<String> className;
  final Value<String> title;
  final Value<int> completedAt;
  const CompletedTasksCompanion({
    this.id = const Value.absent(),
    this.className = const Value.absent(),
    this.title = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  CompletedTasksCompanion.insert({
    this.id = const Value.absent(),
    required String className,
    required String title,
    required int completedAt,
  }) : className = Value(className),
       title = Value(title),
       completedAt = Value(completedAt);
  static Insertable<CompletedTask> custom({
    Expression<int>? id,
    Expression<String>? className,
    Expression<String>? title,
    Expression<int>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (className != null) 'class_name': className,
      if (title != null) 'title': title,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  CompletedTasksCompanion copyWith({
    Value<int>? id,
    Value<String>? className,
    Value<String>? title,
    Value<int>? completedAt,
  }) {
    return CompletedTasksCompanion(
      id: id ?? this.id,
      className: className ?? this.className,
      title: title ?? this.title,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (className.present) {
      map['class_name'] = Variable<String>(className.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompletedTasksCompanion(')
          ..write('id: $id, ')
          ..write('className: $className, ')
          ..write('title: $title, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $CompletedTasksTable completedTasks = $CompletedTasksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [completedTasks];
}

typedef $$CompletedTasksTableCreateCompanionBuilder =
    CompletedTasksCompanion Function({
      Value<int> id,
      required String className,
      required String title,
      required int completedAt,
    });
typedef $$CompletedTasksTableUpdateCompanionBuilder =
    CompletedTasksCompanion Function({
      Value<int> id,
      Value<String> className,
      Value<String> title,
      Value<int> completedAt,
    });

class $$CompletedTasksTableFilterComposer
    extends Composer<_$AppDb, $CompletedTasksTable> {
  $$CompletedTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get className => $composableBuilder(
    column: $table.className,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CompletedTasksTableOrderingComposer
    extends Composer<_$AppDb, $CompletedTasksTable> {
  $$CompletedTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get className => $composableBuilder(
    column: $table.className,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompletedTasksTableAnnotationComposer
    extends Composer<_$AppDb, $CompletedTasksTable> {
  $$CompletedTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get className =>
      $composableBuilder(column: $table.className, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$CompletedTasksTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $CompletedTasksTable,
          CompletedTask,
          $$CompletedTasksTableFilterComposer,
          $$CompletedTasksTableOrderingComposer,
          $$CompletedTasksTableAnnotationComposer,
          $$CompletedTasksTableCreateCompanionBuilder,
          $$CompletedTasksTableUpdateCompanionBuilder,
          (
            CompletedTask,
            BaseReferences<_$AppDb, $CompletedTasksTable, CompletedTask>,
          ),
          CompletedTask,
          PrefetchHooks Function()
        > {
  $$CompletedTasksTableTableManager(_$AppDb db, $CompletedTasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompletedTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompletedTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompletedTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> className = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> completedAt = const Value.absent(),
              }) => CompletedTasksCompanion(
                id: id,
                className: className,
                title: title,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String className,
                required String title,
                required int completedAt,
              }) => CompletedTasksCompanion.insert(
                id: id,
                className: className,
                title: title,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CompletedTasksTable, CompletedTask>(table),
                  BaseReferences<_$AppDb, $CompletedTasksTable, CompletedTask>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CompletedTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $CompletedTasksTable,
      CompletedTask,
      $$CompletedTasksTableFilterComposer,
      $$CompletedTasksTableOrderingComposer,
      $$CompletedTasksTableAnnotationComposer,
      $$CompletedTasksTableCreateCompanionBuilder,
      $$CompletedTasksTableUpdateCompanionBuilder,
      (
        CompletedTask,
        BaseReferences<_$AppDb, $CompletedTasksTable, CompletedTask>,
      ),
      CompletedTask,
      PrefetchHooks Function()
    >;

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$CompletedTasksTableTableManager get completedTasks =>
      $$CompletedTasksTableTableManager(_db, _db.completedTasks);
}
