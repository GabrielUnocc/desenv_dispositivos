import 'package:injectable/injectable.dart';

import '../repositories/task_repository.dart';

@lazySingleton
class ToggleTaskCompleted {
  ToggleTaskCompleted(this._repository);
  final TaskRepository _repository;

  Future<void> call(int id) => _repository.toggleCompleted(id);
}
