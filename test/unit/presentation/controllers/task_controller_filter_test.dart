import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciador_tarefas/features/tasks/domain/entities/priority.dart';
import 'package:gerenciador_tarefas/features/tasks/domain/entities/task.dart';
import 'package:gerenciador_tarefas/features/tasks/domain/repositories/task_repository.dart';
import 'package:gerenciador_tarefas/features/tasks/domain/usecases/create_task.dart';
import 'package:gerenciador_tarefas/features/tasks/domain/usecases/delete_task.dart';
import 'package:gerenciador_tarefas/features/tasks/domain/usecases/get_task_by_id.dart';
import 'package:gerenciador_tarefas/features/tasks/domain/usecases/get_tasks.dart';
import 'package:gerenciador_tarefas/features/tasks/domain/usecases/toggle_task_completed.dart';
import 'package:gerenciador_tarefas/features/tasks/domain/usecases/toggle_task_favorite.dart';
import 'package:gerenciador_tarefas/features/tasks/domain/usecases/update_task.dart';
import 'package:gerenciador_tarefas/features/tasks/presentation/controllers/task_controller.dart';

// ---------------------------------------------------------------------------
// Fake repository com StreamController para simular o Drift.
// ---------------------------------------------------------------------------

class FakeTaskRepository implements TaskRepository {
  final _ctrl = StreamController<List<Task>>.broadcast();

  void emit(List<Task> tasks) => _ctrl.add(tasks);

  @override
  Stream<List<Task>> watchAllTasks() => _ctrl.stream;

  @override
  Future<Task?> getTaskById(int id) async => null;

  @override
  Future<int> createTask(Task task) async => 1;

  @override
  Future<void> updateTask(Task task) async {}

  @override
  Future<void> deleteTask(int id) async {}

  @override
  Future<void> toggleCompleted(int id) async {}

  @override
  Future<void> toggleFavorite(int id) async {}

  void close() => _ctrl.close();
}

// ---------------------------------------------------------------------------
// Helper: constrói o controller com o fake repository.
// ---------------------------------------------------------------------------

TaskController makeController(FakeTaskRepository repo) => TaskController(
      getTasks: GetTasks(repo),
      createTask: CreateTask(repo),
      updateTask: UpdateTask(repo),
      deleteTask: DeleteTask(repo),
      getTaskById: GetTaskById(repo),
      toggleCompleted: ToggleTaskCompleted(repo),
      toggleFavorite: ToggleTaskFavorite(repo),
    );

// ---------------------------------------------------------------------------
// Dados de teste — conjunto fixo de tarefas com variações.
// ---------------------------------------------------------------------------

final _past = DateTime(2020, 6, 15);
final _future = DateTime(2099, 1, 1);
final _today = () {
  final n = DateTime.now();
  // Fim do dia garante que isDueToday=true e isOverdue=false na mesma execução.
  return DateTime(n.year, n.month, n.day, 23, 59, 59);
}();

/// Tarefas de teste:
/// [0] Alta prioridade, concluída, cat 1, sem prazo
/// [1] Média prioridade, pendente, cat 1, prazo hoje
/// [2] Baixa prioridade, pendente, cat 2, prazo passado (atrasada)
/// [3] Alta prioridade, pendente, cat 2, prazo futuro
final _tasks = [
  Task(
    id: 1,
    title: 'Relatório anual',
    description: 'Relatório de vendas do trimestre',
    categoryId: 1,
    priority: Priority.high,
    createdAt: DateTime(2025, 1, 1),
    isCompleted: true,
    isFavorite: false,
  ),
  Task(
    id: 2,
    title: 'Estudar Flutter',
    description: null,
    categoryId: 1,
    priority: Priority.medium,
    createdAt: DateTime(2025, 1, 2),
    isCompleted: false,
    isFavorite: false,
    dueDate: _today,
  ),
  Task(
    id: 3,
    title: 'Comprar mantimentos',
    description: 'Mercado perto de casa',
    categoryId: 2,
    priority: Priority.low,
    createdAt: DateTime(2025, 1, 3),
    isCompleted: false,
    isFavorite: false,
    dueDate: _past,
  ),
  Task(
    id: 4,
    title: 'Revisar projeto',
    description: null,
    categoryId: 2,
    priority: Priority.high,
    createdAt: DateTime(2025, 1, 4),
    isCompleted: false,
    isFavorite: false,
    dueDate: _future,
  ),
];

// ---------------------------------------------------------------------------
// Testes
// ---------------------------------------------------------------------------

