import 'package:injectable/injectable.dart';

import '../entities/task.dart';
import '../repositories/task_repository.dart';

@lazySingleton
class CreateTask {
  CreateTask(this._repository);
  final TaskRepository _repository;

  Future<int> call(Task task) => _repository.createTask(task);
}
