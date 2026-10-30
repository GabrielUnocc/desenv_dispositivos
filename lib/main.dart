import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/database/app_database.dart';
import 'data/repositories/task_repository_impl.dart';
import 'presentation/providers/task_provider.dart';

void main() {
  final db = AppDatabase();
  final repository = TaskRepositoryImpl(db.taskDao);

  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskProvider(repository)..loadTasks(),
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Tarefas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('Etapa 4 — provider configurado')),
      ),
    );
  }
}
