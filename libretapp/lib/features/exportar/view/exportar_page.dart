/// features › exportar › view › exportar_page — UI for selecting and exporting data.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/services/export_service.dart';
import 'package:libretapp/features/exportar/cubit/export_cubit.dart';
import 'package:libretapp/features/exportar/cubit/export_state.dart';
import 'package:share_plus/share_plus.dart';

class ExportarPage extends StatelessWidget {
  const ExportarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExportCubit(locator<ExportService>()),
      child: const _ExportarView(),
    );
  }
}

class _ExportarView extends StatefulWidget {
  const _ExportarView();

  @override
  State<_ExportarView> createState() => _ExportarViewState();
}

class _ExportarViewState extends State<_ExportarView> {
  bool _animals = true;
  bool _ubicaciones = true;
  bool _eventos = true;

  bool get _allSelected => _animals && _ubicaciones && _eventos;

  void _toggleAll(bool? value) {
    final checked = value ?? false;
    setState(() {
      _animals = checked;
      _ubicaciones = checked;
      _eventos = checked;
    });
  }

  Future<void> _share(String filePath) async {
    await Share.shareXFiles([
      XFile(
        filePath,
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      ),
    ], subject: 'LibretApp – exportación de datos');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExportCubit, ExportState>(
      listener: (context, state) {
        if (state is ExportSuccess) {
          _share(state.filePath);
          context.read<ExportCubit>().reset();
        } else if (state is ExportError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          context.read<ExportCubit>().reset();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Exportar a Excel')),
        body: BlocBuilder<ExportCubit, ExportState>(
          builder: (context, state) {
            final isLoading = state is ExportLoading;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Selecciona qué datos exportar',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Se generará un archivo .xlsx con una hoja por cada sección seleccionada. '
                  'Luego podrás compartirlo por WhatsApp, Telegram, correo u otras apps.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      CheckboxListTile(
                        title: const Text('Seleccionar todo'),
                        value: _allSelected,
                        tristate: true,
                        onChanged: isLoading ? null : _toggleAll,
                      ),
                      const Divider(height: 1),
                      CheckboxListTile(
                        secondary: const Icon(Icons.pets_outlined),
                        title: const Text('Animales'),
                        subtitle: const Text(
                          'Caravana, especie, edad, peso, estado…',
                        ),
                        value: _animals,
                        onChanged: isLoading
                            ? null
                            : (v) => setState(() => _animals = v ?? false),
                      ),
                      CheckboxListTile(
                        secondary: const Icon(Icons.map_outlined),
                        title: const Text('Ubicaciones'),
                        subtitle: const Text(
                          'Nombre, tipo, superficie, capacidad…',
                        ),
                        value: _ubicaciones,
                        onChanged: isLoading
                            ? null
                            : (v) => setState(() => _ubicaciones = v ?? false),
                      ),
                      CheckboxListTile(
                        secondary: const Icon(Icons.event_outlined),
                        title: const Text('Agenda'),
                        subtitle: const Text(
                          'Título, fecha, tipo, animal vinculado…',
                        ),
                        value: _eventos,
                        onChanged: isLoading
                            ? null
                            : (v) => setState(() => _eventos = v ?? false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => context.read<ExportCubit>().export(
                            animals: _animals,
                            ubicaciones: _ubicaciones,
                            eventos: _eventos,
                          ),
                    icon: isLoading
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.table_chart_outlined),
                    label: Text(
                      isLoading ? 'Generando…' : 'Exportar y compartir',
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