void main() {
  late FakeTaskRepository repo;
  late TaskController ctrl;

  setUp(() {
    repo = FakeTaskRepository();
    ctrl = makeController(repo);
  });

  tearDown(() {
    ctrl.dispose();
    repo.close();
  });

  /// Emite as tarefas de teste e aguarda o stream ser processado.
  Future<void> seedTasks() async {
    repo.emit(_tasks);
    await Future.delayed(Duration.zero);
  }

  // ---- Estado inicial -----------------------------------------------------

  group('Estado inicial', () {
    test('lista de tarefas começa vazia', () {
      expect(ctrl.tasks, isEmpty);
    });

    test('filteredTasks começa vazia', () {
      expect(ctrl.filteredTasks, isEmpty);
    });

    test('hasActiveFilters é false sem filtros', () {
      expect(ctrl.hasActiveFilters, isFalse);
    });

    test('statusFilter padrão é all', () {
      expect(ctrl.statusFilter, TaskStatusFilter.all);
    });

    test('sortOption padrão é dateDesc', () {
      expect(ctrl.sortOption, TaskSortOption.dateDesc);
    });
  });

  // ---- Stream reativo ------------------------------------------------------

  group('Stream reativo', () {
    test('tasks é atualizado ao receber dados do repositório', () async {
      await seedTasks();
      expect(ctrl.tasks.length, _tasks.length);
    });

    test('filteredTasks retorna todas as tarefas sem filtros ativos', () async {
      await seedTasks();
      expect(ctrl.filteredTasks.length, _tasks.length);
    });
  });

  // ---- Busca ---------------------------------------------------------------

  group('Busca (setSearch)', () {
    test('filtra por título (case-insensitive)', () async {
      await seedTasks();
      ctrl.setSearch('flutter');
      expect(ctrl.filteredTasks.map((t) => t.id), containsAll([2]));
      expect(ctrl.filteredTasks.length, 1);
    });

    test('filtra por descrição', () async {
      await seedTasks();
      ctrl.setSearch('mercado');
      expect(ctrl.filteredTasks.single.id, 3);
    });

    test('retorna todas quando a busca é limpa', () async {
      await seedTasks();
      ctrl.setSearch('flutter');
      ctrl.setSearch('');
      expect(ctrl.filteredTasks.length, _tasks.length);
    });

    test('retorna lista vazia para busca sem resultado', () async {
      await seedTasks();
      ctrl.setSearch('xyzwnotfound');
      expect(ctrl.filteredTasks, isEmpty);
    });
  });

  // ---- Filtro de status ----------------------------------------------------

  group('Filtro de status (setStatusFilter)', () {
    test('pending: retorna apenas não concluídas', () async {
      await seedTasks();
      ctrl.setStatusFilter(TaskStatusFilter.pending);
      expect(ctrl.filteredTasks.every((t) => !t.isCompleted), isTrue);
    });

    test('completed: retorna apenas concluídas', () async {
      await seedTasks();
      ctrl.setStatusFilter(TaskStatusFilter.completed);
      expect(ctrl.filteredTasks.every((t) => t.isCompleted), isTrue);
      expect(ctrl.filteredTasks.single.id, 1);
    });

    test('overdue: retorna apenas atrasadas', () async {
      await seedTasks();
      ctrl.setStatusFilter(TaskStatusFilter.overdue);
      expect(ctrl.filteredTasks.single.id, 3);
    });

    test('today: retorna apenas com prazo hoje', () async {
      await seedTasks();
      ctrl.setStatusFilter(TaskStatusFilter.today);
      expect(ctrl.filteredTasks.single.id, 2);
    });

    test('all: retorna todas após mudar o filtro de volta', () async {
      await seedTasks();
      ctrl.setStatusFilter(TaskStatusFilter.completed);
      ctrl.setStatusFilter(TaskStatusFilter.all);
      expect(ctrl.filteredTasks.length, _tasks.length);
    });
  });

  // ---- Filtro de categoria -------------------------------------------------

  group('Filtro de categoria (setCategoryFilter)', () {
    test('filtra por categoria 1', () async {
      await seedTasks();
      ctrl.setCategoryFilter(1);
      expect(ctrl.filteredTasks.every((t) => t.categoryId == 1), isTrue);
      expect(ctrl.filteredTasks.length, 2);
    });

    test('filtra por categoria 2', () async {
      await seedTasks();
      ctrl.setCategoryFilter(2);
      expect(ctrl.filteredTasks.length, 2);
      expect(ctrl.filteredTasks.every((t) => t.categoryId == 2), isTrue);
    });

    test('null remove o filtro de categoria', () async {
      await seedTasks();
      ctrl.setCategoryFilter(1);
      ctrl.setCategoryFilter(null);
      expect(ctrl.filteredTasks.length, _tasks.length);
    });
  });

  // ---- Filtro de prioridade ------------------------------------------------

  group('Filtro de prioridade (setPriorityFilter)', () {
    test('filtra por alta prioridade', () async {
      await seedTasks();
      ctrl.setPriorityFilter(Priority.high);
      expect(ctrl.filteredTasks.every((t) => t.priority == Priority.high), isTrue);
      expect(ctrl.filteredTasks.length, 2);
    });

    test('filtra por baixa prioridade', () async {
      await seedTasks();
      ctrl.setPriorityFilter(Priority.low);
      expect(ctrl.filteredTasks.single.id, 3);
    });

    test('null remove o filtro de prioridade', () async {
      await seedTasks();
      ctrl.setPriorityFilter(Priority.high);
      ctrl.setPriorityFilter(null);
      expect(ctrl.filteredTasks.length, _tasks.length);
    });
  });

  // ---- Filtros combinados --------------------------------------------------

  group('Filtros combinados', () {
    test('busca + filtro de status funcionam juntos', () async {
      await seedTasks();
      ctrl.setStatusFilter(TaskStatusFilter.pending);
      ctrl.setSearch('projeto');
      expect(ctrl.filteredTasks.single.id, 4);
    });

    test('categoria + prioridade funcionam juntos', () async {
      await seedTasks();
      ctrl.setCategoryFilter(2);
      ctrl.setPriorityFilter(Priority.high);
      expect(ctrl.filteredTasks.single.id, 4);
    });
  });

  // ---- Ordenação -----------------------------------------------------------

  group('Ordenação (setSortOption)', () {
    test('dateDesc: mais recente primeiro (padrão)', () async {
      await seedTasks();
      ctrl.setSortOption(TaskSortOption.dateDesc);
      final ids = ctrl.filteredTasks.map((t) => t.id).toList();
      expect(ids, [4, 3, 2, 1]);
    });

    test('dateAsc: mais antiga primeiro', () async {
      await seedTasks();
      ctrl.setSortOption(TaskSortOption.dateAsc);
      final ids = ctrl.filteredTasks.map((t) => t.id).toList();
      expect(ids, [1, 2, 3, 4]);
    });

    test('nameAsc: ordem alfabética pelo título', () async {
      await seedTasks();
      ctrl.setSortOption(TaskSortOption.nameAsc);
      final titles = ctrl.filteredTasks.map((t) => t.title).toList();
      expect(titles, orderedEquals(titles.toList()..sort()));
    });

    test('priorityDesc: alta primeiro, depois média, depois baixa', () async {
      await seedTasks();
      ctrl.setSortOption(TaskSortOption.priorityDesc);
      final priorities = ctrl.filteredTasks.map((t) => t.priority).toList();
      // Verifica que a lista está em ordem não-crescente de índice do enum
      for (var i = 0; i < priorities.length - 1; i++) {
        expect(
          priorities[i].index,
          greaterThanOrEqualTo(priorities[i + 1].index),
        );
      }
    });
  });

  // ---- clearFilters --------------------------------------------------------

  group('clearFilters', () {
    test('reseta todos os filtros e a ordenação', () async {
      await seedTasks();
      ctrl.setSearch('flutter');
      ctrl.setStatusFilter(TaskStatusFilter.pending);
      ctrl.setCategoryFilter(1);
      ctrl.setPriorityFilter(Priority.high);
      ctrl.setSortOption(TaskSortOption.nameAsc);

      ctrl.clearFilters();

      expect(ctrl.searchQuery, isEmpty);
      expect(ctrl.statusFilter, TaskStatusFilter.all);
      expect(ctrl.categoryFilter, isNull);
      expect(ctrl.priorityFilter, isNull);
      expect(ctrl.sortOption, TaskSortOption.dateDesc);
      expect(ctrl.hasActiveFilters, isFalse);
      expect(ctrl.filteredTasks.length, _tasks.length);
    });
  });

  // ---- hasActiveFilters ----------------------------------------------------

  group('hasActiveFilters', () {
    test('true quando há busca ativa', () async {
      await seedTasks();
      ctrl.setSearch('algo');
      expect(ctrl.hasActiveFilters, isTrue);
    });

    test('true quando filtro de status não é all', () async {
      ctrl.setStatusFilter(TaskStatusFilter.pending);
      expect(ctrl.hasActiveFilters, isTrue);
    });

    test('true quando filtro de categoria está ativo', () async {
      ctrl.setCategoryFilter(1);
      expect(ctrl.hasActiveFilters, isTrue);
    });

    test('true quando filtro de prioridade está ativo', () async {
      ctrl.setPriorityFilter(Priority.low);
      expect(ctrl.hasActiveFilters, isTrue);
    });

    test('false após clearFilters', () async {
      ctrl.setSearch('x');
      ctrl.clearFilters();
      expect(ctrl.hasActiveFilters, isFalse);
    });
  });
}
