import 'package:drift/drift.dart';

import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../database/app_database.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskDao _dao;

  const TaskRepositoryImpl(this._dao);

  @override
  Future<List<Task>> getAllTasks() async {
    final rows = await _dao.getAllTasks();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<void> createTask(Task task) => _dao.insertTask(_toCompanion(task));

  @override
  Future<void> updateTask(Task task) => _dao.updateTask(_toCompanion(task));

  @override
  Future<void> deleteTask(int id) => _dao.deleteTask(id);

  Task _toEntity(TaskRow row) => Task(
        id: row.id,
        title: row.title,
        description: row.description,
        category: row.category,
        priority: row.priority,
        isCompleted: row.isCompleted,
        createdAt: row.createdAt,
      );

  TasksCompanion _toCompanion(Task task) => TasksCompanion(
        id: task.id != null ? Value(task.id!) : const Value.absent(),
        title: Value(task.title),
        description: Value(task.description),
        category: Value(task.category),
        priority: Value(task.priority),
        isCompleted: Value(task.isCompleted),
        createdAt: Value(task.createdAt),
      );
}
