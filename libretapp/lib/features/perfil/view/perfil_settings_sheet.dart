/// Profile settings overview and its account and data pages.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:libretapp/core/workspace/workspace_manager.dart';
import 'package:libretapp/core/experience/app_experience.dart';
import 'package:libretapp/core/experience/care_profile_selector.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';
import 'package:libretapp/features/lite/lite_notification_service.dart';
import 'package:libretapp/features/perfil/view/account_settings_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/app_bottom_sheet.dart';
import 'package:libretapp/app/widgets/shell_insets.dart';
import 'package:libretapp/core/demo/demo_scenario_service.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/platform/release_features.dart';
import 'package:libretapp/core/backup/backup_operation_lock.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/core/services/backup_service.dart';
import 'package:libretapp/features/biblioteca/data/region_catalog.dart';
import 'package:libretapp/features/perfil/bloc/perfil_bloc.dart';
import 'package:libretapp/features/perfil/bloc/perfil_event.dart';
import 'package:libretapp/features/perfil/bloc/perfil_state.dart';
import 'package:libretapp/features/perfil/data/perfil_model.dart';
import 'package:libretapp/features/perfil/view/cloud_auth_sheet.dart';
import 'package:libretapp/features/perfil/view/cloud_backup_sheet.dart';
import 'package:libretapp/theme/app_theme.dart';
import 'package:share_plus/share_plus.dart';
import 'package:libretapp/app/theme/theme_bloc.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/platform/pilot_information.dart';
import 'package:libretapp/core/maintenance/data_maintenance.dart';
import 'data_review_page.dart';
import 'recovery_copies_page.dart';

class PerfilSettingsContent extends StatefulWidget {
  const PerfilSettingsContent({
    required this.perfil,
    this.showCloseButton = false,
    this.shrinkWrap = false,
    super.key,
  });

  final Perfil perfil;
  final bool showCloseButton;
  final bool shrinkWrap;

  @override
  State<PerfilSettingsContent> createState() => PerfilSettingsContentState();
}

void showPerfilEditor(
  BuildContext context,
  Perfil perfil, {
  PerfilBloc? perfilBloc,
}) {
  final bloc = perfilBloc ?? context.read<PerfilBloc>();
  showAppBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => BlocProvider.value(
      value: bloc,
      child: _EditPerfilSheet(perfil: perfil),
    ),
  );
}

class PerfilSettingsContentState extends State<PerfilSettingsContent> {
  bool _backupBusy = false;
  bool _experienceBusy = false;

