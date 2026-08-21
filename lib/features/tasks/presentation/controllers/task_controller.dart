import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/entities/priority.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_task_by_id.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/toggle_task_completed.dart';
import '../../domain/usecases/toggle_task_favorite.dart';
import '../../domain/usecases/update_task.dart';

/// Filtro de status aplicado à lista de tarefas.
enum TaskStatusFilter { all, pending, completed, today, overdue }

/// Critério de ordenação da lista de tarefas.
enum TaskSortOption { dateDesc, dateAsc, nameAsc, priorityDesc }

/// ViewModel responsável pela lista de tarefas.
/// Escuta o stream reativo do Drift e notifica a UI a cada mudança.
/// Também gerencia busca, filtros e ordenação na camada de apresentação.
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

  // --- Estado de busca / filtro / ordenação ---
  String _searchQuery = '';
  TaskStatusFilter _statusFilter = TaskStatusFilter.all;
  int? _categoryFilter;
  Priority? _priorityFilter;
  TaskSortOption _sortOption = TaskSortOption.dateDesc;

  // --- Getters de estado bruto ---
  List<Task> get tasks => _tasks;
  String? get error => _error;
  bool get isLoading => _isLoading;

  // --- Getters de filtro (para a UI saber o que está ativo) ---
  String get searchQuery => _searchQuery;
  TaskStatusFilter get statusFilter => _statusFilter;
  int? get categoryFilter => _categoryFilter;
  Priority? get priorityFilter => _priorityFilter;
  TaskSortOption get sortOption => _sortOption;

  /// Verdadeiro quando qualquer filtro (exceto ordenação) está ativo.
  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _statusFilter != TaskStatusFilter.all ||
      _categoryFilter != null ||
      _priorityFilter != null;

  /// Lista filtrada e ordenada, usada pela UI na tela principal.
  List<Task> get filteredTasks {
    var result = _tasks.where((t) {
      // Busca por título e descrição
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = t.title.toLowerCase().contains(q);
        final matchDesc = t.description?.toLowerCase().contains(q) ?? false;
        if (!matchTitle && !matchDesc) return false;
      }

      // Filtro de status
      switch (_statusFilter) {
        case TaskStatusFilter.all:
          break;
        case TaskStatusFilter.pending:
          if (t.isCompleted) return false;
        case TaskStatusFilter.completed:
          if (!t.isCompleted) return false;
        case TaskStatusFilter.today:
          if (!t.isDueToday) return false;
        case TaskStatusFilter.overdue:
          if (!t.isOverdue) return false;
      }

      // Filtro de categoria
      if (_categoryFilter != null && t.categoryId != _categoryFilter) {
        return false;
      }

      // Filtro de prioridade
      if (_priorityFilter != null && t.priority != _priorityFilter) {
        return false;
      }

      return true;
    }).toList();

    // Ordenação
    switch (_sortOption) {
      case TaskSortOption.dateDesc:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case TaskSortOption.dateAsc:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case TaskSortOption.nameAsc:
        result.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      case TaskSortOption.priorityDesc:
        result.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    }

    return result;
  }

  // --- Métodos de filtro ---

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(TaskStatusFilter filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  void setCategoryFilter(int? categoryId) {
    _categoryFilter = categoryId;
    notifyListeners();
  }

  void setPriorityFilter(Priority? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  void setSortOption(TaskSortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _statusFilter = TaskStatusFilter.all;
    _categoryFilter = null;
    _priorityFilter = null;
    _sortOption = TaskSortOption.dateDesc;
    notifyListeners();
  }

  // --- Operações CRUD ---

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
