import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/category.dart';

/// Converte entre [CategoriesTableData] (Drift) e [Category] (domínio).
class CategoryModel {
  CategoryModel._();

  /// Banco → Entidade.
  static Category fromData(CategoriesTableData data) => Category(
        id: data.id,
        name: data.name,
        color: data.color,
      );

  /// Entidade → Companion para UPDATE (inclui id).
  static CategoriesTableCompanion toCompanion(Category entity) =>
      CategoriesTableCompanion(
        id: Value(entity.id),
        name: Value(entity.name),
        color: Value(entity.color),
      );

  /// Entidade → Companion para INSERT (sem id, gerado pelo banco).
  static CategoriesTableCompanion toInsertCompanion(Category entity) =>
      CategoriesTableCompanion.insert(
        name: entity.name,
        color: entity.color,
      );
}
