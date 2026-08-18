import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';

abstract class TaskLocalDatasource {
  Stream<List<TasksTableData>> watchAll();
  Future<TasksTableData?> getById(int id);
  Future<int> insert(TasksTableCompanion companion);
  Future<void> update(TasksTableCompanion companion);
  Future<void> delete(int id);
}

@LazySingleton(as: TaskLocalDatasource)
class TaskLocalDatasourceImpl implements TaskLocalDatasource {
  TaskLocalDatasourceImpl(this._db);
  final AppDatabase _db;

  @override
  Stream<List<TasksTableData>> watchAll() =>
      (_db.select(_db.tasksTable)
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .watch();

  @override
  Future<TasksTableData?> getById(int id) =>
      (_db.select(_db.tasksTable)..where((t) => t.id.equals(id)))
      .getSingleOrNull();

  @override
  Future<int> insert(TasksTableCompanion companion) =>
      _db.into(_db.tasksTable).insert(companion);

  @override
  Future<void> update(TasksTableCompanion companion) async {
    await (_db.update(_db.tasksTable)
          ..where((t) => t.id.equals(companion.id.value)))
        .write(companion);
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.tasksTable)..where((t) => t.id.equals(id))).go();
  }
}
