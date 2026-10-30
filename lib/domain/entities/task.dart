enum Category {
  work,
  study,
  personal;

  String get label => switch (this) {
        Category.work => 'Trabalho',
        Category.study => 'Estudo',
        Category.personal => 'Pessoal',
      };
}

enum Priority {
  high,
  medium,
  low;

  String get label => switch (this) {
        Priority.high => 'Alta',
        Priority.medium => 'Média',
        Priority.low => 'Baixa',
      };
}

class Task {
  final int? id;
  final String title;
  final String description;
  final Category category;
  final Priority priority;
  final bool isCompleted;
  final DateTime createdAt;

  const Task({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    this.isCompleted = false,
    required this.createdAt,
  });

  Task copyWith({
    int? id,
    String? title,
    String? description,
    Category? category,
    Priority? priority,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
