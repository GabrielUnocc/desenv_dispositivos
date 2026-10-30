import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        actions: [
          if (provider.hasActiveFilters)
            IconButton(
              icon: const Icon(Icons.filter_alt_off),
              tooltip: 'Limpar filtros',
              onPressed: () {
                provider.clearFilters();
                _searchController.clear();
              },
            ),
          IconButton(
            icon: Icon(
              themeProvider.isDark ? Icons.light_mode : Icons.dark_mode,
            ),
            tooltip: themeProvider.isDark ? 'Tema claro' : 'Tema escuro',
            onPressed: themeProvider.toggle,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(provider),
          _buildFilterRow(provider),
          Expanded(child: _buildTaskList(provider)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nova tarefa',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TaskFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar(TaskProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar tarefas...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    provider.setSearchQuery('');
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: provider.setSearchQuery,
      ),
    );
  }

  Widget _buildFilterRow(TaskProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          for (final status in TaskStatusFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                label: Text(_statusLabel(status)),
                selected: provider.statusFilter == status,
                onSelected: (_) => provider.setStatusFilter(status),
              ),
            ),
          _divider(),
          for (final cat in Category.values)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                avatar: Icon(_categoryIcon(cat), size: 16),
                label: Text(cat.label),
                selected: provider.categoryFilter == cat,
                onSelected: (selected) =>
                    provider.setCategoryFilter(selected ? cat : null),
              ),
            ),
          _divider(),
          for (final pri in Priority.values)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                label: Text(pri.label),
                selected: provider.priorityFilter == pri,
                onSelected: (selected) =>
                    provider.setPriorityFilter(selected ? pri : null),
              ),
            ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 28,
        margin: const EdgeInsets.only(right: 8),
        color: Colors.grey.shade300,
      );

  Widget _buildTaskList(TaskProvider provider) {
    final tasks = provider.filteredTasks;

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              provider.hasActiveFilters
                  ? Icons.search_off
                  : Icons.checklist_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              provider.hasActiveFilters
                  ? 'Nenhuma tarefa encontrada\npara os filtros aplicados.'
                  : 'Nenhuma tarefa ainda.\nToque em + para criar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: tasks.length,
      itemBuilder: (_, index) => TaskCard(task: tasks[index]),
    );
  }

  String _statusLabel(TaskStatusFilter s) => switch (s) {
        TaskStatusFilter.all => 'Todas',
        TaskStatusFilter.pending => 'Pendentes',
        TaskStatusFilter.completed => 'Concluídas',
      };

  IconData _categoryIcon(Category cat) => switch (cat) {
        Category.work => Icons.work_outline,
        Category.study => Icons.school_outlined,
        Category.personal => Icons.person_outline,
      };
}
