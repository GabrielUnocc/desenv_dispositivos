import '../entities/task.dart';

abstract interface class TaskRepository {
  Future<List<Task>> getAllTasks();
  Future<void> createTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(int id);
}
