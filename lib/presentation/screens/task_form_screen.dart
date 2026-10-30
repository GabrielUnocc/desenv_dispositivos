import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late Category _category;
  late Priority _priority;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleController = TextEditingController(text: t?.title ?? '');
    _descriptionController = TextEditingController(text: t?.description ?? '');
    _category = t?.category ?? Category.personal;
    _priority = t?.priority ?? Priority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Nova Tarefa' : 'Editar Tarefa'),
        actions: [
          TextButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: const Text('Salvar'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título *',
                hintText: 'Ex: Estudar para a prova',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              autofocus: true,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'O título é obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                hintText: 'Detalhes opcionais...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            const _SectionLabel('Categoria'),
            const SizedBox(height: 8),
            SegmentedButton<Category>(
              segments: const [
                ButtonSegment(
                  value: Category.work,
                  label: Text('Trabalho'),
                  icon: Icon(Icons.work_outline),
                ),
                ButtonSegment(
                  value: Category.study,
                  label: Text('Estudo'),
                  icon: Icon(Icons.school_outlined),
                ),
                ButtonSegment(
                  value: Category.personal,
                  label: Text('Pessoal'),
                  icon: Icon(Icons.person_outline),
                ),
              ],
              selected: {_category},
              onSelectionChanged: (set) =>
                  setState(() => _category = set.first),
            ),
            const SizedBox(height: 24),
            const _SectionLabel('Prioridade'),
            const SizedBox(height: 8),
            SegmentedButton<Priority>(
              segments: const [
                ButtonSegment(value: Priority.high, label: Text('Alta')),
                ButtonSegment(value: Priority.medium, label: Text('Média')),
                ButtonSegment(value: Priority.low, label: Text('Baixa')),
              ],
              selected: {_priority},
              onSelectionChanged: (set) =>
                  setState(() => _priority = set.first),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final provider = context.read<TaskProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (widget.task != null) {
      await provider.updateTask(
        widget.task!.copyWith(
          title: title,
          description: description,
          category: _category,
          priority: _priority,
        ),
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('Tarefa atualizada!')),
      );
    } else {
      await provider.createTask(
        Task(
          title: title,
          description: description,
          category: _category,
          priority: _priority,
          createdAt: DateTime.now(),
        ),
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('Tarefa criada!')),
      );
    }

    navigator.pop();
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.labelLarge);
  }
}
