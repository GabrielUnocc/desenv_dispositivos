import 'package:injectable/injectable.dart';

import '../entities/task.dart';
import '../repositories/task_repository.dart';

@lazySingleton
class UpdateTask {
  UpdateTask(this._repository);
  final TaskRepository _repository;

  Future<void> call(Task task) => _repository.updateTask(task);
}
