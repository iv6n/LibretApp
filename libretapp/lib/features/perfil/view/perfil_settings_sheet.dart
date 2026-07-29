/// Settings sheet: theme, backup, export, edit profile.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/theme/theme_bloc.dart';
import 'package:libretapp/app/widgets/shell_insets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/core/services/animal_excel_import_service.dart';
import 'package:libretapp/core/services/backup_service.dart';
import 'package:libretapp/core/services/export_service.dart';
import 'package:libretapp/core/sync/sync_service.dart';
import 'package:libretapp/features/exportar/cubit/export_cubit.dart';
import 'package:libretapp/features/perfil/view/cloud_auth_sheet.dart';
import 'package:libretapp/features/exportar/widgets/export_selection_panel.dart';
import 'package:libretapp/features/perfil/bloc/perfil_bloc.dart';
import 'package:libretapp/features/perfil/bloc/perfil_event.dart';
import 'package:libretapp/features/perfil/data/perfil_model.dart';
import 'package:libretapp/theme/app_theme.dart';
import 'package:share_plus/share_plus.dart';

class PerfilSettingsContent extends StatefulWidget {
  const PerfilSettingsContent({
    required this.perfil,
    this.showCloseButton = false,
    this.closeBeforeEdit = false,
    this.shrinkWrap = false,
    super.key,
  });

  final Perfil perfil;
  final bool showCloseButton;
  final bool closeBeforeEdit;
  final bool shrinkWrap;

  @override
  State<PerfilSettingsContent> createState() => _PerfilSettingsContentState();
}

