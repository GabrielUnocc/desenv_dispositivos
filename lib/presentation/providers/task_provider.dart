// 'hide Category' evita conflito com a anotação homônima do Flutter
import 'package:flutter/foundation.dart' hide Category;

import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

enum TaskStatusFilter { all, pending, completed }

class TaskProvider extends ChangeNotifier {
  final TaskRepository _repository;

  TaskProvider(this._repository);

  List<Task> _allTasks = [];
  String _searchQuery = '';
  Category? _categoryFilter;
  Priority? _priorityFilter;
  TaskStatusFilter _statusFilter = TaskStatusFilter.all;

  String get searchQuery => _searchQuery;
  Category? get categoryFilter => _categoryFilter;
  Priority? get priorityFilter => _priorityFilter;
  TaskStatusFilter get statusFilter => _statusFilter;

  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _categoryFilter != null ||
      _priorityFilter != null ||
      _statusFilter != TaskStatusFilter.all;

  List<Task> get filteredTasks {
    var tasks = _allTasks.where((task) {
      if (_statusFilter == TaskStatusFilter.pending && task.isCompleted) {
        return false;
      }
      if (_statusFilter == TaskStatusFilter.completed && !task.isCompleted) {
        return false;
      }
      if (_categoryFilter != null && task.category != _categoryFilter) {
        return false;
      }
      if (_priorityFilter != null && task.priority != _priorityFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return task.title.toLowerCase().contains(q) ||
            task.description.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    // mais recentes primeiro
    tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return tasks;
  }

  Future<void> loadTasks() async {
    _allTasks = await _repository.getAllTasks();
    notifyListeners();
  }

  Future<void> createTask(Task task) async {
    await _repository.createTask(task);
    await loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await _repository.updateTask(task);
    await loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await _repository.deleteTask(id);
    await loadTasks();
  }

  Future<void> toggleTaskDone(Task task) async {
    await _repository.updateTask(
      task.copyWith(isCompleted: !task.isCompleted),
    );
    await loadTasks();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(Category? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void setPriorityFilter(Priority? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  void setStatusFilter(TaskStatusFilter status) {
    _statusFilter = status;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _categoryFilter = null;
    _priorityFilter = null;
    _statusFilter = TaskStatusFilter.all;
    notifyListeners();
  }
}
