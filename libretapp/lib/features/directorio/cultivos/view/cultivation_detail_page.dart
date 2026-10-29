/// Detail and activity timeline for an independent cultivation.
library;

import 'package:flutter/material.dart';
import 'package:libretapp/core/widgets/record_save_scope.dart';
import 'package:libretapp/core/widgets/app_empty_state.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/agenda/data/agenda_reminder_sync_service.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_growth_stage.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_task_type.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/features/ubicaciones/widgets/crop_sheets.dart';

class CultivationDetailPage extends StatefulWidget {
  CultivationDetailPage({
    super.key,
    required this.cultivationUuid,
    CultivationRepository? repository,
    LocationRepository? locationRepository,
  }) : repository = repository ?? locator<CultivationRepository>(),
       locationRepository = locationRepository ?? locator<LocationRepository>();

  final String cultivationUuid;
  final CultivationRepository repository;
  final LocationRepository locationRepository;

  @override
  State<CultivationDetailPage> createState() => _CultivationDetailPageState();
}

class _CultivationDetailPageState extends State<CultivationDetailPage> {
  late Stream<List<CultivationEntity>> _stream;
  CultivationRepository get repository => widget.repository;
  LocationRepository get locationRepository => widget.locationRepository;
  String get cultivationUuid => widget.cultivationUuid;
  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  void _subscribe() {
    _stream = repository.watchAll(includeArchived: true);
  }

  @override
  void didUpdateWidget(CultivationDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != repository ||
        oldWidget.cultivationUuid != cultivationUuid)
      _subscribe();
  }

  @override
  Widget build(BuildContext context) {
    return ShellChromeScope(
      visible: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cultivo'),
          actions: [
            IconButton(
              tooltip: 'Editar cultivo',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.pushNamed(
                AppRoutes.nameCultivoEditar,
                pathParameters: {'uuid': cultivationUuid},
              ),
            ),
          ],
        ),
        body: StreamBuilder<List<CultivationEntity>>(
          stream: _stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return AppEmptyState(
                title: 'No se pudo cargar el cultivo',
                action: FilledButton(
                  onPressed: () => setState(_subscribe),
                  child: const Text('Reintentar'),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final matches = snapshot.data!
                .where((item) => item.uuid == cultivationUuid)
                .toList(growable: false);
            if (matches.isEmpty) {
              return const Center(child: Text('Cultivo no encontrado'));
            }
            return FutureBuilder<LocationEntity?>(
              future: _loadLocation(matches.first),
              builder: (context, locationSnapshot) => _CultivationDetailBody(
                cultivation: matches.first,
                location: locationSnapshot.data,
                repository: repository,
              ),
            );
          },
        ),
      ),
    );
  }

  Future<LocationEntity?> _loadLocation(CultivationEntity cultivation) {
    final locationUuid = cultivation.locationUuid;
    if (locationUuid == null) return Future.value();
    return locationRepository.getByUuid(locationUuid);
  }
}

class _CultivationDetailBody extends StatefulWidget {
  const _CultivationDetailBody({
    required this.cultivation,
    required this.location,
    required this.repository,
  });

  final CultivationEntity cultivation;
  final LocationEntity? location;
  final CultivationRepository repository;

  @override
  State<_CultivationDetailBody> createState() => _CultivationDetailBodyState();
}

