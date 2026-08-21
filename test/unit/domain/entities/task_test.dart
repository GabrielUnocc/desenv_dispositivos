import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciador_tarefas/features/tasks/domain/entities/priority.dart';
import 'package:gerenciador_tarefas/features/tasks/domain/entities/task.dart';

/// Fábrica de tarefas para uso nos testes — evita repetição de campos obrigatórios.
Task makeTask({
  int id = 1,
  String title = 'Tarefa de teste',
  String? description,
  int categoryId = 1,
  Priority priority = Priority.medium,
  bool isCompleted = false,
  bool isFavorite = false,
  DateTime? dueDate,
  DateTime? createdAt,
}) =>
    Task(
      id: id,
      title: title,
      description: description,
      categoryId: categoryId,
      priority: priority,
      createdAt: createdAt ?? DateTime(2025, 1, 1),
      isCompleted: isCompleted,
      isFavorite: isFavorite,
      dueDate: dueDate,
    );

void main() {
  group('Task.isOverdue', () {
    test('retorna false quando a tarefa está concluída', () {
      final task = makeTask(
        isCompleted: true,
        dueDate: DateTime(2020, 1, 1),
      );
      expect(task.isOverdue, isFalse);
    });

    test('retorna false quando não há data limite', () {
      final task = makeTask();
      expect(task.isOverdue, isFalse);
    });

    test('retorna false quando a data limite é no futuro', () {
      final task = makeTask(
        dueDate: DateTime.now().add(const Duration(days: 10)),
      );
      expect(task.isOverdue, isFalse);
    });

    test('retorna true quando a data limite passou e a tarefa está pendente', () {
      final task = makeTask(dueDate: DateTime(2020, 1, 1));
      expect(task.isOverdue, isTrue);
    });
  });

  group('Task.isDueToday', () {
    test('retorna false quando não há data limite', () {
      final task = makeTask();
      expect(task.isDueToday, isFalse);
    });

    test('retorna true quando a data limite é hoje', () {
      final now = DateTime.now();
      final task = makeTask(
        dueDate: DateTime(now.year, now.month, now.day, 23, 59),
      );
      expect(task.isDueToday, isTrue);
    });

    test('retorna false quando a data limite foi ontem', () {
      final task = makeTask(
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(task.isDueToday, isFalse);
    });

    test('retorna false quando a data limite é amanhã', () {
      final task = makeTask(
        dueDate: DateTime.now().add(const Duration(days: 1)),
      );
      expect(task.isDueToday, isFalse);
    });
  });

  group('Task.copyWith', () {
    test('atualiza apenas os campos informados', () {
      final original = makeTask(title: 'Original', priority: Priority.low);
      final updated = original.copyWith(title: 'Atualizado', isCompleted: true);

      expect(updated.title, 'Atualizado');
      expect(updated.isCompleted, isTrue);
      // Campos não alterados preservados
      expect(updated.id, original.id);
      expect(updated.priority, original.priority);
      expect(updated.categoryId, original.categoryId);
    });

    test('não modifica a tarefa original (imutabilidade)', () {
      final original = makeTask(title: 'Original');
      original.copyWith(title: 'Outro');
      expect(original.title, 'Original');
    });
  });

  group('Task — equatable', () {
    test('duas tarefas com os mesmos campos são iguais', () {
      final t1 = makeTask(id: 1, title: 'A');
      final t2 = makeTask(id: 1, title: 'A');
      expect(t1, equals(t2));
    });

    test('tarefas com ids diferentes são diferentes', () {
      final t1 = makeTask(id: 1);
      final t2 = makeTask(id: 2);
      expect(t1, isNot(equals(t2)));
    });

    test('tarefas com títulos diferentes são diferentes', () {
      final t1 = makeTask(title: 'A');
      final t2 = makeTask(title: 'B');
      expect(t1, isNot(equals(t2)));
    });
  });

  group('Priority.fromValue', () {
    test('converte índice correto para o enum', () {
      expect(Priority.fromValue(0), Priority.low);
      expect(Priority.fromValue(1), Priority.medium);
      expect(Priority.fromValue(2), Priority.high);
    });

    test('clamp: índice negativo retorna low', () {
      expect(Priority.fromValue(-1), Priority.low);
    });

    test('clamp: índice acima do máximo retorna high', () {
      expect(Priority.fromValue(99), Priority.high);
    });
  });
}
