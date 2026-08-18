import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import 'tables/categories_table.dart';
import 'tables/tasks_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [CategoriesTable, TasksTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _seedDefaultCategories();
    },
  );

  /// Insere as 5 categorias padrão no primeiro uso do app.
  Future<void> _seedDefaultCategories() async {
    const defaults = [
      (AppStrings.categoryWork, AppColors.categoryWork),
      (AppStrings.categoryStudy, AppColors.categoryStudy),
      (AppStrings.categoryPersonal, AppColors.categoryPersonal),
      (AppStrings.categoryShopping, AppColors.categoryShopping),
      (AppStrings.categoryHealth, AppColors.categoryHealth),
    ];

    await batch((b) {
      b.insertAll(
        categoriesTable,
        defaults
            .map(
              (e) => CategoriesTableCompanion.insert(
                name: e.$1,
                color: e.$2.toARGB32(),
              ),
            )
            .toList(),
      );
    });
  }
}

/// Abre (ou cria) o arquivo SQLite na pasta de documentos do dispositivo.
/// Foreign keys são habilitadas explicitamente para garantir integridade referencial.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'tasks.sqlite'));

    return NativeDatabase.createInBackground(
      file,
      setup: (db) => db.execute('PRAGMA foreign_keys = ON;'),
    );
  });
}
