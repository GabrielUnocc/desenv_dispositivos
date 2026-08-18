import 'package:intl/intl.dart';

/// Utilitários de formatação de datas para a camada de apresentação.
class DateFormatter {
  DateFormatter._();

  static final _fmt = DateFormat('dd/MM/yyyy');

  static String format(DateTime date) => _fmt.format(date);

  /// Retorna 'Hoje', 'Amanhã', 'Ontem', 'Atrasada Xd' ou a data formatada.
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = d.difference(today).inDays;

    if (diff == 0) return 'Hoje';
    if (diff == 1) return 'Amanhã';
    if (diff == -1) return 'Ontem';
    if (diff < -1) return 'Atrasada ${-diff}d';
    return _fmt.format(date);
  }
}
