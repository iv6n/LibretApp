/// features \u203a perfil \u203a view \u203a perfil_view \u2014 main view for the user profile.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/app/theme/theme_bloc.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/services/backup_service.dart';
import 'package:libretapp/core/services/export_service.dart';
import 'package:libretapp/features/exportar/cubit/export_cubit.dart';
import 'package:libretapp/features/exportar/cubit/export_state.dart';
import 'package:libretapp/features/perfil/bloc/perfil_bloc.dart';
import 'package:libretapp/features/perfil/bloc/perfil_state.dart';
import 'package:libretapp/features/perfil/widgets/widgets.dart';
import 'package:share_plus/share_plus.dart';

class PerfilView extends StatelessWidget {
  const PerfilView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = ShellInsets.bottomSafePadding(context);

    return BlocBuilder<PerfilBloc, PerfilState>(
      builder: (context, state) {
        if (state is PerfilLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PerfilLoaded || state is PerfilUpdated) {
          final perfil = state is PerfilLoaded
              ? state.perfil
              : (state as PerfilUpdated).perfil;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 2),
            child: Column(
              children: [
                const ProfileAvatar(),
                const SizedBox(height: 16),
                Text(
                  '${perfil.nombre} ${perfil.apellido}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                ProfileField(label: 'Email', value: perfil.email),
                const SizedBox(height: 16),
                ProfileField(label: 'Teléfono', value: perfil.telefono),
                const SizedBox(height: 16),
                ProfileField(label: 'Finca', value: perfil.finca),
                const SizedBox(height: 16),
                ProfileField(label: 'Dirección', value: perfil.direccion),
                const SizedBox(height: 32),
                const _ThemeToggleTile(),
                const SizedBox(height: 16),
                const _BackupActionsSection(),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Editar Perfil'),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is PerfilError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _ThemeToggleTile extends StatelessWidget {
  const _ThemeToggleTile();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isDark = state.themeMode == ThemeMode.dark;
        return SwitchListTile(
          title: const Text('Tema oscuro'),
          subtitle: const Text('Activa o desactiva el modo oscuro'),
          value: isDark,
          onChanged: (_) => context.read<ThemeBloc>().add(
            ThemeModeChanged(isDark ? ThemeMode.light : ThemeMode.dark),
          ),
        );
      },
    );
  }
}

class _BackupActionsSection extends StatelessWidget {
  const _BackupActionsSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Respaldo de datos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Exporta o importa animales y lotes en formato JSON.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _handleExport(context),
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('Exportar datos'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _handleImport(context),
              icon: const Icon(Icons.download_for_offline_outlined),
              label: const Text('Importar datos'),
            ),
            const _ExportarSection(),
          ],
        ),
      ),
    );
  }

  Future<void> _handleExport(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final service = locator<BackupService>();

    try {
      final path = await service.exportToFile();
      if (!context.mounted) {
        return;
      }
      if (path == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Exportacion cancelada.')),
        );
        return;
      }
      messenger.showSnackBar(
        SnackBar(content: Text('Respaldo exportado en: $path')),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      messenger.showSnackBar(SnackBar(content: Text('Error al exportar: $e')));
    }
  }

  Future<void> _handleImport(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final service = locator<BackupService>();

    final mode = await _askImportMode(context);
    if (mode == null || !context.mounted) {
      return;
    }

    try {
      final summary = await service.importFromFile(mode: mode);
      if (!context.mounted) {
        return;
      }
      if (summary == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Importacion cancelada.')),
        );
        return;
      }

      final modeLabel = summary.mode == BackupImportMode.merge
          ? 'mezcla'
          : 'reemplazo total';
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Importacion completada ($modeLabel): ${summary.animalsImported} animales, ${summary.lotesImported} lotes.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      messenger.showSnackBar(SnackBar(content: Text('Error al importar: $e')));
    }
  }

  Future<BackupImportMode?> _askImportMode(BuildContext context) {
    return showDialog<BackupImportMode>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Modo de importacion'),
          content: const Text(
            'Elige como aplicar el respaldo:\n\n'
            '- Mezclar: actualiza por UUID y conserva datos locales no presentes.\n'
            '- Reemplazar todo: elimina animales/lotes locales e importa desde el archivo.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(BackupImportMode.merge),
              child: const Text('Mezclar'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(BackupImportMode.replaceAll),
              child: const Text('Reemplazar todo'),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Inline Excel export section
// ---------------------------------------------------------------------------

class _ExportarSection extends StatefulWidget {
  const _ExportarSection();

  @override
  State<_ExportarSection> createState() => _ExportarSectionState();
}

class _ExportarSectionState extends State<_ExportarSection> {
  bool _animals = true;
  bool _ubicaciones = true;
  bool _eventos = true;

  bool get _allSelected => _animals && _ubicaciones && _eventos;
  bool get _anySelected => _animals || _ubicaciones || _eventos;

  void _toggleAll(bool? value) {
    final checked = value ?? false;
    setState(() {
      _animals = checked;
      _ubicaciones = checked;
      _eventos = checked;
    });
  }

  Future<void> _shareFile(File file) async {
    await Share.shareXFiles([
      XFile(
        file.path,
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      ),
    ], subject: 'LibretApp – exportación de datos');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExportCubit(locator<ExportService>()),
      child: BlocListener<ExportCubit, ExportState>(
        listener: (context, state) {
          if (state is ExportSuccess) {
            _shareFile(state.file);
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
        child: BlocBuilder<ExportCubit, ExportState>(
          builder: (context, state) {
            final isLoading = state is ExportLoading;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Divider(height: 24),
                Row(
                  children: [
                    const Icon(Icons.table_chart_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Exportar a Excel',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Selecciona qué datos incluir. Se generará un .xlsx que podrás '
                  'compartir por WhatsApp, Telegram, correo u otras apps.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Seleccionar todo'),
                  tristate: true,
                  value: _allSelected
                      ? true
                      : _anySelected
                      ? null
                      : false,
                  onChanged: isLoading ? null : _toggleAll,
                ),
                CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.pets_outlined, size: 20),
                  title: const Text('Animales'),
                  value: _animals,
                  onChanged: isLoading
                      ? null
                      : (v) => setState(() => _animals = v ?? false),
                ),
                CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.map_outlined, size: 20),
                  title: const Text('Ubicaciones'),
                  value: _ubicaciones,
                  onChanged: isLoading
                      ? null
                      : (v) => setState(() => _ubicaciones = v ?? false),
                ),
                CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.event_outlined, size: 20),
                  title: const Text('Eventos'),
                  value: _eventos,
                  onChanged: isLoading
                      ? null
                      : (v) => setState(() => _eventos = v ?? false),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () => context.read<ExportCubit>().export(
                          animals: _animals,
                          ubicaciones: _ubicaciones,
                          eventos: _eventos,
                        ),
                  icon: isLoading
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.ios_share_outlined),
                  label: Text(
                    isLoading ? 'Generando…' : 'Exportar y compartir',
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
