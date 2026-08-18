import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/priority_ext.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/priority.dart';
import '../../domain/entities/task.dart';
import '../controllers/category_controller.dart';
import '../controllers/task_controller.dart';

/// Formulário de criação e edição de tarefas.
/// [taskId] null = criar; não-nulo = editar a tarefa existente.
class TaskFormPage extends StatefulWidget {
  const TaskFormPage({super.key, this.taskId});

  final int? taskId;

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  int? _categoryId;
  Priority _priority = Priority.medium;
  DateTime? _dueDate;
  bool _initialized = false;
  bool _saving = false;

  bool get _isEditing => widget.taskId != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    if (_isEditing) {
      final task = context.read<TaskController>().findById(widget.taskId!);
      if (task != null) {
        _titleCtrl.text = task.title;
        _descCtrl.text = task.description ?? '';
        _categoryId = task.categoryId;
        _priority = task.priority;
        _dueDate = task.dueDate;
      }
    } else {
      final cats = context.read<CategoryController>().categories;
      if (cats.isNotEmpty) _categoryId = cats.first.id;
    }

    _initialized = true;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(AppStrings.validationCategoryRequired)),
      );
      return;
    }

    setState(() => _saving = true);
    final ctrl = context.read<TaskController>();

    try {
      final desc = _descCtrl.text.trim().isEmpty
          ? null
          : _descCtrl.text.trim();

      if (_isEditing) {
        final existing = ctrl.findById(widget.taskId!);
        if (existing == null) return;
        await ctrl.updateTask(
          existing.copyWith(
            title: _titleCtrl.text.trim(),
            description: desc,
            categoryId: _categoryId,
            priority: _priority,
            dueDate: _dueDate,
          ),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.taskUpdated)),
          );
          context.pop();
        }
      } else {
        await ctrl.createTask(
          Task(
            id: 0,
            title: _titleCtrl.text.trim(),
            description: desc,
            categoryId: _categoryId!,
            priority: _priority,
            createdAt: DateTime.now(),
            dueDate: _dueDate,
            isCompleted: false,
            isFavorite: false,
          ),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.taskCreated)),
          );
          context.pop();
        }
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final cats = context.watch<CategoryController>().categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            _isEditing ? AppStrings.screenEditTask : AppStrings.screenNewTask),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Título *',
                hintText: 'Ex.: Revisar relatório',
              ),
              textCapitalization: TextCapitalization.sentences,
              autofocus: !_isEditing,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? AppStrings.validationTitleEmpty
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                hintText: 'Detalhes opcionais...',
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            _SectionLabel(label: 'Categoria *'),
            const SizedBox(height: 8),
            _CategorySelector(
              categories: cats,
              selectedId: _categoryId,
              onChanged: (id) => setState(() => _categoryId = id),
            ),
            const SizedBox(height: 24),
            _SectionLabel(label: 'Prioridade'),
            const SizedBox(height: 8),
            _PrioritySelector(
              selected: _priority,
              onChanged: (p) => setState(() => _priority = p),
            ),
            const SizedBox(height: 24),
            _SectionLabel(label: 'Data limite'),
            const SizedBox(height: 8),
            _DatePickerTile(
              date: _dueDate,
              onPick: _pickDate,
              onClear: () => setState(() => _dueDate = null),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(AppStrings.actionSave),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets internos do formulário
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      );
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.categories,
    required this.selectedId,
    required this.onChanged,
  });

  final List<Category> categories;
  final int? selectedId;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Text('Nenhuma categoria disponível.');
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final cat in categories)
          ChoiceChip(
            label: Text(cat.name),
            selected: selectedId == cat.id,
            selectedColor: Color(cat.color).withAlpha(51),
            side: BorderSide(
              color: selectedId == cat.id
                  ? Color(cat.color)
                  : Theme.of(context).colorScheme.outlineVariant,
            ),
            labelStyle: TextStyle(
              color: selectedId == cat.id
                  ? Color(cat.color)
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: selectedId == cat.id
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
            onSelected: (_) => onChanged(cat.id),
          ),
      ],
    );
  }
}

class _PrioritySelector extends StatelessWidget {
  const _PrioritySelector({
    required this.selected,
    required this.onChanged,
  });

  final Priority selected;
  final ValueChanged<Priority> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: Priority.values.map((p) {
        final isSelected = selected == p;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    p.icon,
                    size: 14,
                    color: isSelected ? p.color : null,
                  ),
                  const SizedBox(width: 4),
                  Text(p.label),
                ],
              ),
              selected: isSelected,
              selectedColor: p.color.withAlpha(38),
              side: BorderSide(
                color: isSelected
                    ? p.color
                    : Theme.of(context).colorScheme.outlineVariant,
              ),
              labelStyle: TextStyle(
                color: isSelected
                    ? p.color
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              onSelected: (_) => onChanged(p),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  const _DatePickerTile({
    required this.date,
    required this.onPick,
    required this.onClear,
  });

  final DateTime? date;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                date != null
                    ? DateFormatter.format(date!)
                    : 'Sem data limite',
                style: TextStyle(
                  color: date != null
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (date != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