class _CultivationDetailBodyState extends State<_CultivationDetailBody> {
  CultivationEntity get cultivation => widget.cultivation;
  LocationEntity? get location => widget.location;
  CultivationRepository get repository => widget.repository;
  bool _busy = false;
  Future<void> _perform(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo guardar. Vuelve a intentarlo.'),
          ),
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pending = cultivation.tasks.where((task) => !task.completed).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final bottom = ShellInsets.bottomSafePadding(context);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _OverviewCard(cultivation: cultivation, location: location),
          const SizedBox(height: 12),
          if (cultivation.isActive)
            Text(
              'Registrar actividad',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          const SizedBox(height: 8),
          if (cultivation.isActive)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ActionButton(
                  icon: Icons.water_drop_outlined,
                  label: 'Riego',
                  onPressed: () => _addWatering(context),
                ),
                _ActionButton(
                  icon: Icons.agriculture_outlined,
                  label: 'Cosecha',
                  onPressed: () => _addHarvest(context),
                ),
                _ActionButton(
                  icon: Icons.health_and_safety_outlined,
                  label: 'Salud',
                  onPressed: () => _addHealth(context),
                ),
                _ActionButton(
                  icon: Icons.add_task_outlined,
                  label: 'Tarea',
                  onPressed: () => _addTask(context),
                ),
              ],
            ),
          if (pending.isNotEmpty) ...[
            const SizedBox(height: 18),
            _SectionCard(
              title: 'Próximas actividades',
              children: [
                for (final task in pending)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      task.isOverdue
                          ? Icons.warning_amber_rounded
                          : Icons.event_note_outlined,
                      color: task.isOverdue
                          ? Theme.of(context).colorScheme.error
                          : null,
                    ),
                    title: Text(task.type.displayName),
                    subtitle: Text(
                      '${_date(task.dueDate)}${task.notes == null ? '' : ' · ${task.notes}'}',
                    ),
                    trailing: IconButton(
                      tooltip: 'Marcar como realizada',
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: _busy
                          ? null
                          : () => _perform(() async {
                              await repository.completeTask(
                                cultivation.uuid,
                                task.uuid,
                              );
                              await _syncAgenda();
                            }),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Historial',
            children: [
              _HistoryRow(
                icon: Icons.water_drop_outlined,
                label: 'Riegos',
                value: cultivation.waterings.length,
              ),
              _HistoryRow(
                icon: Icons.agriculture_outlined,
                label: 'Cosechas',
                value: cultivation.harvests.length,
                detail: cultivation.totalYieldKg > 0
                    ? '${cultivation.totalYieldKg.toStringAsFixed(1)} kg'
                    : null,
              ),
              _HistoryRow(
                icon: Icons.health_and_safety_outlined,
                label: 'Registros de salud',
                value: cultivation.healthRecords.length,
              ),
              _HistoryRow(
                icon: Icons.task_alt_outlined,
                label: 'Tareas realizadas',
                value: cultivation.tasks.where((task) => task.completed).length,
              ),
            ],
          ),
          if (cultivation.notes?.isNotEmpty ?? false) ...[
            const SizedBox(height: 12),
            _SectionCard(title: 'Notas', children: [Text(cultivation.notes!)]),
          ],
          if (cultivation.isActive) ...[
            const SizedBox(height: 20),
            OutlinedButton.icon(
              icon: const Icon(Icons.archive_outlined),
              label: const Text('Archivar cultivo'),
              onPressed: _busy ? null : () => _perform(() => _archive(context)),
            ),
          ],
        ],
      ),
    );
  }

  Future<T?> _openSheet<T>(
    BuildContext context,
    Widget child,
    Future<void> Function(T) onSave,
  ) {
    return showAppBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => RecordSaveScope(
        onSave: (value) => onSave(value as T),
        child: SingleChildScrollView(child: child),
      ),
    );
  }

  Future<void> _addWatering(BuildContext context) async {
    await _openSheet<CropWateringRecord>(
      context,
      CropWateringFormSheet(cropName: cultivation.name),
      (value) async {
        await repository.addWatering(cultivation.uuid, value);
        await _syncAgenda();
      },
    );
  }

  Future<void> _addHarvest(BuildContext context) async {
    await _openSheet<HarvestRecord>(
      context,
      HarvestFormSheet(cropName: cultivation.name),
      (value) async {
        await repository.addHarvest(cultivation.uuid, value);
        await _syncAgenda();
      },
    );
  }

  Future<void> _addHealth(BuildContext context) async {
    await _openSheet<CropHealthRecord>(
      context,
      CropHealthFormSheet(cropName: cultivation.name),
      (value) async {
        await repository.addHealth(cultivation.uuid, value);
        await _syncAgenda();
      },
    );
  }

  Future<void> _addTask(BuildContext context) async {
    await _openSheet<CropTask>(
      context,
      CropTaskFormSheet(cropName: cultivation.name),
      (value) async {
        await repository.addTask(cultivation.uuid, value);
        await _syncAgenda();
      },
    );
  }

  Future<void> _archive(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archivar cultivo'),
        content: Text(
          '¿Archivar “${cultivation.name}”? Dejará de contar como uso activo de la ubicación.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Archivar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await repository.archive(cultivation.uuid);
    await _syncAgenda();
  }

  Future<void> _syncAgenda() async {
    if (!locator.isRegistered<AgendaReminderSyncService>()) return;
    try {
      await locator<AgendaReminderSyncService>().sync();
    } catch (_) {
      /* The record is already persisted; a later sync retries the projection. */
    }
  }

  String _date(DateTime value) => '${value.day}/${value.month}/${value.year}';
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.cultivation, required this.location});

  final CultivationEntity cultivation;
  final LocationEntity? location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: scheme.primaryContainer,
                  child: Icon(
                    cultivation.scale == CultivationScale.individual
                        ? Icons.local_florist_outlined
                        : cultivation.scale == CultivationScale.group
                        ? Icons.yard_outlined
                        : Icons.grass_outlined,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cultivation.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (cultivation.variety.isNotEmpty)
                        Text(cultivation.variety),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(cultivation.status.displayName)),
                Chip(label: Text(cultivation.scale.displayName)),
                Chip(label: Text(cultivation.measureLabel)),
                Chip(label: Text(cultivation.growthStage.displayName)),
              ],
            ),
            const SizedBox(height: 10),
            _OverviewLine(
              icon: Icons.calendar_today_outlined,
              text: 'Inició ${_date(cultivation.plantingDate)}',
            ),
            _OverviewLine(
              icon: cultivation.locationUuid == null
                  ? Icons.location_off_outlined
                  : Icons.location_on_outlined,
              text: location?.name ?? 'Sin ubicación',
              onTap: location == null
                  ? null
                  : () => context.pushNamed(
                      AppRoutes.nameUbicacionDetalle,
                      pathParameters: {'uuid': location!.uuid},
                    ),
            ),
            _OverviewLine(
              icon: Icons.water_drop_outlined,
              text: cultivation.isOverdueForWatering
                  ? 'Riego pendiente desde ${_date(cultivation.nextWateringDate)}'
                  : 'Próximo riego ${_date(cultivation.nextWateringDate)}',
            ),
          ],
        ),
      ),
    );
  }

  String _date(DateTime value) => '${value.day}/${value.month}/${value.year}';
}

class _OverviewLine extends StatelessWidget {
  const _OverviewLine({required this.icon, required this.text, this.onTap});

  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
            if (onTap != null) const Icon(Icons.chevron_right, size: 18),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.detail,
  });

  final IconData icon;
  final String label;
  final int value;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(icon),
      title: Text(label),
      trailing: Text(
        detail == null ? '$value' : '$value · $detail',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
