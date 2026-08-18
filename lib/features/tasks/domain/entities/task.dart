import 'package:equatable/equatable.dart';

import 'priority.dart';

/// Entidade de domínio central do aplicativo.
/// Não conhece Flutter, banco de dados nem frameworks.
class Task extends Equatable {
  const Task({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.priority,
    required this.createdAt,
    required this.isCompleted,
    required this.isFavorite,
    this.description,
    this.dueDate,
  });

  final int id;
  final String title;
  final String? description;
  final int categoryId;
  final Priority priority;
  final DateTime createdAt;
  final DateTime? dueDate;
  final bool isCompleted;
  final bool isFavorite;

  /// Retorna true se a tarefa está atrasada (não concluída e passou do prazo).
  bool get isOverdue =>
      !isCompleted && dueDate != null && dueDate!.isBefore(DateTime.now());

  /// Retorna true se o prazo é hoje.
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    int? categoryId,
    Priority? priority,
    DateTime? createdAt,
    DateTime? dueDate,
    bool? isCompleted,
    bool? isFavorite,
  }) =>
      Task(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        categoryId: categoryId ?? this.categoryId,
        priority: priority ?? this.priority,
        createdAt: createdAt ?? this.createdAt,
        dueDate: dueDate ?? this.dueDate,
        isCompleted: isCompleted ?? this.isCompleted,
        isFavorite: isFavorite ?? this.isFavorite,
      );

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        categoryId,
        priority,
        createdAt,
        dueDate,
        isCompleted,
        isFavorite,
      ];
}
