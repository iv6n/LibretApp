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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
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
  bool _animals = true;
  bool _ubicaciones = true;
  bool _eventos = true;

  bool get _allSelected => _animals && _ubicaciones && _eventos;

  /// `true` when every section is selected, `false` when none are, and
  /// `null` (indeterminate) when the selection is mixed.
  bool? get _allSelectedState {
    if (_allSelected) return true;
    if (!_animals && !_ubicaciones && !_eventos) return false;
    return null;
  }

  void _toggleAll(bool? value) {
    final checked = value ?? false;
    setState(() {
      _animals = checked;
      _ubicaciones = checked;
      _eventos = checked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExportCubit, ExportState>(
      builder: (context, state) {
        final loading = state is ExportLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CheckboxListTile(
              title: const Text('Seleccionar todo'),
              value: _allSelectedState,
              tristate: true,
              onChanged: loading ? null : _toggleAll,
            ),
            const Divider(height: 1),
            CheckboxListTile(
              secondary: const Icon(Icons.pets_outlined),
              title: const Text('Animales'),
              subtitle: const Text('Caravana, especie, edad, peso, estado…'),
              value: _animals,
              onChanged: loading
                  ? null
                  : (v) => setState(() => _animals = v ?? false),
            ),
            CheckboxListTile(
              secondary: const Icon(Icons.map_outlined),
              title: const Text('Ubicaciones'),
              subtitle: const Text('Nombre, tipo, superficie, capacidad…'),
              value: _ubicaciones,
              onChanged: loading
                  ? null
                  : (v) => setState(() => _ubicaciones = v ?? false),
            ),
            CheckboxListTile(
              secondary: const Icon(Icons.event_outlined),
              title: const Text('Agenda'),
              subtitle: const Text('Título, fecha, tipo, animal vinculado…'),
              value: _eventos,
              onChanged: loading
                  ? null
                  : (v) => setState(() => _eventos = v ?? false),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: loading || !(_animals || _ubicaciones || _eventos)
                  ? null
                  : () => context.read<ExportCubit>().export(
                      animals: _animals,
                      ubicaciones: _ubicaciones,
                      eventos: _eventos,
                    ),
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
}
