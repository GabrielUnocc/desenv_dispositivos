import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/entities/task.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_task_by_id.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/toggle_task_completed.dart';
import '../../domain/usecases/toggle_task_favorite.dart';
import '../../domain/usecases/update_task.dart';

/// ViewModel responsável pela lista de tarefas.
/// Escuta o stream reativo do Drift e notifica a UI a cada mudança.
class TaskController extends ChangeNotifier {
  TaskController({
    required GetTasks getTasks,
    required this._createTask,
    required this._updateTask,
    required this._deleteTask,
    required this._getTaskById,
    required this._toggleCompleted,
    required this._toggleFavorite,
  }) {
    _sub = getTasks().listen(
      (list) {
        _tasks = list;
        notifyListeners();
      },
      onError: (Object e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  final CreateTask _createTask;
  final UpdateTask _updateTask;
  final DeleteTask _deleteTask;
  final GetTaskById _getTaskById;
  final ToggleTaskCompleted _toggleCompleted;
  final ToggleTaskFavorite _toggleFavorite;

  StreamSubscription<List<Task>>? _sub;
  List<Task> _tasks = [];
  String? _error;
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  String? get error => _error;
  bool get isLoading => _isLoading;

  /// Busca a tarefa na lista em memória (O(n), suficiente para listas típicas).
  Task? findById(int id) {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Task?> getById(int id) => _getTaskById(id);

  Future<int> createTask(Task task) async {
    _isLoading = true;
    notifyListeners();
    try {
      return await _createTask(task);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTask(Task task) => _updateTask(task);

  Future<void> deleteTask(int id) => _deleteTask(id);

  Future<void> toggleCompleted(int id) => _toggleCompleted(id);

  Future<void> toggleFavorite(int id) => _toggleFavorite(id);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
