import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/priority_ext.dart';
import '../controllers/category_controller.dart';
import '../controllers/task_controller.dart';

/// Tela de detalhes de uma tarefa com ações de editar, excluir,
/// concluir/reabrir e favoritar.
class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({super.key, required this.taskId});

  final int taskId;

  @override
  Widget build(BuildContext context) {
    final task = context.watch<TaskController>().findById(taskId);

    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.screenTaskDetail)),
        body: const Center(child: Text('Tarefa não encontrada.')),
      );
    }

    final category =
        context.watch<CategoryController>().findById(task.categoryId);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.screenTaskDetail),
        actions: [
          IconButton(
            icon: Icon(
              task.isFavorite
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              color: task.isFavorite ? const Color(0xFFFFB300) : null,
            ),
            tooltip: task.isFavorite ? 'Remover favorito' : 'Favoritar',
            onPressed: () =>
                context.read<TaskController>().toggleFavorite(task.id),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: AppStrings.actionEdit,
            onPressed: () => context.push('/tasks/${task.id}/edit'),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: colorScheme.error),
            tooltip: AppStrings.actionDelete,
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            task.title,
            style: textTheme.headlineSmall?.copyWith(
              decoration:
                  task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted
                  ? colorScheme.onSurface.withAlpha(128)
                  : colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (category != null)
                _Badge(
                  label: category.name,
                  color: Color(category.color),
                  icon: Icons.folder_outlined,
                ),
              _Badge(
                label: task.priority.label,
                color: task.priority.color,
                icon: task.priority.icon,
              ),
              if (task.isCompleted)
                _Badge(
                  label: 'Concluída',
                  color: colorScheme.primary,
                  icon: Icons.check_circle_outline,
                ),
            ],
          ),
          const SizedBox(height: 20),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Criada em',
            value: DateFormatter.format(task.createdAt),
          ),
          if (task.dueDate != null) ...[
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.schedule_rounded,
              label: 'Prazo',
              value: DateFormatter.formatRelative(task.dueDate!),
              valueColor: task.isOverdue ? colorScheme.error : null,
            ),
          ],
          if (task.description != null &&
              task.description!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Descrição', style: textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(task.description!, style: textTheme.bodyMedium),
          ],
          const SizedBox(height: 32),
          FilledButton.icon(
            icon: Icon(
              task.isCompleted
                  ? Icons.refresh_rounded
                  : Icons.check_circle_outline,
            ),
            label: Text(
              task.isCompleted
                  ? 'Reabrir tarefa'
                  : 'Marcar como concluída',
            ),
            onPressed: () {
              context.read<TaskController>().toggleCompleted(task.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    task.isCompleted
                        ? 'Tarefa reaberta.'
                        : AppStrings.taskCompleted,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.confirmDeleteTitle),
        content: const Text(AppStrings.confirmDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text(AppStrings.actionDelete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<TaskController>().deleteTask(taskId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.taskDeleted)),
        );
        context.pop();
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Widgets internos
// ---------------------------------------------------------------------------

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(31),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: valueColor ?? colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
