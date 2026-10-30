import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:gerenciador_tarefas/domain/entities/task.dart';
import 'package:gerenciador_tarefas/domain/repositories/task_repository.dart';
import 'package:gerenciador_tarefas/main.dart';
import 'package:gerenciador_tarefas/presentation/providers/task_provider.dart';
import 'package:gerenciador_tarefas/presentation/providers/theme_provider.dart';

class _FakeRepository implements TaskRepository {
  @override
  Future<List<Task>> getAllTasks() async => [];
  @override
  Future<void> createTask(Task task) async {}
  @override
  Future<void> updateTask(Task task) async {}
  @override
  Future<void> deleteTask(int id) async {}
}

void main() {
  testWidgets('App smoke test — renderiza a tela principal', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(
            create: (_) => TaskProvider(_FakeRepository()),
          ),
        ],
        child: const App(),
      ),
    );
    expect(find.text('Minhas Tarefas'), findsOneWidget);
  });
}
