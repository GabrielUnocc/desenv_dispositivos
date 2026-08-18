import 'package:injectable/injectable.dart';

import '../entities/task.dart';
import '../repositories/task_repository.dart';

@lazySingleton
class GetTasks {
  GetTasks(this._repository);
  final TaskRepository _repository;

  Stream<List<Task>> call() => _repository.watchAllTasks();
}
