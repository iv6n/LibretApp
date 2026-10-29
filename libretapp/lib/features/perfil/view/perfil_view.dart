/// features › perfil › view › perfil_view — profile hub with tabs.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/widgets/app_empty_state.dart';
import 'package:libretapp/features/biblioteca/view/biblioteca_tab.dart';
import 'package:libretapp/features/perfil/bloc/perfil_bloc.dart';
import 'package:libretapp/features/perfil/bloc/perfil_event.dart';
import 'package:libretapp/features/perfil/bloc/perfil_state.dart';
import 'package:libretapp/features/perfil/data/perfil_model.dart';
import 'package:libretapp/features/perfil/view/perfil_settings_sheet.dart';
import 'package:libretapp/features/perfil/widgets/profile_header_card.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_repository.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';

class PerfilView extends StatelessWidget {
  const PerfilView({super.key, this.openBackups = false});

  final bool openBackups;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PerfilBloc, PerfilState>(
      builder: (context, state) {
        if (state is PerfilInitial || state is PerfilLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PerfilError) {
          if (state.perfil != null) {
            return _PerfilTabbedContent(
              perfil: state.perfil!,
              openBackups: openBackups,
            );
          }
          return AppEmptyState(
            icon: Icons.error_outline,
            title: 'No se pudo cargar el perfil',
            message: state.message,
            action: FilledButton.icon(
              onPressed: () =>
                  context.read<PerfilBloc>().add(const LoadPerfil()),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          );
        }

        final perfil = switch (state) {
          PerfilLoaded(:final perfil) => perfil,
          PerfilUpdated(:final perfil) => perfil,
          PerfilSaving(:final perfil) => perfil,
          _ => const Perfil(
            id: '',
            nombre: '',
            apellido: '',
            email: '',
            telefono: '',
            finca: '',
            direccion: '',
          ),
        };

        return _PerfilTabbedContent(perfil: perfil, openBackups: openBackups);
      },
    );
  }
}

class _PerfilTabbedContent extends StatefulWidget {
  const _PerfilTabbedContent({required this.perfil, required this.openBackups});

  final Perfil perfil;
  final bool openBackups;

  @override
  State<_PerfilTabbedContent> createState() => _PerfilTabbedContentState();
}

class _PerfilTabbedContentState extends State<_PerfilTabbedContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _settingsKey = GlobalKey<PerfilSettingsContentState>();
  int? _recordCount;
  StreamSubscription<void>? _animalChanges;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _refreshRecordCount();
    if (widget.openBackups) _scheduleOpenBackups();
    if (locator.isRegistered<AnimalRepository>()) {
      _animalChanges = locator<AnimalRepository>().watchChanges().listen((_) {
        _refreshRecordCount();
      });
    }
  }

  @override
  void didUpdateWidget(covariant _PerfilTabbedContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.openBackups && !oldWidget.openBackups) {
      _scheduleOpenBackups();
    }
  }

  void _scheduleOpenBackups() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _openBackups();
    });
  }

  Future<void> _refreshRecordCount() async {
    final checks = <Future<int>>[
      if (locator.isRegistered<AnimalRepository>())
        locator<AnimalRepository>().getAllIncludingInactive().then(
          (items) => items.length,
        ),
      if (locator.isRegistered<LotesRepository>())
        locator<LotesRepository>().getAll().then((items) => items.length),
      if (locator.isRegistered<CultivationRepository>())
        locator<CultivationRepository>().getAll().then((items) => items.length),
      if (locator.isRegistered<AgendaRepository>())
        locator<AgendaRepository>().fetchEntries().then(
          (items) => items.length,
        ),
      if (locator.isRegistered<LocationRepository>())
        locator<LocationRepository>().getAll().then((items) => items.length),
    ];
    final counts = await Future.wait(
      checks.map((check) => check.catchError((Object _) => 0)),
    );
    if (mounted) {
      setState(
        () => _recordCount = counts.fold<int>(0, (sum, count) => sum + count),
      );
    }
  }

  Future<void> _openBackups() async {
    _tabController.animateTo(1);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    await _settingsKey.currentState?.openDataPage();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _animalChanges?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: ProfileHeaderCard(
              perfil: widget.perfil,
              onEditTap: () => showPerfilEditor(context, widget.perfil),
            ),
          ),
          SliverToBoxAdapter(
            child: _BackupStatusCard(
              hasRecords: (_recordCount ?? 0) > 0,
              onTap: _openBackups,
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: AppSegmentedTabBarSliverDelegate(
              tabBar: AppSegmentedTabBar(
                textScale: MediaQuery.textScalerOf(context).scale(1),
                controller: _tabController,
                items: const [
                  AppSegmentedTabItem(
                    label: 'Biblioteca',
                    icon: Icons.menu_book_outlined,
                  ),
                  AppSegmentedTabItem(
                    label: 'Ajustes',
                    icon: Icons.settings_outlined,
                  ),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            const BibliotecaTab(),
            PerfilSettingsContent(key: _settingsKey, perfil: widget.perfil),
          ],
        ),
      ),
    );
  }
}

class _BackupStatusCard extends StatelessWidget {
  const _BackupStatusCard({required this.hasRecords, required this.onTap});

  final bool hasRecords;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final prefs = locator.isRegistered<SharedPrefsService>()
        ? locator<SharedPrefsService>()
        : null;
    final verified = prefs?.getDateTime(PrefsKeys.lastVerifiedCloudBackup);
    final uploaded = prefs?.getDateTime(PrefsKeys.lastCloudBackup);
    final local = prefs?.getDateTime(PrefsKeys.lastLocalBackup);
    final title =
        verified != null && (uploaded == null || !verified.isBefore(uploaded))
        ? 'Copia externa verificada'
        : uploaded != null
        ? 'Copia en nube subida; verificación pendiente'
        : local != null
        ? 'Copia local creada'
        : 'Datos solo en este teléfono';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.backup_outlined),
          title: Text(title),
          subtitle: Text(
            hasRecords && local == null && uploaded == null
                ? 'Ya tienes registros. Crea una copia de seguridad.'
                : 'Revisa y exporta tus respaldos',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}
