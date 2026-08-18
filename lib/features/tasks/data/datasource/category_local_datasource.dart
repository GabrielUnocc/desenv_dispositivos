import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';

abstract class CategoryLocalDatasource {
  Stream<List<CategoriesTableData>> watchAll();
  Future<List<CategoriesTableData>> getAll();
  Future<int> insert(CategoriesTableCompanion companion);
  Future<void> update(CategoriesTableCompanion companion);
  Future<void> delete(int id);
}

@LazySingleton(as: CategoryLocalDatasource)
class CategoryLocalDatasourceImpl implements CategoryLocalDatasource {
  CategoryLocalDatasourceImpl(this._db);
  final AppDatabase _db;

  @override
  Stream<List<CategoriesTableData>> watchAll() =>
      (_db.select(_db.categoriesTable)
        ..orderBy([(c) => OrderingTerm.asc(c.name)]))
      .watch();

  @override
  Future<List<CategoriesTableData>> getAll() =>
      (_db.select(_db.categoriesTable)
        ..orderBy([(c) => OrderingTerm.asc(c.name)]))
      .get();

  @override
  Future<int> insert(CategoriesTableCompanion companion) =>
      _db.into(_db.categoriesTable).insert(companion);

  @override
  Future<void> update(CategoriesTableCompanion companion) async {
    await (_db.update(_db.categoriesTable)
          ..where((c) => c.id.equals(companion.id.value)))
        .write(companion);
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.categoriesTable)..where((c) => c.id.equals(id))).go();
  }
}