class _PerfilSettingsContentState extends State<PerfilSettingsContent> {
  void _openEdit() {
    final perfilBloc = context.read<PerfilBloc>();
    if (widget.closeBeforeEdit) {
      Navigator.of(context).pop();
    }
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: perfilBloc,
        child: _EditPerfilSheet(perfil: widget.perfil),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // In its one current usage this content sits inside a tab body under the
    // shell's floating bottom nav bar (Scaffold(extendBody: true)), so it
    // needs the shared shell inset — not just the keyboard inset — or the
    // last list tiles end up hidden (and untappable) behind the nav bar.
    final bottomInset = ShellInsets.bottomSafePadding(context);

    return ListView(
      shrinkWrap: widget.shrinkWrap,
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Ajustes', style: theme.textTheme.titleLarge),
                const Spacer(),
                if (widget.showCloseButton)
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Editar perfil'),
              onTap: _openEdit,
            ),
            BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                final isDark = state.themeMode == ThemeMode.dark;
                return SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Tema oscuro'),
                  value: isDark,
                  onChanged: (_) => context.read<ThemeBloc>().add(
                    ThemeModeChanged(isDark ? ThemeMode.light : ThemeMode.dark),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file_outlined),
              title: const Text('Exportar respaldo JSON'),
              onTap: () => _exportBackup(context),
            ),
            ListTile(
              leading: const Icon(Icons.download_for_offline_outlined),
              title: const Text('Importar respaldo JSON'),
              onTap: () => _importBackup(context),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: const Text('Cuenta en la nube'),
              subtitle: const Text('Iniciar sesión, crear cuenta o cerrar sesión.'),
              onTap: () => showModalBottomSheet<void>(
                context: context,
                useRootNavigator: true,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (_) => const CloudAuthSheet(),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.cloud_upload_outlined),
              title: const Text('Respaldar ahora'),
              subtitle: const Text('Sube los cambios locales a tu respaldo en la nube.'),
              onTap: () => _syncNow(context),
            ),
            ListTile(
              leading: const Icon(Icons.table_chart_outlined),
              title: const Text('Exportar a Excel'),
              onTap: () => context.push(AppRoutes.exportar),
            ),
            ListTile(
              leading: const Icon(Icons.upload_outlined),
              title: const Text('Importar animales desde Excel'),
              subtitle: const Text(
                'Solo la hoja "Animales" de una exportación previa — datos básicos.',
              ),
              onTap: () => _importAnimalsFromExcel(context),
            ),
            const Divider(),
            BlocProvider(
              create: (_) => ExportCubit(locator<ExportService>()),
              child: const ExportResultListener(child: ExportSelectionPanel()),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _exportBackup(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final path = await locator<BackupService>().exportToFile();
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
            onPressed: () => Share.shareXFiles([XFile(path)]),
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    final mode = await showDialog<BackupImportMode>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        title: const Text('Modo de importación'),
        content: const Text(
          'Mezclar conserva datos locales. Reemplazar borra todo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, BackupImportMode.merge),
            child: const Text('Mezclar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, BackupImportMode.replaceAll),
            child: const Text('Reemplazar'),
          ),
        ],
      ),
    );
    if (mode == null || !context.mounted) return;
    try {
      final summary = await locator<BackupService>().importFromFile(mode: mode);
      if (!context.mounted) return;
      if (summary == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Importados ${summary.animalsImported} animales, '
            '${summary.lotesImported} lotes, '
            '${summary.agendaEntriesImported} tareas, '
            '${summary.workersImported} integrantes y '
            '${summary.teamsImported} equipos, '
            '${summary.milkingSessionsImported} ordeñas.',
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _syncNow(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Respaldando en la nube...')),
    );
    try {
      final result = await locator<SyncService>().syncNow();
      if (!context.mounted) return;
      if (result.isUnavailable) {
        messenger.showSnackBar(
          SnackBar(content: Text(result.unavailableReason!)),
        );
        return;
      }
      final message = result.hasErrors
          ? '${result.pushed} registro(s) respaldados. '
                '${result.errors.length} error(es), ver logs.'
          : '${result.pushed} registro(s) respaldados.';
      messenger.showSnackBar(SnackBar(content: Text(message)));
      for (final error in result.errors) {
        debugPrint('[Respaldar] $error');
      }
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _importAnimalsFromExcel(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final summary = await locator<AnimalExcelImportService>()
          .importFromPickedFile();
      if (summary == null) return;
      final parts = <String>[
        if (summary.created > 0) '${summary.created} animales nuevos',
        if (summary.updated > 0) '${summary.updated} actualizados',
      ];
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            parts.isEmpty
                ? 'No se importó ningún animal.'
                : '${parts.join(', ')}.'
                      '${summary.warnings.isEmpty ? '' : ' ${summary.warnings.length} aviso(s), ver logs.'}',
          ),
          duration: const Duration(seconds: 5),
        ),
      );
      for (final warning in summary.warnings) {
        debugPrint('[ImportarExcel] $warning');
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

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
  late final TextEditingController _upp;
  late final TextEditingController _direccion;

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.perfil.nombre);
    _apellido = TextEditingController(text: widget.perfil.apellido);
    _email = TextEditingController(text: widget.perfil.email);
    _telefono = TextEditingController(text: widget.perfil.telefono);
    _finca = TextEditingController(text: widget.perfil.finca);
    _upp = TextEditingController(text: widget.perfil.upp);
    _direccion = TextEditingController(text: widget.perfil.direccion);
  }

  @override
  void dispose() {
    _nombre.dispose();
    _apellido.dispose();
    _email.dispose();
    _telefono.dispose();
    _finca.dispose();
    _upp.dispose();
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
      upp: _upp.text.trim(),
      direccion: _direccion.text.trim(),
    );
    context.read<PerfilBloc>().add(SavePerfil(updated));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Editar perfil',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nombre,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _apellido,
                      decoration: const InputDecoration(labelText: 'Apellido'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _finca,
                decoration: const InputDecoration(labelText: 'Rancho / Finca'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _upp,
                decoration: const InputDecoration(labelText: 'UPP'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Correo'),
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
                controller: _direccion,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: _save, child: const Text('Guardar')),
            ],
          ),
        ),
      ),
    );
  }
}
