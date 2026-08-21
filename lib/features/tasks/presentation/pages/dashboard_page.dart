import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/priority_ext.dart';
import '../../domain/entities/priority.dart';
import '../../domain/entities/task.dart';
import '../controllers/task_controller.dart';

/// Tela de estatísticas: resumo visual do progresso das tarefas.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskController>().tasks;
    final stats = _TaskStats.from(tasks);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: tasks.isEmpty
          ? const _EmptyDashboard()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                _ProgressHero(stats: stats),
                const SizedBox(height: 20),
                _StatsGrid(stats: stats),
                const SizedBox(height: 24),
                _PrioritySection(tasks: tasks),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Seção: anel de progresso + percentual
// ---------------------------------------------------------------------------

class _ProgressHero extends StatelessWidget {
  const _ProgressHero({required this.stats});
  final _TaskStats stats;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
        child: Column(
          children: [
            Text('Progresso geral', style: tt.titleMedium),
            const SizedBox(height: 24),
            SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: stats.completionRate,
                    strokeWidth: 14,
                    backgroundColor: cs.surfaceContainerHighest,
                    color: cs.primary,
                    strokeCap: StrokeCap.round,
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(stats.completionRate * 100).toStringAsFixed(0)}%',
                          style: tt.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                          ),
                        ),
                        Text(
                          'concluído',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${stats.completed} de ${stats.total} tarefa${stats.total == 1 ? '' : 's'} concluída${stats.completed == 1 ? '' : 's'}',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Seção: grade de cartões de estatística
// ---------------------------------------------------------------------------

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});
  final _TaskStats stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        _StatCard(
          label: 'Total',
          value: stats.total,
          icon: Icons.list_alt_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
        _StatCard(
          label: 'Concluídas',
          value: stats.completed,
          icon: Icons.check_circle_outline_rounded,
          color: Colors.green,
        ),
        _StatCard(
          label: 'Pendentes',
          value: stats.pending,
          icon: Icons.radio_button_unchecked_rounded,
          color: Theme.of(context).colorScheme.secondary,
        ),
        _StatCard(
          label: 'Atrasadas',
          value: stats.overdue,
          icon: Icons.warning_amber_rounded,
          color: Theme.of(context).colorScheme.error,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  label,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Seção: distribuição por prioridade (barras horizontais)
// ---------------------------------------------------------------------------

class _PrioritySection extends StatelessWidget {
  const _PrioritySection({required this.tasks});
  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    final byPriority = {
      Priority.high: tasks.where((t) => t.priority == Priority.high).length,
      Priority.medium: tasks.where((t) => t.priority == Priority.medium).length,
      Priority.low: tasks.where((t) => t.priority == Priority.low).length,
    };
    final total = tasks.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Por prioridade', style: tt.titleMedium),
            const SizedBox(height: 16),
            for (final priority in [Priority.high, Priority.medium, Priority.low])
              _PriorityBar(
                priority: priority,
                count: byPriority[priority]!,
                total: total,
              ),
          ],
        ),
      ),
    );
  }
}

class _PriorityBar extends StatelessWidget {
  const _PriorityBar({
    required this.priority,
    required this.count,
    required this.total,
  });

  final Priority priority;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final color = priority.color;
    final ratio = total > 0 ? count / total : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(priority.icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(priority.label, style: tt.bodyMedium),
              const Spacer(),
              Text(
                '$count tarefa${count == 1 ? '' : 's'}',
                style: tt.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Estado vazio
// ---------------------------------------------------------------------------

class _EmptyDashboard extends StatelessWidget {
  const _EmptyDashboard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 72,
            color: cs.onSurfaceVariant.withAlpha(102),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma tarefa ainda.',
            style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            'Crie tarefas para ver as estatísticas aqui.',
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant.withAlpha(178),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Modelo de estatísticas computado a partir da lista de tarefas
// ---------------------------------------------------------------------------

class _TaskStats {
  const _TaskStats({
    required this.total,
    required this.completed,
    required this.pending,
    required this.overdue,
  });

  factory _TaskStats.from(List<Task> tasks) {
    final completed = tasks.where((t) => t.isCompleted).length;
    final overdue = tasks.where((t) => t.isOverdue).length;
    return _TaskStats(
      total: tasks.length,
      completed: completed,
      pending: tasks.length - completed,
      overdue: overdue,
    );
  }

  final int total;
  final int completed;
  final int pending;
  final int overdue;

  double get completionRate => total > 0 ? completed / total : 0.0;
}
