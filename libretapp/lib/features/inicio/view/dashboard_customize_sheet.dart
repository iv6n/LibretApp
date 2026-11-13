/// Sheet to customize dashboard widgets and quick actions.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/app/widgets/app_bottom_sheet.dart';
import 'package:libretapp/core/experience/care_profile.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/inicio/data/dashboard_config_repository.dart';
import 'package:libretapp/features/inicio/data/dashboard_quick_action.dart';
import 'package:libretapp/features/inicio/data/dashboard_widget_config.dart';
import 'package:libretapp/theme/app_theme.dart';

Future<void> showDashboardCustomizeSheet({
  required BuildContext context,
  required List<DashboardWidgetConfig> widgets,
  required List<DashboardQuickAction> actions,
  CareProfile? profile,
  required void Function(
    List<DashboardWidgetConfig>,
    List<DashboardQuickAction>,
  )
  onSaved,
}) {
  return showAppBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _DashboardCustomizeSheet(
      initialWidgets: List.of(widgets),
      initialActions: List.of(actions),
      profile: profile,
      onSaved: onSaved,
    ),
  );
}

class _DashboardCustomizeSheet extends StatefulWidget {
  const _DashboardCustomizeSheet({
    required this.initialWidgets,
    required this.initialActions,
    required this.profile,
    required this.onSaved,
  });

  final List<DashboardWidgetConfig> initialWidgets;
  final List<DashboardQuickAction> initialActions;
  final CareProfile? profile;
  final void Function(List<DashboardWidgetConfig>, List<DashboardQuickAction>)
  onSaved;

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
    _actions = List.of(widget.initialActions)
      ..sort((a, b) => a.order.compareTo(b.order));
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

  Future<void> _previewSuggestions() async {
    final suggestions = defaultQuickActions(profile: widget.profile);
    final selected = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Configuración sugerida'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Perfil: ${widget.profile?.label ?? 'General'}'),
              const SizedBox(height: 8),
              const Text('Accesos propuestos'),
              for (final action in suggestions)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(action.icon),
                  title: Text(action.label),
                ),
              const Text(
                'También se actualizará el orden y la visibilidad de los bloques de Inicio.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Aplicar sugerida'),
          ),
        ],
      ),
    );
    if (selected != true || !mounted) return;
    setState(() {
      _widgets = widgetsSorted(
        defaultDashboardWidgets(profile: widget.profile),
      );
      _actions = List.of(suggestions);
    });
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
                Expanded(
                  child: Text(
                    'Personalizar inicio',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  tooltip: 'Cerrar',
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _previewSuggestions,
                child: const Text('Aplicar configuración sugerida'),
              ),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        'Bloques de Inicio',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ),
                  SliverReorderableList(
                    itemCount: _widgets.length,
                    onReorderItem: (oldIndex, newIndex) {
                      setState(() {
                        final item = _widgets.removeAt(oldIndex);
                        _widgets.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      final w = _widgets[index];
                      final pendingEnabled = _widgets.any(
                        (item) =>
                            item.type == DashboardWidgetType.pendingTasks &&
                            item.enabled,
                      );
                      return SwitchListTile(
                        key: ValueKey('widget-${w.id}'),
                        title: Text(w.title),
                        subtitle: w.type == DashboardWidgetType.weather
                            ? const Text('Siempre visible en la parte superior')
                            : w.type == DashboardWidgetType.pendingTasks ||
                                  w.type == DashboardWidgetType.animalSummary
                            ? const Text('Tarjeta principal')
                            : w.type == DashboardWidgetType.healthAlerts &&
                                  pendingEnabled
                            ? const Text('Incluidas en Pendientes')
                            : null,
                        value: w.type == DashboardWidgetType.weather
                            ? true
                            : w.enabled,
                        secondary: w.type == DashboardWidgetType.weather
                            ? const Icon(Icons.push_pin_outlined)
                            : ReorderableDragStartListener(
                                index: index,
                                child: Tooltip(
                                  message: 'Reordenar ${w.title}',
                                  child: const Icon(Icons.drag_handle),
                                ),
                              ),
                        onChanged: w.type == DashboardWidgetType.weather
                            ? null
                            : (value) {
                                setState(() {
                                  _widgets[index] = w.copyWith(enabled: value);
                                });
                              },
                      );
                    },
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: Text(
                        'Accesos rápidos',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ),
                  SliverReorderableList(
                    itemCount: _actions.length,
                    onReorderItem: (oldIndex, newIndex) {
                      setState(() {
                        final item = _actions.removeAt(oldIndex);
                        _actions.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      final action = _actions[index];
                      return SwitchListTile(
                        key: ValueKey('action-${action.id}'),
                        title: Text(action.label),
                        subtitle:
                            action.routeName == AppRoutes.nameAnimalNuevoRapido
                            ? const Text('El alta se muestra en Registrar')
                            : null,
                        value: action.enabled,
                        secondary: ReorderableDragStartListener(
                          index: index,
                          child: Tooltip(
                            message: 'Reordenar ${action.label}',
                            child: const Icon(Icons.drag_handle),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _actions[index] = action.copyWith(enabled: value);
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            FilledButton(onPressed: _save, child: const Text('Guardar')),
          ],
        ),
      ),
    );
  }
}
