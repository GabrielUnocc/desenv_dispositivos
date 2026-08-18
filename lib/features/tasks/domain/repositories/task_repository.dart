import '../entities/task.dart';

/// Contrato de acesso a dados para tarefas.
/// A camada de domínio só conhece esta interface — nunca a implementação.
abstract class TaskRepository {
  /// Stream reativo: re-emite a lista sempre que o banco muda.
  Stream<List<Task>> watchAllTasks();

  Future<Task?> getTaskById(int id);

  /// Retorna o id gerado pelo banco.
  Future<int> createTask(Task task);

  Future<void> updateTask(Task task);
  Future<void> deleteTask(int id);
  Future<void> toggleCompleted(int id);
  Future<void> toggleFavorite(int id);
}
