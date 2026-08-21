import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciador_tarefas/features/tasks/domain/entities/priority.dart';
import 'package:gerenciador_tarefas/features/tasks/domain/entities/task.dart';
import 'package:gerenciador_tarefas/features/tasks/domain/repositories/task_repository.dart';
import 'package:gerenciador_tarefas/features/tasks/domain/usecases/create_task.dart';
import 'package:gerenciador_tarefas/features/tasks/domain/usecases/delete_task.dart';
import 'package:gerenciador_tarefas/features/tasks/domain/usecases/get_tasks.dart';
import 'package:gerenciador_tarefas/features/tasks/domain/usecases/toggle_task_completed.dart';
import 'package:gerenciador_tarefas/features/tasks/domain/usecases/toggle_task_favorite.dart';
import 'package:gerenciador_tarefas/features/tasks/domain/usecases/update_task.dart';

// ---------------------------------------------------------------------------
// Fake repository — grava as chamadas para verificação nos testes.
// ---------------------------------------------------------------------------

class FakeTaskRepository implements TaskRepository {
  final _streamCtrl = StreamController<List<Task>>.broadcast();

  // Chamadas registradas para verificação
  int? lastDeletedId;
  int? lastToggledCompletedId;
  int? lastToggledFavoriteId;
  Task? lastCreatedTask;
  Task? lastUpdatedTask;
  int _nextId = 1;

  void emit(List<Task> tasks) => _streamCtrl.add(tasks);

  @override
  Stream<List<Task>> watchAllTasks() => _streamCtrl.stream;

  @override
  Future<Task?> getTaskById(int id) async => null;

  @override
  Future<int> createTask(Task task) async {
    lastCreatedTask = task;
    return _nextId++;
  }

  @override
  Future<void> updateTask(Task task) async => lastUpdatedTask = task;

  @override
  Future<void> deleteTask(int id) async => lastDeletedId = id;

  @override
  Future<void> toggleCompleted(int id) async =>
      lastToggledCompletedId = id;

  @override
  Future<void> toggleFavorite(int id) async =>
      lastToggledFavoriteId = id;

  void close() => _streamCtrl.close();
}

// ---------------------------------------------------------------------------
// Fábrica de tarefa para testes
// ---------------------------------------------------------------------------

Task makeTask({int id = 1, String title = 'Tarefa'}) => Task(
      id: id,
      title: title,
      categoryId: 1,
      priority: Priority.medium,
      createdAt: DateTime(2025, 1, 1),
      isCompleted: false,
      isFavorite: false,
    );

// ---------------------------------------------------------------------------
// Testes
// ---------------------------------------------------------------------------

void main() {
  late FakeTaskRepository repo;

  setUp(() => repo = FakeTaskRepository());
  tearDown(() => repo.close());

  group('CreateTask', () {
    test('delega a criação ao repositório e retorna o id gerado', () async {
      final usecase = CreateTask(repo);
      final task = makeTask(title: 'Nova tarefa');

      final id = await usecase(task);

      expect(id, 1);
      expect(repo.lastCreatedTask, task);
    });

    test('ids incrementam a cada chamada', () async {
      final usecase = CreateTask(repo);

      final id1 = await usecase(makeTask(id: 1, title: 'T1'));
      final id2 = await usecase(makeTask(id: 2, title: 'T2'));

      expect(id1, 1);
      expect(id2, 2);
    });
  });

  group('UpdateTask', () {
    test('delega a atualização ao repositório com a tarefa correta', () async {
      final usecase = UpdateTask(repo);
      final task = makeTask(title: 'Atualizada');

      await usecase(task);

      expect(repo.lastUpdatedTask, task);
    });
  });

  group('DeleteTask', () {
    test('delega a exclusão ao repositório com o id correto', () async {
      final usecase = DeleteTask(repo);

      await usecase(42);

      expect(repo.lastDeletedId, 42);
    });
  });

  group('ToggleTaskCompleted', () {
    test('delega o toggle ao repositório com o id correto', () async {
      final usecase = ToggleTaskCompleted(repo);

      await usecase(7);

      expect(repo.lastToggledCompletedId, 7);
    });
  });

  group('ToggleTaskFavorite', () {
    test('delega o toggle ao repositório com o id correto', () async {
      final usecase = ToggleTaskFavorite(repo);

      await usecase(3);

      expect(repo.lastToggledFavoriteId, 3);
    });
  });

  group('GetTasks', () {
    test('retorna stream que emite a lista de tarefas', () async {
      final usecase = GetTasks(repo);
      final tasks = [makeTask(id: 1), makeTask(id: 2, title: 'Outra')];

      final future = usecase().first;
      repo.emit(tasks);

      final result = await future;
      expect(result, tasks);
    });

    test('re-emite quando o repositório emite novamente', () async {
      final usecase = GetTasks(repo);
      final emitted = <List<Task>>[];

      final sub = usecase().listen(emitted.add);
      repo.emit([makeTask(id: 1)]);
      repo.emit([makeTask(id: 1), makeTask(id: 2, title: 'Segunda')]);
      await Future.delayed(Duration.zero);

      expect(emitted.length, 2);
      expect(emitted[1].length, 2);
      await sub.cancel();
    });
  });
}
