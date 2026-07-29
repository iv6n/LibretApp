/// Sheet to customize dashboard widgets and quick actions.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/inicio/data/dashboard_config_repository.dart';
import 'package:libretapp/features/inicio/data/dashboard_quick_action.dart';
import 'package:libretapp/features/inicio/data/dashboard_widget_config.dart';
import 'package:libretapp/theme/app_theme.dart';

Future<void> showDashboardCustomizeSheet({
  required BuildContext context,
  required List<DashboardWidgetConfig> widgets,
  required List<DashboardQuickAction> actions,
  required void Function(
    List<DashboardWidgetConfig>,
    List<DashboardQuickAction>,
  ) onSaved,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _DashboardCustomizeSheet(
      initialWidgets: List.of(widgets),
      initialActions: List.of(actions),
      onSaved: onSaved,
    ),
  );
}

class _DashboardCustomizeSheet extends StatefulWidget {
  const _DashboardCustomizeSheet({
    required this.initialWidgets,
    required this.initialActions,
    required this.onSaved,
  });

  final List<DashboardWidgetConfig> initialWidgets;
  final List<DashboardQuickAction> initialActions;
  final void Function(
    List<DashboardWidgetConfig>,
    List<DashboardQuickAction>,
  ) onSaved;

  @override
  State<_DashboardCustomizeSheet> createState() =>
      _DashboardCustomizeSheetState();
}

class _DashboardCustomizeSheetState extends State<_DashboardCustomizeSheet> {
  late List<DashboardWidgetConfig> _widgets;
  late List<DashboardQuickAction> _actions;

  @override
  void initState() {
    super.initState();
    _widgets = List.of(widgetsSorted(widget.initialWidgets));
    _actions = List.of(widget.initialActions)..sort((a, b) => a.order.compareTo(b.order));
  }

  List<DashboardWidgetConfig> widgetsSorted(List<DashboardWidgetConfig> list) {
    return List.of(list)..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<void> _save() async {
    final repo = locator<DashboardConfigRepository>();
    for (var i = 0; i < _widgets.length; i++) {
      _widgets[i] = _widgets[i].copyWith(order: i);
    }
    for (var i = 0; i < _actions.length; i++) {
      _actions[i] = _actions[i].copyWith(order: i);
    }
    await repo.saveWidgets(_widgets);
    await repo.saveQuickActions(_actions);
    widget.onSaved(_widgets, _actions);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _reset() async {
    final repo = locator<DashboardConfigRepository>();
    await repo.resetToDefaults();
    _widgets = widgetsSorted(defaultDashboardWidgets());
    _actions = List.of(defaultQuickActions());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.75;

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Personalizar inicio',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                TextButton(onPressed: _reset, child: const Text('Restablecer')),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Text(
              'Widgets del dashboard',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Expanded(
              flex: 3,
              child: ReorderableListView.builder(
                itemCount: _widgets.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = _widgets.removeAt(oldIndex);
                    _widgets.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final w = _widgets[index];
                  return SwitchListTile(
                    key: ValueKey(w.id),
                    title: Text(w.title),
                    value: w.enabled,
                    secondary: const Icon(Icons.drag_handle),
                    onChanged: (v) {
                      setState(() {
                        _widgets[index] = w.copyWith(enabled: v);
                      });
                    },
                  );
                },
              ),
            ),
            Text(
              'Accesos rápidos',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Expanded(
              flex: 2,
              child: ReorderableListView.builder(
                itemCount: _actions.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = _actions.removeAt(oldIndex);
                    _actions.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final a = _actions[index];
                  return SwitchListTile(
                    key: ValueKey(a.id),
                    title: Text(a.label),
                    value: a.enabled,
                    secondary: const Icon(Icons.drag_handle),
                    onChanged: (v) {
                      setState(() {
                        _actions[index] = a.copyWith(enabled: v);
                      });
                    },
                  );
                },
              ),
            ),
            FilledButton(onPressed: _save, child: const Text('Guardar')),
          ],
        ),
      ),
    );
  }
}