  Future<void> _changePlants(bool value) async {
    try {
      final controller = AppExperienceScope.of(context);
      await controller.setPreferences(
        controller.value.copyWith(includePlants: value, configured: true),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo guardar la preferencia: $error')),
        );
      }
    }
  }

  void _openRegionSettings() {
    final perfilBloc = context.read<PerfilBloc>();
    showAppBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: perfilBloc,
        child: _RegionSettingsSheet(perfil: widget.perfil),
      ),
    );
  }

  void _openRegistrationSettings(AppExperienceController experience) {
    var selection = experience.value;
    showAppBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.8,
        ),
        child: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setSheetState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  title: Text('Qué vas a registrar'),
                  subtitle: Text(
                    'Tu selección prioriza accesos y no oculta las fichas guardadas.',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CareProfileSelector(
                    value: selection.careProfile,
                    onChanged: (profile) => setSheetState(
                      () => selection = selection.copyWith(
                        careProfile: profile,
                        configured: true,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 2,
                    children: [
                      for (final species in Species.values)
                        FilterChip(
                          label: Text(species.displayName),
                          selected: selection.preferredSpecies.contains(
                            species,
                          ),
                          onSelected: (selected) {
                            final speciesSet = Set<Species>.of(
                              selection.preferredSpecies,
                            );
                            selected
                                ? speciesSet.add(species)
                                : speciesSet.remove(species);
                            setSheetState(
                              () => selection = selection.copyWith(
                                preferredSpecies: speciesSet,
                                configured:
                                    speciesSet.isNotEmpty ||
                                    selection.includePlants,
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.eco_outlined),
                  title: const Text('Plantas y cultivos'),
                  value: selection.includePlants,
                  onChanged: (value) => setSheetState(
                    () => selection = selection.copyWith(
                      includePlants: value,
                      configured:
                          value || selection.preferredSpecies.isNotEmpty,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton(
                    onPressed: _experienceBusy
                        ? null
                        : () async {
                            setState(() => _experienceBusy = true);
                            try {
                              await experience.setPreferences(selection);
                              if (sheetContext.mounted) {
                                Navigator.of(sheetContext).pop();
                              }
                            } catch (error) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('No se pudo guardar: $error'),
                                  ),
                                );
                              }
                            } finally {
                              if (mounted)
                                setState(() => _experienceBusy = false);
                            }
                          },
                    child: const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openAppearance() {
    final bloc = context.read<ThemeBloc>();
    final selected = bloc.state.themeMode;
    showAppBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(title: Text('Apariencia')),
              for (final mode in ThemeMode.values)
                ListTile(
                  title: Text(switch (mode) {
                    ThemeMode.light => 'Claro',
                    ThemeMode.dark => 'Oscuro',
                    ThemeMode.system => 'Según el dispositivo',
                  }),
                  trailing: mode == selected ? const Icon(Icons.check) : null,
                  onTap: () {
                    bloc.add(ThemeModeChanged(mode));
                    Navigator.of(sheetContext).pop();
                  },
                ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> openDataPage() async {
    final manager = locator.isRegistered<WorkspaceManager>()
        ? locator<WorkspaceManager>()
        : null;
    await _openDataPage(manager?.isDemo ?? false);
    if (mounted) setState(() {});
  }

  Future<void> _openDataPage(bool demo) async {
    final bloc = context.read<PerfilBloc>();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: _DataSettingsPage(
            demo: demo,
            lastBackupLabel: _lastBackupLabel,
            exportBackup: _exportBackup,
            importBackup: _importBackup,
            importHerd: _importAnimalsFromExcel,
            loadDemo: _loadDemoScenario,
            removeDemo: _removeDemoScenario,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final experience = AppExperienceScope.maybeOf(context);
    final manager = locator.isRegistered<WorkspaceManager>()
        ? locator<WorkspaceManager>()
        : null;
    final demo = manager?.isDemo ?? false;
    return ListView(
      shrinkWrap: widget.shrinkWrap,
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        ShellInsets.bottomSafePadding(context) + 16,
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text('Ajustes', style: theme.textTheme.titleLarge),
              ),
            ),
            if (widget.showCloseButton)
              IconButton(
                tooltip: 'Cerrar ajustes',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        const _SettingsSectionLabel('Preferencias'),
        if (experience != null)
          _SettingsNavTile(
            icon: Icons.tune_outlined,
            title: 'Qué vas a registrar',
            subtitle:
                experience.value.preferredSpecies.isEmpty &&
                    !experience.value.includePlants
                ? 'Animales; puedes configurar especies después'
                : [
                    ...experience.value.preferredSpecies.map(
                      (s) => s.displayName,
                    ),
                    if (experience.value.includePlants) 'Plantas y cultivos',
                  ].join(' · '),
            onTap: () => _openRegistrationSettings(experience),
          ),
        BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) => _SettingsNavTile(
            icon: Icons.brightness_6_outlined,
            title: 'Apariencia',
            subtitle: switch (state.themeMode) {
              ThemeMode.light => 'Claro',
              ThemeMode.dark => 'Oscuro',
              ThemeMode.system => 'Según el dispositivo',
            },
            onTap: _openAppearance,
          ),
        ),
        _SettingsNavTile(
          icon: Icons.map_outlined,
          title: 'Región y producción',
          onTap: _openRegionSettings,
        ),
        if (experience != null)
          SwitchListTile(
            secondary: const Icon(Icons.local_florist_outlined),
            title: const Text('Plantas y cultivos en accesos sugeridos'),
            value: experience.value.includePlants,
            onChanged: _changePlants,
          ),
        FutureBuilder<bool>(
          future: LiteNotificationService.exactAvailable(),
          builder: (context, status) => _SettingsNavTile(
            icon: Icons.notifications_active_outlined,
            title: 'Avisos del teléfono',
            subtitle: status.data == true
                ? 'Alarmas a la hora elegida disponibles'
                : 'Avisos aproximados; toca para permitir alarmas exactas',
            onTap: status.data == true
                ? null
                : () async {
                    try {
                      await LiteNotificationService.requestExactAccess();
                    } catch (error) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('No se pudo abrir el ajuste: $error'),
                          ),
                        );
                      }
                    }
                  },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const _SettingsSectionLabel('Cuenta y datos'),
        if (manager != null)
          _SettingsNavTile(
            icon: Icons.account_circle_outlined,
            title: 'Cuenta',
            subtitle: manager.isDemo
                ? 'Espacio de demostración'
                : manager.isGuest
                ? 'Espacio de invitado'
                : 'Número de teléfono verificado',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => _AccountSettingsPage(manager: manager),
              ),
            ),
          ),
        _SettingsNavTile(
          icon: Icons.backup_outlined,
          title: 'Datos y respaldos',
          subtitle: _lastBackupLabel(),
          onTap: () => _openDataPage(demo),
        ),
        const SizedBox(height: AppSpacing.md),
        const _SettingsSectionLabel('Ayuda'),
        _SettingsNavTile(
          icon: Icons.help_outline,
          title: 'Ayuda, privacidad y soporte',
          onTap: () => showAppBottomSheet<void>(
            context: context,
            useSafeArea: true,
            isScrollControlled: true,
            builder: (_) => const PilotInformationSheet(),
          ),
        ),
      ],
    );
  }

  String _lastBackupLabel() {
    final date = locator.isRegistered<SharedPrefsService>()
        ? locator<SharedPrefsService>().getDateTime(PrefsKeys.lastLocalBackup)
        : null;
    return date == null
        ? 'Última copia local: aún no has creado un respaldo.'
        : 'Última copia local creada: ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _exportBackup(BuildContext context) async {
    if (_backupBusy) return;
    setState(() => _backupBusy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final path = await BackupOperationLock().run(
        () => locator<BackupService>().exportToFile(),
      );
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
    } finally {
      if (mounted) setState(() => _backupBusy = false);
    }
  }

  Future<void> _loadDemoScenario(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Escenario demo'),
        content: const Text(
          'Esto instala o restablece "Rancho El Mezquite — DEMO". Si ya '
          'estaba instalado, sus registros vuelven a sus valores originales '
          '(cualquier cambio que hayas hecho a un animal demo se pierde). '
          'Tus datos reales nunca se tocan ni se borran.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      final result = await locator<DemoScenarioService>().install(reset: true);
      if (!context.mounted) return;
      context.read<PerfilBloc>().add(const LoadPerfil());
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Escenario demo listo: ${result.counts['animals'] ?? 0} animales, '
            '${result.counts['locations'] ?? 0} ubicaciones, '
            '${result.counts['lotes'] ?? 0} lotes.',
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Error al instalar el escenario demo: $e')),
        );
      }
    }
  }

  Future<void> _removeDemoScenario(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quitar escenario demo'),
        content: const Text(
          'Se eliminarán los animales, ubicaciones, lotes, ordeñas, '
          'movimientos financieros y tareas que pertenecen a "Rancho El '
          'Mezquite — DEMO".\n\n'
          'Tus datos reales se conservan. Si algún registro tuyo estaba '
          'asignado a un lote o una ubicación del demo, sólo se le quita esa '
          'asignación.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Quitar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      final result = await locator<DemoScenarioService>().uninstall();
      if (!context.mounted) return;
      context.read<PerfilBloc>().add(const LoadPerfil());

      final detached = result.detachedReferences;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Escenario demo eliminado: '
            '${result.counts['animals'] ?? 0} animales, '
            '${result.counts['locations'] ?? 0} ubicaciones, '
            '${result.counts['lotes'] ?? 0} lotes.'
            '${detached > 0 ? ' Se desvincularon $detached registro(s) tuyo(s).' : ''}',
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Error al quitar el escenario demo: $e')),
        );
      }
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    if (_backupBusy) return;
    final mode = await showDialog<BackupImportMode>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        title: const Text('Modo de importación'),
        content: const Text(
          'Fusionar agrega lo que falte y conserva los cambios locales más '
          'recientes.\n\n'
          'Reemplazar todo borra los datos locales y los sustituye por el '
          'archivo; antes de hacerlo se guarda una copia de emergencia en el '
          'dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, BackupImportMode.replaceAll),
            child: const Text('Reemplazar todo'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, BackupImportMode.merge),
            child: const Text('Fusionar'),
          ),
        ],
      ),
    );
    if (mode == null || !context.mounted) return;
    setState(() => _backupBusy = true);
    try {
      final summary = await BackupOperationLock().run(
        () => locator<BackupService>().importFromFile(mode: mode),
      );
      if (!context.mounted) return;
      if (summary == null) return;
      if (locator.isRegistered<WorkspaceManager>()) {
        await locator<WorkspaceManager>().reload();
        return;
      }
      context.read<PerfilBloc>().add(const LoadPerfil());
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
    } finally {
      if (mounted) setState(() => _backupBusy = false);
    }
  }

  Future<void> _importAnimalsFromExcel(BuildContext context) async {
    if (_backupBusy) return;
    setState(() => _backupBusy = true);
    try {
      await context.pushNamed(AppRoutes.nameHerdImport);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _backupBusy = false);
    }
  }
}

