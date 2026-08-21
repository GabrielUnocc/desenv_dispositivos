import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/priority_ext.dart';
import '../../domain/entities/priority.dart';
import '../controllers/category_controller.dart';
import '../controllers/task_controller.dart';
import '../widgets/task_card.dart';

/// Tela principal: lista de tarefas com busca, filtros e ordenação.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskCtrl = context.watch<TaskController>();
    final catCtrl = context.watch<CategoryController>();
    final filtered = taskCtrl.filteredTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        actions: [
          // Botão de filtros avançados — badge indica filtro ativo
          Badge(
            isLabelVisible: taskCtrl.hasActiveFilters,
            child: IconButton(
              icon: const Icon(Icons.tune_rounded),
              tooltip: 'Filtros e ordenação',
              onPressed: () => _showFilterSheet(context, taskCtrl, catCtrl),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Dashboard',
            onPressed: () => context.push('/dashboard'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configurações',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          _SearchBar(controller: _searchController),
          _StatusFilterChips(taskCtrl: taskCtrl),
          Expanded(
            child: _TaskList(
              tasks: filtered,
              catCtrl: catCtrl,
              taskCtrl: taskCtrl,
              hasFilters: taskCtrl.hasActiveFilters ||
                  taskCtrl.searchQuery.isNotEmpty,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tasks/new'),
        tooltip: 'Nova tarefa',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterSheet(
    BuildContext context,
    TaskController taskCtrl,
    CategoryController catCtrl,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: taskCtrl,
        child: ChangeNotifierProvider.value(
          value: catCtrl,
          child: const _FilterSheet(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Barra de busca
// ---------------------------------------------------------------------------

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: controller,
        onChanged: context.read<TaskController>().setSearch,
        decoration: InputDecoration(
          hintText: 'Buscar tarefas…',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, _) => value.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      controller.clear();
                      context.read<TaskController>().setSearch('');
                    },
                  )
                : const SizedBox.shrink(),
          ),
          filled: true,
          fillColor: cs.surfaceContainerHighest,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chips de filtro de status (horizontal)
// ---------------------------------------------------------------------------

class _StatusFilterChips extends StatelessWidget {
  const _StatusFilterChips({required this.taskCtrl});
  final TaskController taskCtrl;

  static const _filters = [
    (TaskStatusFilter.all, 'Todas'),
    (TaskStatusFilter.pending, 'Pendentes'),
    (TaskStatusFilter.today, 'Hoje'),
    (TaskStatusFilter.overdue, 'Atrasadas'),
    (TaskStatusFilter.completed, 'Concluídas'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemCount: _filters.length,
        itemBuilder: (_, i) {
          final (filter, label) = _filters[i];
          final selected = taskCtrl.statusFilter == filter;
          return FilterChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => taskCtrl.setStatusFilter(filter),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Lista de tarefas (com estados vazios)
// ---------------------------------------------------------------------------

class _TaskList extends StatelessWidget {
  const _TaskList({
    required this.tasks,
    required this.catCtrl,
    required this.taskCtrl,
    required this.hasFilters,
  });

  final List tasks;
  final CategoryController catCtrl;
  final TaskController taskCtrl;
  final bool hasFilters;

  @override
  Widget build(BuildContext context) {
    if (taskCtrl.error != null) {
      return Center(
        child: Text(
          taskCtrl.error!,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
    }

    if (tasks.isEmpty) {
      return hasFilters ? const _EmptySearch() : const _EmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      itemCount: tasks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final task = tasks[i];
        final cat = catCtrl.findById(task.categoryId);
        return TaskCard(
          task: task,
          category: cat,
          onToggleCompleted: () => taskCtrl.toggleCompleted(task.id),
          onDelete: () => taskCtrl.deleteTask(task.id),
          onTap: () => context.push('/tasks/${task.id}'),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Estados vazios
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.task_alt_outlined, size: 72,
              color: cs.onSurfaceVariant.withAlpha(102)),
          const SizedBox(height: 16),
          Text('Nenhuma tarefa ainda.',
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text('Toque no + para criar sua primeira tarefa.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant.withAlpha(178))),
        ],
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 72,
              color: cs.onSurfaceVariant.withAlpha(102)),
          const SizedBox(height: 16),
          Text('Nenhum resultado.',
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: context.read<TaskController>().clearFilters,
            child: const Text('Limpar filtros'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom sheet de filtros avançados e ordenação
// ---------------------------------------------------------------------------

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context) {
    final taskCtrl = context.watch<TaskController>();
    final catCtrl = context.watch<CategoryController>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (_, scrollCtrl) => ListView(
        controller: scrollCtrl,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // Handle visual
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // --- Ordenação ---
          Text('Ordenar por', style: tt.titleSmall),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _SortChip(
                label: 'Mais recente',
                option: TaskSortOption.dateDesc,
                current: taskCtrl.sortOption,
                onTap: taskCtrl.setSortOption,
              ),
              _SortChip(
                label: 'Mais antiga',
                option: TaskSortOption.dateAsc,
                current: taskCtrl.sortOption,
                onTap: taskCtrl.setSortOption,
              ),
              _SortChip(
                label: 'Nome (A-Z)',
                option: TaskSortOption.nameAsc,
                current: taskCtrl.sortOption,
                onTap: taskCtrl.setSortOption,
              ),
              _SortChip(
                label: 'Prioridade',
                option: TaskSortOption.priorityDesc,
                current: taskCtrl.sortOption,
                onTap: taskCtrl.setSortOption,
              ),
            ],
          ),

          const Divider(height: 32),

          // --- Prioridade ---
          Text('Prioridade', style: tt.titleSmall),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: Priority.values.map((p) {
              final selected = taskCtrl.priorityFilter == p;
              return FilterChip(
                avatar: Icon(p.icon, size: 16, color: p.color),
                label: Text(p.label),
                selected: selected,
                showCheckmark: false,
                onSelected: (_) => taskCtrl.setPriorityFilter(
                  selected ? null : p,
                ),
              );
            }).toList(),
          ),

          const Divider(height: 32),

          // --- Categoria ---
          Text('Categoria', style: tt.titleSmall),
          const SizedBox(height: 10),
          catCtrl.categories.isEmpty
              ? Text('Nenhuma categoria cadastrada.',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant))
              : Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: catCtrl.categories.map((cat) {
                    final selected = taskCtrl.categoryFilter == cat.id;
                    return FilterChip(
                      avatar: CircleAvatar(
                        radius: 6,
                        backgroundColor: Color(cat.color),
                      ),
                      label: Text(cat.name),
                      selected: selected,
                      showCheckmark: false,
                      onSelected: (_) => taskCtrl.setCategoryFilter(
                        selected ? null : cat.id,
                      ),
                    );
                  }).toList(),
                ),

          const SizedBox(height: 24),

          // --- Limpar filtros ---
          if (taskCtrl.hasActiveFilters)
            OutlinedButton.icon(
              onPressed: () {
                taskCtrl.clearFilters();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.clear_all_rounded),
              label: const Text('Limpar todos os filtros'),
            ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.option,
    required this.current,
    required this.onTap,
  });

  final String label;
  final TaskSortOption option;
  final TaskSortOption current;
  final ValueChanged<TaskSortOption> onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: current == option,
      showCheckmark: false,
      onSelected: (_) => onTap(option),
    );
  }
}
