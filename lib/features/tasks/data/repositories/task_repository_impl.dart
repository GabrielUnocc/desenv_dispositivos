import 'package:injectable/injectable.dart';

import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasource/task_local_datasource.dart';
import '../models/task_model.dart';

@LazySingleton(as: TaskRepository)
class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._datasource);
  final TaskLocalDatasource _datasource;

  @override
  Stream<List<Task>> watchAllTasks() =>
      _datasource.watchAll().map((rows) => rows.map(TaskModel.fromData).toList());

  @override
  Future<Task?> getTaskById(int id) async {
    final data = await _datasource.getById(id);
    return data != null ? TaskModel.fromData(data) : null;
  }

  @override
  Future<int> createTask(Task task) =>
      _datasource.insert(TaskModel.toInsertCompanion(task));

  @override
  Future<void> updateTask(Task task) =>
      _datasource.update(TaskModel.toUpdateCompanion(task));

  @override
  Future<void> deleteTask(int id) => _datasource.delete(id);

  @override
  Future<void> toggleCompleted(int id) async {
    final task = await getTaskById(id);
    if (task != null) {
      await updateTask(task.copyWith(isCompleted: !task.isCompleted));
    }
  }

  @override
  Future<void> toggleFavorite(int id) async {
    final task = await getTaskById(id);
    if (task != null) {
      await updateTask(task.copyWith(isFavorite: !task.isFavorite));
    }
  }
}
