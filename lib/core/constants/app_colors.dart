import 'package:flutter/material.dart';

/// Paleta de cores centralizada do aplicativo.
/// O Material 3 gera a paleta completa a partir de [seed],
/// mas cores específicas de domínio (prioridade, categoria) ficam aqui.
class AppColors {
  AppColors._();

  // Semente do ColorScheme — gera toda a paleta Material 3 automaticamente
  static const Color seed = Color(0xFF4A6CF7);

  // Prioridades
  static const Color priorityHigh = Color(0xFFE53935);
  static const Color priorityMedium = Color(0xFFFB8C00);
  static const Color priorityLow = Color(0xFF43A047);

  // Cores padrão das categorias
  static const Color categoryWork = Color(0xFF1565C0);
  static const Color categoryStudy = Color(0xFF6A1B9A);
  static const Color categoryPersonal = Color(0xFF00838F);
  static const Color categoryShopping = Color(0xFF2E7D32);
  static const Color categoryHealth = Color(0xFFC62828);

  // Paleta de cores disponíveis para o usuário criar categorias
  static const List<Color> categoryPalette = [
    Color(0xFF1565C0),
    Color(0xFF6A1B9A),
    Color(0xFF00838F),
    Color(0xFF2E7D32),
    Color(0xFFC62828),
    Color(0xFFE65100),
    Color(0xFF4527A0),
    Color(0xFF00695C),
    Color(0xFF4E342E),
    Color(0xFF37474F),
  ];
}
