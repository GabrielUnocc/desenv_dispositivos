import 'package:drift/drift.dart';

/// Tabela de categorias no banco SQLite.
/// As 5 categorias padrão são inseridas via seed na criação do banco.
class CategoriesTable extends Table {
  @override
  String get tableName => 'categories';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// Cor armazenada como inteiro ARGB (ex.: 0xFF1565C0).
  IntColumn get color => integer()();
}
