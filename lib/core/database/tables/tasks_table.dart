import 'package:drift/drift.dart';

import 'categories_table.dart';

/// Tabela de tarefas no banco SQLite.
/// [priority] é armazenada como int: 0 = Baixa, 1 = Média, 2 = Alta.
/// [categoryId] referencia [CategoriesTable] com deleção restrita.
class TasksTable extends Table {
  @override
  String get tableName => 'tasks';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();

  IntColumn get categoryId =>
      integer().references(CategoriesTable, #id)();

  /// 0 = Baixa · 1 = Média · 2 = Alta
  IntColumn get priority => integer().withDefault(const Constant(1))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get dueDate => dateTime().nullable()();

  BoolColumn get isCompleted =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isFavorite =>
      boolean().withDefault(const Constant(false))();
}
