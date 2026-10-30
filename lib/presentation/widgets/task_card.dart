import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';
import '../screens/task_form_screen.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TaskProvider>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => provider.toggleTaskDone(task),
        ),
        title: Text(
          task.title,
          style: task.isCompleted
              ? const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                )
              : null,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Text(
                task.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                _CategoryChip(task.category),
                const SizedBox(width: 6),
                _PriorityBadge(task.priority),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _confirmDelete(context, provider),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, TaskProvider provider) {
    // salva referência antes do gap assíncrono do showDialog
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir tarefa'),
        content: Text('Deseja excluir "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteTask(task.id!);
              messenger.showSnackBar(
                const SnackBar(content: Text('Tarefa excluída')),
              );
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final Category category;

  const _CategoryChip(this.category);

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(_iconFor(category), size: 14),
      label: Text(category.label, style: const TextStyle(fontSize: 11)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  IconData _iconFor(Category cat) => switch (cat) {
        Category.work => Icons.work_outline,
        Category.study => Icons.school_outlined,
        Category.personal => Icons.person_outline,
      };
}

class _PriorityBadge extends StatelessWidget {
  final Priority priority;

  const _PriorityBadge(this.priority);

  @override
  Widget build(BuildContext context) {
    final (color, bg) = _colorsFor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        priority.label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, Color) _colorsFor(Priority p) => switch (p) {
        Priority.high => (Colors.red.shade700, Colors.red.shade50),
        Priority.medium => (Colors.orange.shade800, Colors.orange.shade50),
        Priority.low => (Colors.green.shade700, Colors.green.shade50),
      };
}
