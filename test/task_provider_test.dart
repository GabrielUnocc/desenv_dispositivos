import 'package:flutter_test/flutter_test.dart';

import 'package:gerenciador_tarefas/domain/entities/task.dart';
import 'package:gerenciador_tarefas/domain/repositories/task_repository.dart';
import 'package:gerenciador_tarefas/presentation/providers/task_provider.dart';

class _FakeRepository implements TaskRepository {
  final List<Task> _tasks;
  _FakeRepository(this._tasks);

  @override
  Future<List<Task>> getAllTasks() async => List.of(_tasks);

  @override
  Future<void> createTask(Task task) async => _tasks.add(task);

  @override
  Future<void> updateTask(Task task) async {}

  @override
  Future<void> deleteTask(int id) async =>
      _tasks.removeWhere((t) => t.id == id);
}

Task _task({
  required int id,
  required String title,
  String description = '',
  Category category = Category.personal,
  Priority priority = Priority.medium,
  bool isCompleted = false,
}) =>
    Task(
      id: id,
      title: title,
      description: description,
      category: category,
      priority: priority,
      isCompleted: isCompleted,
      createdAt: DateTime(2026, 10, id),
    );

void main() {
  late TaskProvider provider;

  setUp(() async {
    provider = TaskProvider(
      _FakeRepository([
        _task(id: 1, title: 'Estudar Flutter', category: Category.study, priority: Priority.high),
        _task(id: 2, title: 'Reunião', description: 'Sala 3', category: Category.work, isCompleted: true),
        _task(id: 3, title: 'Academia', category: Category.personal, priority: Priority.low),
      ]),
    );
    await provider.loadTasks();
  });

  group('filteredTasks', () {
    test('sem filtros retorna todas as tarefas', () {
      expect(provider.filteredTasks, hasLength(3));
    });

    test('status pendentes exclui concluídas', () {
      provider.setStatusFilter(TaskStatusFilter.pending);
      expect(provider.filteredTasks, hasLength(2));
      expect(provider.filteredTasks.every((t) => !t.isCompleted), isTrue);
    });

    test('status concluídas retorna só as concluídas', () {
      provider.setStatusFilter(TaskStatusFilter.completed);
      final tasks = provider.filteredTasks;
      expect(tasks, hasLength(1));
      expect(tasks.first.id, 2);
    });

    test('filtro por categoria', () {
      provider.setCategoryFilter(Category.study);
      expect(provider.filteredTasks, hasLength(1));
      expect(provider.filteredTasks.first.category, Category.study);
    });

    test('filtro por prioridade', () {
      provider.setPriorityFilter(Priority.low);
      expect(provider.filteredTasks, hasLength(1));
      expect(provider.filteredTasks.first.priority, Priority.low);
    });

    test('busca por título (case insensitive)', () {
      provider.setSearchQuery('flutter');
      expect(provider.filteredTasks, hasLength(1));
      expect(provider.filteredTasks.first.title, contains('Flutter'));
    });

    test('busca por descrição', () {
      provider.setSearchQuery('Sala');
      expect(provider.filteredTasks, hasLength(1));
    });

    test('filtros combinados: pendentes + categoria estudo', () {
      provider.setStatusFilter(TaskStatusFilter.pending);
      provider.setCategoryFilter(Category.study);
      expect(provider.filteredTasks, hasLength(1));
      expect(provider.filteredTasks.first.id, 1);
    });

    test('clearFilters reseta tudo', () {
      provider.setStatusFilter(TaskStatusFilter.completed);
      provider.setCategoryFilter(Category.work);
      provider.setSearchQuery('algo');
      provider.clearFilters();
      expect(provider.filteredTasks, hasLength(3));
      expect(provider.hasActiveFilters, isFalse);
    });

    test('hasActiveFilters reflete estado dos filtros', () {
      expect(provider.hasActiveFilters, isFalse);
      provider.setPriorityFilter(Priority.high);
      expect(provider.hasActiveFilters, isTrue);
    });
  });
}
