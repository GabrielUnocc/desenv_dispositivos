import 'package:equatable/equatable.dart';

/// Entidade de domínio para categoria.
/// [color] é o ARGB como inteiro — a apresentação converte para Color.
class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.color,
  });

  final int id;
  final String name;

  /// Cor armazenada como inteiro ARGB (ex.: 0xFF1565C0).
  final int color;

  Category copyWith({int? id, String? name, int? color}) => Category(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color ?? this.color,
      );

  @override
  List<Object?> get props => [id, name, color];
}