class _SettingsSectionLabel extends StatelessWidget {
  const _SettingsSectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
    child: Semantics(
      header: true,
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

class _SettingsNavTile extends StatelessWidget {
  const _SettingsNavTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 56),
    child: ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}

class _AccountSettingsPage extends StatelessWidget {
  const _AccountSettingsPage({required this.manager});

  final WorkspaceManager manager;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Cuenta')),
    body: ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        ShellInsets.bottomSafePadding(context) + 16,
      ),
      children: [AccountSettingsCard(manager: manager)],
    ),
  );
}

class _DataSettingsPage extends StatefulWidget {
  const _DataSettingsPage({
    required this.demo,
    required this.lastBackupLabel,
    required this.exportBackup,
    required this.importBackup,
    required this.importHerd,
    required this.loadDemo,
    required this.removeDemo,
  });

  final bool demo;
  final String Function() lastBackupLabel;
  final Future<void> Function(BuildContext) exportBackup;
  final Future<void> Function(BuildContext) importBackup;
  final Future<void> Function(BuildContext) importHerd;
  final Future<void> Function(BuildContext) loadDemo;
  final Future<void> Function(BuildContext) removeDemo;

  @override
  State<_DataSettingsPage> createState() => _DataSettingsPageState();
}

class _DataSettingsPageState extends State<_DataSettingsPage> {
  bool _busy = false;

