import 'package:flutter/material.dart';

import '../../domain/entities/task.dart';

class TaskFormScreen extends StatelessWidget {
  final Task? task;

  const TaskFormScreen({super.key, this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task == null ? 'Nova Tarefa' : 'Editar Tarefa'),
      ),
      body: const Center(
        child: Text('Formulário — implementado na Etapa 6'),
      ),
    );
  }
}
