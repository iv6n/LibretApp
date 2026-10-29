library;

import 'package:flutter/material.dart';
import 'package:libretapp/app/widgets/app_bottom_sheet.dart';
import 'package:libretapp/core/widgets/widgets.dart';
import 'package:libretapp/theme/app_theme.dart';

class AnimalQuickAction {
  const AnimalQuickAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
}

class QuickActionsFab extends StatelessWidget {
  const QuickActionsFab({super.key, required this.actions});
  final List<AnimalQuickAction> actions;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();
    return FloatingActionButton.extended(
      heroTag: 'animal-register',
      tooltip: 'Registrar actividad del animal',
      icon: const Icon(Icons.add),
      label: const Text('Registrar'),
      onPressed: () => showAppBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        builder: (sheetContext) => ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.85,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              const AppPageHeader(title: 'Registrar actividad'),
              const SizedBox(height: AppSpacing.sm),
              for (final action in actions)
                ListTile(
                  minTileHeight: 56,
                  leading: Icon(
                    action.icon,
                    color: Theme.of(sheetContext).colorScheme.primary,
                  ),
                  title: Text(action.label),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    action.onPressed();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
