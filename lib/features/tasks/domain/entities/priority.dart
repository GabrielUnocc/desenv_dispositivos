/// Enum de prioridade — domínio puro, sem dependência de Flutter.
/// O índice (0, 1, 2) é o valor persistido no banco.
/// Propriedades visuais (cor, ícone) ficam em extensões na camada de apresentação.
enum Priority {
  low,
  medium,
  high;

  /// Converte o int armazenado no banco de volta para o enum.
  static Priority fromValue(int value) {
    return Priority.values[value.clamp(0, Priority.values.length - 1)];
  }
}
