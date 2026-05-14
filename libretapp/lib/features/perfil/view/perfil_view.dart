/// features \u203a perfil \u203a view \u203a perfil_view \u2014 main view for the user profile.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/app/theme/theme_bloc.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/core/services/backup_service.dart';
import 'package:libretapp/core/services/export_service.dart';
import 'package:libretapp/features/exportar/cubit/export_cubit.dart';
import 'package:libretapp/features/exportar/cubit/export_state.dart';
import 'package:libretapp/features/perfil/bloc/perfil_bloc.dart';
import 'package:libretapp/features/perfil/bloc/perfil_event.dart';
import 'package:libretapp/features/perfil/bloc/perfil_state.dart';
import 'package:libretapp/features/perfil/data/perfil_model.dart';
import 'package:libretapp/features/perfil/widgets/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class PerfilView extends StatelessWidget {
  const PerfilView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = ShellInsets.bottomSafePadding(context);

    return BlocBuilder<PerfilBloc, PerfilState>(
      builder: (context, state) {
        if (state is PerfilInitial || state is PerfilLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PerfilLoaded || state is PerfilUpdated) {
          final perfil = state is PerfilLoaded
              ? state.perfil
              : (state as PerfilUpdated).perfil;

          return CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _PersonalInfoSection(perfil: perfil),
                    const SizedBox(height: 24),
                    const _ThemeToggleTile(),
                    const SizedBox(height: 16),
                    const _JsonBackupCard(),
                    const SizedBox(height: 16),
                    const _ExcelExportCard(),
                  ]),
                ),
              ),
            ],
          );
        }

        if (state is PerfilError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No se pudo cargar el perfil.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () =>
                        context.read<PerfilBloc>().add(const LoadPerfil()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _PersonalInfoSection extends StatelessWidget {
  const _PersonalInfoSection({required this.perfil});

  final Perfil perfil;

  String _initials() {
    final n = perfil.nombre.isNotEmpty ? perfil.nombre[0] : '';
    final a = perfil.apellido.isNotEmpty ? perfil.apellido[0] : '';
    return (n + a).toUpperCase();
  }

  void _openEdit(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: context.read<PerfilBloc>(),
        child: _EditPerfilSheet(perfil: perfil),
      ),
    );
  }

  List<Widget> _buildTileWithDivider({
    required IconData icon,
    required String label,
    required String value,
    required bool isLast,
  }) {
    return [
      _InfoTile(icon: icon, label: label, value: value),
      if (!isLast) const Divider(height: 1, indent: 56),
    ];
  }

  List<Widget> _buildInfoTiles() {
    final tiles = <({IconData icon, String label, String value})>[];

    if (perfil.email.isNotEmpty) {
      tiles.add((
        icon: Icons.email_outlined,
        label: 'Email',
        value: perfil.email,
      ));
    }
    if (perfil.telefono.isNotEmpty) {
      tiles.add((
        icon: Icons.phone_outlined,
        label: 'Teléfono',
        value: perfil.telefono,
      ));
    }
    if (perfil.finca.isNotEmpty) {
      tiles.add((
        icon: Icons.grass_outlined,
        label: 'Finca',
        value: perfil.finca,
      ));
    }
    if (perfil.direccion.isNotEmpty) {
      tiles.add((
        icon: Icons.location_on_outlined,
        label: 'Dirección',
        value: perfil.direccion,
      ));
    }

    final widgets = <Widget>[];
    for (var i = 0; i < tiles.length; i++) {
      final tile = tiles[i];
      widgets.addAll(
        _buildTileWithDivider(
          icon: tile.icon,
          label: tile.label,
          value: tile.value,
          isLast: i == tiles.length - 1,
        ),
      );
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fullName = '${perfil.nombre} ${perfil.apellido}'.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: ProfileAvatar(initials: _initials())),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    fullName.isEmpty ? 'Sin nombre' : fullName,
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    iconSize: 20,
                    onPressed: () {
                      // Placeholder para ajustes futuros
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    iconSize: 20,
                    onPressed: () => _openEdit(context),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Card(child: Column(children: _buildInfoTiles())),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => context.go(AppRoutes.finanzas),
          icon: const Icon(Icons.account_balance_wallet_outlined),
          label: const Text('Abrir finanzas'),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmpty = value.isEmpty;
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label, style: theme.textTheme.labelSmall),
      subtitle: Text(
        isEmpty ? '—' : value,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isEmpty ? theme.colorScheme.outline : null,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Edit profile bottom sheet
// ---------------------------------------------------------------------------

class _EditPerfilSheet extends StatefulWidget {
  const _EditPerfilSheet({required this.perfil});

  final Perfil perfil;

  @override
  State<_EditPerfilSheet> createState() => _EditPerfilSheetState();
}

class _EditPerfilSheetState extends State<_EditPerfilSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _apellido;
  late final TextEditingController _email;
  late final TextEditingController _telefono;
  late final TextEditingController _finca;
  late final TextEditingController _direccion;

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.perfil.nombre);
    _apellido = TextEditingController(text: widget.perfil.apellido);
    _email = TextEditingController(text: widget.perfil.email);
    _telefono = TextEditingController(text: widget.perfil.telefono);
    _finca = TextEditingController(text: widget.perfil.finca);
    _direccion = TextEditingController(text: widget.perfil.direccion);
  }

  @override
  void dispose() {
    _nombre.dispose();
    _apellido.dispose();
    _email.dispose();
    _telefono.dispose();
    _finca.dispose();
    _direccion.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final updated = Perfil(
      id: widget.perfil.id,
      nombre: _nombre.text.trim(),
      apellido: _apellido.text.trim(),
      email: _email.text.trim(),
      telefono: _telefono.text.trim(),
      finca: _finca.text.trim(),
      direccion: _direccion.text.trim(),
    );
    context.read<PerfilBloc>().add(SavePerfil(updated));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Editar perfil', style: theme.textTheme.titleLarge),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nombre,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _apellido,
                    decoration: const InputDecoration(labelText: 'Apellido'),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _telefono,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _finca,
              decoration: const InputDecoration(labelText: 'Finca'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _direccion,
              decoration: const InputDecoration(labelText: 'Dirección'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('Guardar')),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Theme toggle
// ---------------------------------------------------------------------------

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

class _JsonBackupCard extends StatelessWidget {
  const _JsonBackupCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.folder_zip_outlined,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text('Respaldo JSON', style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Exporta o importa animales y lotes en formato JSON.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _handleExport(context),
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('Exportar respaldo'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _handleImport(context),
              icon: const Icon(Icons.download_for_offline_outlined),
              label: const Text('Importar respaldo'),
            ),
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
      if (!context.mounted) return;
      if (path == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Exportación cancelada.')),
        );
        return;
      }
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Respaldo guardado.'),
          action: SnackBarAction(
            label: 'Compartir',
            onPressed: () => Share.shareXFiles([
              XFile(path),
            ], subject: 'LibretApp – respaldo'),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Error al exportar: $e')));
    }
  }

  Future<void> _handleImport(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final service = locator<BackupService>();

    final mode = await _askImportMode(context);
    if (mode == null || !context.mounted) return;

    try {
      final summary = await service.importFromFile(mode: mode);
      if (!context.mounted) return;
      if (summary == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Importación cancelada.')),
        );
        return;
      }
      final modeLabel = summary.mode == BackupImportMode.merge
          ? 'mezcla'
          : 'reemplazo total';
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Importación completada ($modeLabel): '
            '${summary.animalsImported} animales, '
            '${summary.lotesImported} lotes.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Error al importar: $e')));
    }
  }

  Future<BackupImportMode?> _askImportMode(BuildContext context) {
    return showDialog<BackupImportMode>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Modo de importación'),
          content: const Text(
            'Elige cómo aplicar el respaldo:\n\n'
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
// Excel export card
// ---------------------------------------------------------------------------

class _ExcelExportCard extends StatefulWidget {
  const _ExcelExportCard();

  @override
  State<_ExcelExportCard> createState() => _ExcelExportCardState();
}

class _ExcelExportCardState extends State<_ExcelExportCard> {
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
    final theme = Theme.of(context);
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
                backgroundColor: theme.colorScheme.error,
              ),
            );
            context.read<ExportCubit>().reset();
          }
        },
        child: BlocBuilder<ExportCubit, ExportState>(
          builder: (context, state) {
            final isLoading = state is ExportLoading;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.table_chart_outlined,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Exportar a Excel',
                          style: theme.textTheme.titleSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Selecciona qué datos incluir. Se generará un .xlsx que podrás '
                      'compartir por WhatsApp, Telegram, correo u otras apps.',
                      style: theme.textTheme.bodySmall,
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
