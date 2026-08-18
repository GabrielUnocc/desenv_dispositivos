import 'package:injectable/injectable.dart';

import '../entities/task.dart';
import '../repositories/task_repository.dart';

@lazySingleton
class GetTaskById {
  GetTaskById(this._repository);
  final TaskRepository _repository;

  Future<Task?> call(int id) => _repository.getTaskById(id);
}
