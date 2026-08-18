import 'package:flutter/material.dart';

import '../../features/tasks/domain/entities/priority.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

/// Propriedades visuais do enum [Priority] — separadas do domínio puro.
extension PriorityExt on Priority {
  Color get color => switch (this) {
        Priority.high => AppColors.priorityHigh,
        Priority.medium => AppColors.priorityMedium,
        Priority.low => AppColors.priorityLow,
      };

  IconData get icon => switch (this) {
        Priority.high => Icons.keyboard_double_arrow_up_rounded,
        Priority.medium => Icons.remove_rounded,
        Priority.low => Icons.keyboard_double_arrow_down_rounded,
      };

  String get label => switch (this) {
        Priority.high => AppStrings.priorityHigh,
        Priority.medium => AppStrings.priorityMedium,
        Priority.low => AppStrings.priorityLow,
      };
}
