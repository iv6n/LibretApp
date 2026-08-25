/// features › exportar › widgets › export_selection_panel — shared section/export
/// picker UI for [ExportCubit], used by both the full export page and the
/// quick-export block in Perfil settings so the two don't drift.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/exportar/cubit/export_cubit.dart';
import 'package:libretapp/features/exportar/cubit/export_state.dart';
import 'package:share_plus/share_plus.dart';

/// Shares the exported file on [ExportSuccess], shows a snackbar on
/// [ExportError], and resets the cubit afterwards either way. Assumes an
/// ancestor `BlocProvider<ExportCubit>`.
class ExportResultListener extends StatelessWidget {
  const ExportResultListener({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExportCubit, ExportState>(
      listener: (context, state) {
        if (state is ExportSuccess) {
          Share.shareXFiles([XFile(state.filePath)]);
          context.read<ExportCubit>().reset();
        } else if (state is ExportError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          context.read<ExportCubit>().reset();
        }
      },
      child: child,
    );
  }
}

/// Section checkboxes (animals/ubicaciones/eventos) plus the export button.
/// Assumes an ancestor `BlocProvider<ExportCubit>`.
class ExportSelectionPanel extends StatefulWidget {
  const ExportSelectionPanel({super.key});

  @override
  State<ExportSelectionPanel> createState() => _ExportSelectionPanelState();
}

class _ExportSelectionPanelState extends State<ExportSelectionPanel> {
  Set<String>? _selectedKeys;

  bool _allSelected(int total) => _selectedKeys?.length == total;

  /// `true` when every section is selected, `false` when none are, and
  /// `null` (indeterminate) when the selection is mixed.
  bool? _allSelectedState(int total) {
    if (_allSelected(total)) return true;
    if (_selectedKeys?.isEmpty ?? true) return false;
    return null;
  }

  void _toggleAll(bool? value, Set<String> allKeys) {
    final checked = value ?? false;
    setState(() {
      _selectedKeys = checked ? Set.of(allKeys) : <String>{};
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExportCubit, ExportState>(
      builder: (context, state) {
        final loading = state is ExportLoading;
        final exportCubit = context.read<ExportCubit>();
        final sheets = exportCubit.sheets;
        final allKeys = sheets.map((sheet) => sheet.key).toSet();
        _selectedKeys ??= Set.of(allKeys);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CheckboxListTile(
              title: const Text('Seleccionar todo'),
              value: _allSelectedState(sheets.length),
              tristate: true,
              onChanged: loading ? null : (value) => _toggleAll(value, allKeys),
            ),
            const Divider(height: 1),
            for (final sheet in sheets)
              CheckboxListTile(
                secondary: Icon(_iconFor(sheet.key)),
                title: Text(sheet.title),
                subtitle: Text(sheet.description),
                value: _selectedKeys!.contains(sheet.key),
                onChanged: loading
                    ? null
                    : (value) => setState(() {
                        if (value ?? false) {
                          _selectedKeys!.add(sheet.key);
                        } else {
                          _selectedKeys!.remove(sheet.key);
                        }
                      }),
              ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: loading || _selectedKeys!.isEmpty
                  ? null
                  : () => exportCubit.export(Set.of(_selectedKeys!)),
              icon: loading
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.ios_share_outlined),
              label: Text(loading ? 'Generando…' : 'Exportar y compartir'),
            ),
          ],
        );
      },
    );
  }

  IconData _iconFor(String key) => switch (key) {
    'animals' => Icons.pets_outlined,
    'locations' => Icons.map_outlined,
    'events' => Icons.event_outlined,
    'weights' => Icons.monitor_weight_outlined,
    'health' => Icons.medical_services_outlined,
    'reproduction' => Icons.favorite_outline,
    'movements' => Icons.route_outlined,
    'costs' || 'finances' => Icons.payments_outlined,
    'commercial' => Icons.store_outlined,
    'production' => Icons.insights_outlined,
    'milking' => Icons.water_drop_outlined,
    _ => Icons.table_chart_outlined,
  };
}
