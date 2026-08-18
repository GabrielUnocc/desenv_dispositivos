import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_strings.dart';
import '../controllers/category_controller.dart';
import '../controllers/task_controller.dart';
import '../widgets/task_card.dart';

/// Tela principal: lista todas as tarefas com FAB para criar novas.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final taskCtrl = context.watch<TaskController>();
    final catCtrl = context.watch<CategoryController>();
    final tasks = taskCtrl.tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.screenHome),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configurações',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Builder(
        builder: (ctx) {
          if (taskCtrl.error != null) {
            return Center(
              child: Text(
                taskCtrl.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }
          if (tasks.isEmpty) {
            return const _EmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final task = tasks[i];
              final cat = catCtrl.findById(task.categoryId);
              return TaskCard(
                task: task,
                category: cat,
                onToggleCompleted: () =>
                    context.read<TaskController>().toggleCompleted(task.id),
                onDelete: () =>
                    context.read<TaskController>().deleteTask(task.id),
                onTap: () => context.push('/tasks/${task.id}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tasks/new'),
        tooltip: 'Nova tarefa',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.task_alt_outlined,
            size: 72,
            color: colorScheme.onSurfaceVariant.withAlpha(102),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.emptyTaskList,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque no + para criar sua primeira tarefa.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withAlpha(178),
                ),
          ),
        ],
      ),
    );
  }
}
