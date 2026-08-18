import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/theme_controller.dart';

/// Tela de configurações: seleção de tema (claro, escuro ou sistema).
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = context.watch<ThemeController>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.screenSettings)),
      body: ListView(
        children: [
          const _SectionHeader(label: AppStrings.settingsTheme),
          // RadioGroup gerencia o groupValue e onChanged para os RadioListTiles filhos.
          RadioGroup<ThemeMode>(
            groupValue: themeCtrl.themeMode,
            onChanged: (v) {
              if (v != null) themeCtrl.setThemeMode(v);
            },
            child: Column(
              children: const [
                RadioListTile<ThemeMode>(
                  title: Text(AppStrings.themeSystem),
                  secondary: Icon(Icons.brightness_auto_outlined),
                  value: ThemeMode.system,
                ),
                RadioListTile<ThemeMode>(
                  title: Text(AppStrings.themeLight),
                  secondary: Icon(Icons.light_mode_outlined),
                  value: ThemeMode.light,
                ),
                RadioListTile<ThemeMode>(
                  title: Text(AppStrings.themeDark),
                  secondary: Icon(Icons.dark_mode_outlined),
                  value: ThemeMode.dark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      );
}
