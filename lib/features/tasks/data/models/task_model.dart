import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/priority.dart';
import '../../domain/entities/task.dart';

/// Converte entre [TasksTableData] (Drift) e [Task] (domínio).
class TaskModel {
  TaskModel._();

  /// Banco → Entidade.
  static Task fromData(TasksTableData data) => Task(
        id: data.id,
        title: data.title,
        description: data.description,
        categoryId: data.categoryId,
        priority: Priority.fromValue(data.priority),
        createdAt: data.createdAt,
        dueDate: data.dueDate,
        isCompleted: data.isCompleted,
        isFavorite: data.isFavorite,
      );

  /// Entidade → Companion para INSERT (id gerado pelo banco).
  static TasksTableCompanion toInsertCompanion(Task entity) =>
      TasksTableCompanion.insert(
        title: entity.title,
        description: Value(entity.description),
        categoryId: entity.categoryId,
        priority: Value(entity.priority.index),
        createdAt: entity.createdAt,
        dueDate: Value(entity.dueDate),
        isCompleted: Value(entity.isCompleted),
        isFavorite: Value(entity.isFavorite),
      );

  /// Entidade → Companion para UPDATE (inclui id e todos os campos mutáveis).
  static TasksTableCompanion toUpdateCompanion(Task entity) =>
      TasksTableCompanion(
        id: Value(entity.id),
        title: Value(entity.title),
        description: Value(entity.description),
        categoryId: Value(entity.categoryId),
        priority: Value(entity.priority.index),
        dueDate: Value(entity.dueDate),
        isCompleted: Value(entity.isCompleted),
        isFavorite: Value(entity.isFavorite),
      );
}