  Future<void> _run(Future<void> Function(BuildContext) action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action(context);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final manager = locator.isRegistered<WorkspaceManager>()
        ? locator<WorkspaceManager>()
        : null;
    final maintenance = locator.isRegistered<DataMaintenance>()
        ? locator<DataMaintenance>()
        : null;
    final enabled = !_busy && !widget.demo;
    return Scaffold(
      appBar: AppBar(title: const Text('Datos y respaldos')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          ShellInsets.bottomSafePadding(context) + 16,
        ),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.offline_pin_outlined),
              title: const Text('Datos guardados en este dispositivo'),
              subtitle: Text(
                '${widget.lastBackupLabel()}\nPuedes trabajar sin conexión. Guarda una copia fuera del teléfono para recuperar tus datos.',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const _SettingsSectionLabel('Copias de seguridad'),
          _SettingsNavTile(
            icon: Icons.upload_file_outlined,
            title: 'Exportar respaldo completo',
            subtitle: widget.demo ? 'No disponible en la demo' : null,
            onTap: enabled ? () => _run(widget.exportBackup) : null,
          ),
          _SettingsNavTile(
            icon: Icons.download_for_offline_outlined,
            title: 'Importar respaldo completo',
            subtitle: widget.demo ? 'No disponible en la demo' : null,
            onTap: enabled ? () => _run(widget.importBackup) : null,
          ),
          if (!widget.demo &&
              ReleaseFeatures.cloudBackupEnabled &&
              manager != null &&
              !manager.isGuest) ...[
            if (!ReleaseFeatures.publicRelease)
              _SettingsNavTile(
                icon: Icons.account_circle_outlined,
                title: 'Cuenta de respaldo',
                onTap: () => showAppBottomSheet<void>(
                  context: context,
                  useRootNavigator: true,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (_) => const CloudAuthSheet(),
                ),
              ),
            _SettingsNavTile(
              icon: Icons.cloud_done_outlined,
              title: 'Copias en la nube',
              subtitle: 'Crear, revisar o restaurar copias verificadas',
              onTap: () => showAppBottomSheet<void>(
                context: context,
                useRootNavigator: true,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (_) => const FractionallySizedBox(
                  heightFactor: 0.85,
                  child: CloudBackupSheet(),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          const _SettingsSectionLabel('Archivos'),
          _SettingsNavTile(
            icon: Icons.table_chart_outlined,
            title: 'Exportar a Excel',
            subtitle: widget.demo ? 'No disponible en la demo' : null,
            onTap: enabled ? () => context.push(AppRoutes.exportar) : null,
          ),
          _SettingsNavTile(
            icon: Icons.upload_outlined,
            title: 'Importar hato (Excel o CSV)',
            subtitle: widget.demo
                ? 'No disponible en la demo'
                : 'Revisa los cambios antes de guardar',
            onTap: enabled ? () => _run(widget.importHerd) : null,
          ),
          if (maintenance != null) ...[
            const SizedBox(height: AppSpacing.md),
            const _SettingsSectionLabel('Revisión y recuperación'),
            _SettingsNavTile(
              icon: Icons.fact_check_outlined,
              title: 'Revisar integridad y duplicados',
              onTap: enabled
                  ? () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => DataReviewPage(service: maintenance),
                      ),
                    )
                  : null,
            ),
            _SettingsNavTile(
              icon: Icons.restore_page_outlined,
              title: 'Copias de recuperación',
              onTap: enabled
                  ? () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => RecoveryCopiesPage(
                          service: maintenance,
                          reopen: manager?.runMaintenance,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
          if (kDebugMode && widget.demo) ...[
            const SizedBox(height: AppSpacing.md),
            const _SettingsSectionLabel('Demostración'),
            _SettingsNavTile(
              icon: Icons.science_outlined,
              title: 'Cargar/restablecer escenario demo',
              onTap: _busy ? null : () => _run(widget.loadDemo),
            ),
            _SettingsNavTile(
              icon: Icons.delete_sweep_outlined,
              title: 'Quitar escenario demo',
              onTap: _busy ? null : () => _run(widget.removeDemo),
            ),
          ],
        ],
      ),
    );
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
    if (context.read<PerfilBloc>().state is PerfilSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final updated = widget.perfil.copyWith(
      nombre: _nombre.text.trim(),
      apellido: _apellido.text.trim(),
      email: _email.text.trim(),
      telefono: _telefono.text.trim(),
      finca: _finca.text.trim(),
      upp: _upp.text.trim(),
      direccion: _direccion.text.trim(),
    );
    context.read<PerfilBloc>().add(SavePerfil(updated));
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.watch<PerfilBloc>().state is PerfilSaving;
    final nameField = TextFormField(
      controller: _nombre,
      decoration: const InputDecoration(labelText: 'Nombre'),
    );
    final surnameField = TextFormField(
      controller: _apellido,
      decoration: const InputDecoration(labelText: 'Apellido'),
    );
    return BlocListener<PerfilBloc, PerfilState>(
      listenWhen: (previous, current) =>
          current is PerfilLoaded || current is PerfilError,
      listener: (context, state) {
        if (state is PerfilLoaded) {
          Navigator.of(context).pop();
        } else if (state is PerfilError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se pudo guardar el perfil: ${state.message}'),
            ),
          );
        }
      },
      child: Padding(
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
                Text(
                  'Datos del usuario',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final stacked =
                        constraints.maxWidth < 500 ||
                        MediaQuery.textScalerOf(context).scale(1) >= 1.5;
                    if (stacked) {
                      return Column(
                        children: [
                          nameField,
                          const SizedBox(height: 12),
                          surnameField,
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: nameField),
                        const SizedBox(width: 12),
                        Expanded(child: surnameField),
                      ],
                    );
                  },
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
                const SizedBox(height: 20),
                Text(
                  'Datos del rancho',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _finca,
                  decoration: const InputDecoration(
                    labelText: 'Rancho / Finca',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _upp,
                  decoration: const InputDecoration(labelText: 'UPP'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _direccion,
                  decoration: const InputDecoration(labelText: 'Dirección'),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: saving ? null : _save,
                  icon: saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(saving ? 'Guardando…' : 'Guardar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Lets the reader pick their state and production setting so the biblioteca
/// can show the matching regional adaptation instead of the general
/// fallback — see lib/features/biblioteca/domain/adaptive_resolver.dart.
class _RegionSettingsSheet extends StatefulWidget {
  const _RegionSettingsSheet({required this.perfil});
  final Perfil perfil;

  @override
  State<_RegionSettingsSheet> createState() => _RegionSettingsSheetState();
}

class _RegionSettingsSheetState extends State<_RegionSettingsSheet> {
  RegionCatalog? _catalog;
  String? _error;
  late String _stateId;
  late String _productionSettingId;

  @override
  void initState() {
    super.initState();
    _stateId = widget.perfil.regionState;
    _productionSettingId = widget.perfil.productionSetting;
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    try {
      final raw = await rootBundle.loadString(
        'assets/library/mexico-regions.json',
      );
      final catalog = RegionCatalog.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      if (!mounted) return;
      setState(() {
        _catalog = catalog;
        if (catalog.stateById(_stateId) == null) _stateId = 'general';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  List<ProductionSettingInfo> _availableProductionSettings(
    RegionCatalog catalog,
  ) {
    final settingIds = catalog.stateById(_stateId)?.productionSettings;
    if (settingIds == null) return catalog.productionSettings;
    return catalog.productionSettings
        .where((s) => settingIds.contains(s.id))
        .toList(growable: false);
  }

  void _save() {
    if (context.read<PerfilBloc>().state is PerfilSaving) return;
    final updated = widget.perfil.copyWith(
      regionState: _stateId,
      productionSetting: _productionSettingId,
    );
    context.read<PerfilBloc>().add(SavePerfil(updated));
  }

  @override
  Widget build(BuildContext context) {
    final catalog = _catalog;
    final saving = context.watch<PerfilBloc>().state is PerfilSaving;
    return BlocListener<PerfilBloc, PerfilState>(
      listenWhen: (previous, current) =>
          current is PerfilLoaded || current is PerfilError,
      listener: (context, state) {
        if (state is PerfilLoaded) {
          Navigator.of(context).pop();
        } else if (state is PerfilError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No se pudo guardar la configuración: ${state.message}',
              ),
            ),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Región y tipo de producción',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Se usa para mostrar el recuadro de adaptación regional en la '
              'biblioteca. Puedes dejarlo en General.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(
                'No se pudo cargar el catálogo de regiones: $_error',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )
            else if (catalog == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              DropdownButtonFormField<String>(
                initialValue: _stateId,
                decoration: const InputDecoration(labelText: 'Estado'),
                items: catalog.states
                    .map(
                      (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _stateId = value;
                    final available = _availableProductionSettings(
                      catalog,
                    ).map((s) => s.id);
                    if (!available.contains(_productionSettingId)) {
                      _productionSettingId = 'general';
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _productionSettingId,
                decoration: const InputDecoration(
                  labelText: 'Tipo de producción',
                ),
                items: _availableProductionSettings(catalog)
                    .map(
                      (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                    )
                    .toList(growable: false),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _productionSettingId = value);
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: saving ? null : _save,
                icon: saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(saving ? 'Guardando…' : 'Guardar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
