import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:gerenciador_tarefas/core/theme/app_theme.dart';
import 'package:gerenciador_tarefas/core/theme/theme_controller.dart';

void main() {
  testWidgets('App renderiza com tema Material 3', (WidgetTester tester) async {
    final themeController = ThemeController();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: themeController,
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeController.themeMode,
          home: const Scaffold(body: Text('Teste')),
        ),
      ),
    );

    expect(find.text('Teste'), findsOneWidget);
  });
}
