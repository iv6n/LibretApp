import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_records.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_growth_stage.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_task_type.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/water_type.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/features/ubicaciones/widgets/crop_sheets.dart';

class LocationDetailPage extends StatefulWidget {
  const LocationDetailPage({
    super.key,
    required this.locationUuid,
    this.locationRepository,
    this.animalRepository,
  });

  final String locationUuid;
  final LocationRepository? locationRepository;
  final AnimalRepository? animalRepository;

  @override
  State<LocationDetailPage> createState() => _LocationDetailPageState();
}

class _LocationDetailPageState extends State<LocationDetailPage> {
  late final LocationRepository _locationRepository;
  late final AnimalRepository _animalRepository;
  bool _assigning = false;

  @override
  void initState() {
    super.initState();
    _locationRepository =
        widget.locationRepository ?? locator<LocationRepository>();
    _animalRepository = widget.animalRepository ?? locator<AnimalRepository>();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = ShellInsets.bottomSafePadding(context);

    return ShellChromeScope(
      visible: false,
      child: Scaffold(
        appBar: AppBar(title: const Text('Ubicación')),
        body: StreamBuilder<List<LocationEntity>>(
          stream: _locationRepository.watchAll(),
          builder: (context, locSnapshot) {
            if (locSnapshot.connectionState == ConnectionState.waiting &&
                !locSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final locations = locSnapshot.data ?? const <LocationEntity>[];
            final match = locations
                .where((l) => l.uuid == widget.locationUuid)
                .toList();

            if (match.isEmpty) {
              return const Center(child: Text('Ubicación no encontrada'));
            }
            final location = match.first;

            return StreamBuilder<List<AnimalEntity>>(
              stream: _animalRepository.watchAll(),
              builder: (context, animalSnapshot) {
                final animals = animalSnapshot.data ?? const <AnimalEntity>[];
                final animalsHere = animals
                    .where((animal) {
                      final locId =
                          animal.currentPaddockId ?? animal.initialLocationId;
                      return locId == location.uuid;
                    })
                    .toList(growable: false);

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LocationHeader(
                        location: location,
                        animalsHere: animalsHere,
                      ),
                      const SizedBox(height: 12),
                      _OccupancyCard(
                        location: location,
                        animalsHere: animalsHere,
                      ),
                      const SizedBox(height: 12),
                      _InventorySection(location: location),
                      const SizedBox(height: 12),
                      _ConditionSection(location: location),
                      const SizedBox(height: 12),
                      _InfrastructureSection(location: location),
                      if (_isWarehouse(location)) ...[
                        const SizedBox(height: 12),
                        _WarehouseSection(location: location),
                      ],
                      const SizedBox(height: 12),
                      _RecordActions(
                        onVisit: () => _showVisitSheet(location),
                        onWater: () => _showWaterSheet(location),
                        onSalt: () => _showSaltSheet(location),
                        onShade: () => _showShadeSheet(location),
                        onPasture: () => _showPastureSheet(location),
                        onCost: () => _showCostSheet(location),
                      ),
                      if (_hasUpcomingTasks(location)) ...[
                        const SizedBox(height: 12),
                        _UpcomingTasksCard(
                          location: location,
                          onComplete: (cropUuid, taskUuid) =>
                              _completeCropTask(location, cropUuid, taskUuid),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _CropsSection(
                        location: location,
                        onAddCrop: () => _showCropFormSheet(location),
                        onEditCrop: (crop) =>
                            _showCropFormSheet(location, initial: crop),
                        onDeleteCrop: (crop) =>
                            _confirmDeleteCrop(location, crop),
                        onWaterCrop: (crop) =>
                            _showCropWateringSheet(location, crop),
                        onHarvestCrop: (crop) =>
                            _showHarvestSheet(location, crop),
                        onHealthCrop: (crop) =>
                            _showCropHealthSheet(location, crop),
                        onAddTask: (crop) => _showCropTaskSheet(location, crop),
                        onCompleteTask: (crop, taskUuid) =>
                            _completeCropTask(location, crop.uuid, taskUuid),
                      ),
                      if (_hasRecords(location)) ...[
                        const SizedBox(height: 12),
                        _LocationRecords(location: location),
                      ],
                      const SizedBox(height: 20),
                      _AnimalsSection(
                        animalsHere: animalsHere,
                        location: location,
                        assigning: _assigning,
                        onAssign: () => _showAssignAnimalsSheet(
                          location,
                          animals,
                          animalsHere,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _ActionsRow(
                        onEdit: () => _openForm(location),
                        onDelete: () => _confirmDelete(location),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _openForm(LocationEntity initial) async {
    await context.pushNamed(
      AppRoutes.nameUbicacionEditar,
      pathParameters: {'uuid': initial.uuid},
    );
  }

  Future<void> _confirmDelete(LocationEntity location) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar ubicación'),
        content: Text(
          '¿Deseas borrar "${location.name}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      await _locationRepository.deleteByUuid(location.uuid);
      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _showAssignAnimalsSheet(
    LocationEntity location,
    List<AnimalEntity> allAnimals,
    List<AnimalEntity> animalsHere,
  ) async {
    if (_assigning) return;
    setState(() => _assigning = true);
    final selected = {for (final animal in animalsHere) animal.uuid};

    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _AssignAnimalsSheet(
          allAnimals: allAnimals,
          initiallySelected: selected,
          locationName: location.name,
        );
      },
    );

    if (!mounted) return;

    if (result != null) {
      await _updateAssignments(location, allAnimals, result);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Animales actualizados')));
      }
    }

    if (mounted) setState(() => _assigning = false);
  }

  Future<void> _updateAssignments(
    LocationEntity location,
    List<AnimalEntity> animals,
    Set<String> selected,
  ) async {
    final tasks = <Future<void>>[];
    for (final animal in animals) {
      final locId = animal.currentPaddockId ?? animal.initialLocationId;
      final shouldBeHere = selected.contains(animal.uuid);
      final alreadyHere = locId == location.uuid;
      if (shouldBeHere == alreadyHere) continue;

      final newLocId = shouldBeHere ? location.uuid : null;
      final updated = animal.copyWith(
        currentPaddockId: newLocId,
        initialLocationId: animal.initialLocationId ?? newLocId,
        lastMovementDate: shouldBeHere
            ? DateTime.now()
            : animal.lastMovementDate,
        lastUpdateDate: DateTime.now(),
        synced: false,
      );
      tasks.add(_animalRepository.update(updated));
    }
    await Future.wait(tasks);
  }

  Future<void> _showVisitSheet(LocationEntity location) async {
    final record = await showModalBottomSheet<VisitRecord>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _VisitRecordSheet(locationName: location.name),
    );

    if (record != null) {
      await _locationRepository.addVisit(location.uuid, record);
    }
  }

  Future<void> _showWaterSheet(LocationEntity location) async {
    final record = await showModalBottomSheet<WaterRecord>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _WaterRecordSheet(locationName: location.name),
    );

    if (record != null) {
      await _locationRepository.addWater(location.uuid, record);
    }
  }

  Future<void> _showSaltSheet(LocationEntity location) async {
    final record = await showModalBottomSheet<SaltRecord>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _SaltRecordSheet(locationName: location.name),
    );

    if (record != null) {
      await _locationRepository.addSalt(location.uuid, record);
    }
  }

  Future<void> _showShadeSheet(LocationEntity location) async {
    final record = await showModalBottomSheet<ShadeRecord>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ShadeRecordSheet(locationName: location.name),
    );

    if (record != null) {
      await _locationRepository.addShade(location.uuid, record);
    }
  }

  Future<void> _showPastureSheet(LocationEntity location) async {
    final record = await showModalBottomSheet<PastureRecord>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _PastureRecordSheet(locationName: location.name),
    );

    if (record != null) {
      await _locationRepository.addPasture(location.uuid, record);
    }
  }

  Future<void> _showCostSheet(LocationEntity location) async {
    final record = await showModalBottomSheet<CostRecord>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CostRecordSheet(locationName: location.name),
    );

    if (record != null) {
      await _locationRepository.addCost(location.uuid, record);
    }
  }

  // ── Crop handlers ──────────────────────────────────────────────────────

  Future<void> _showCropFormSheet(
    LocationEntity location, {
    CropRecord? initial,
  }) async {
    final crop = await showModalBottomSheet<CropRecord>(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          CropFormSheet(locationName: location.name, initial: initial),
    );

    if (crop != null) {
      if (initial != null) {
        await _locationRepository.updateCrop(location.uuid, crop);
      } else {
        await _locationRepository.addCrop(location.uuid, crop);
      }
    }
  }

  Future<void> _confirmDeleteCrop(
    LocationEntity location,
    CropRecord crop,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cultivo'),
        content: Text(
          '¿Deseas borrar "${crop.cropName}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _locationRepository.deleteCrop(location.uuid, crop.uuid);
    }
  }

  Future<void> _showCropWateringSheet(
    LocationEntity location,
    CropRecord crop,
  ) async {
    final record = await showModalBottomSheet<CropWateringRecord>(
      context: context,
      isScrollControlled: true,
      builder: (context) => CropWateringFormSheet(cropName: crop.cropName),
    );

    if (record != null) {
      await _locationRepository.addCropWatering(
        location.uuid,
        crop.uuid,
        record,
      );
    }
  }

  Future<void> _showHarvestSheet(
    LocationEntity location,
    CropRecord crop,
  ) async {
    final record = await showModalBottomSheet<HarvestRecord>(
      context: context,
      isScrollControlled: true,
      builder: (context) => HarvestFormSheet(cropName: crop.cropName),
    );

    if (record != null) {
      await _locationRepository.addHarvest(location.uuid, crop.uuid, record);
    }
  }

  Future<void> _showCropHealthSheet(
    LocationEntity location,
    CropRecord crop,
  ) async {
    final record = await showModalBottomSheet<CropHealthRecord>(
      context: context,
      isScrollControlled: true,
      builder: (context) => CropHealthFormSheet(cropName: crop.cropName),
    );

    if (record != null) {
      await _locationRepository.addCropHealth(location.uuid, crop.uuid, record);
    }
  }

  Future<void> _showCropTaskSheet(
    LocationEntity location,
    CropRecord crop,
  ) async {
    final task = await showModalBottomSheet<CropTask>(
      context: context,
      isScrollControlled: true,
      builder: (context) => CropTaskFormSheet(cropName: crop.cropName),
    );

    if (task != null) {
      await _locationRepository.addCropTask(location.uuid, crop.uuid, task);
    }
  }

  Future<void> _completeCropTask(
    LocationEntity location,
    String cropUuid,
    String taskUuid,
  ) async {
    await _locationRepository.completeCropTask(
      location.uuid,
      cropUuid,
      taskUuid,
    );
  }

  bool _hasUpcomingTasks(LocationEntity l) {
    return l.crops.any(
      (c) => c.status == CropStatus.active && c.tasks.any((t) => !t.completed),
    );
  }

  bool _hasRecords(LocationEntity l) =>
      l.visits.isNotEmpty ||
      l.waters.isNotEmpty ||
      l.salts.isNotEmpty ||
      l.shades.isNotEmpty ||
      l.pastures.isNotEmpty ||
      l.seedings.isNotEmpty ||
      l.irrigations.isNotEmpty ||
      l.rains.isNotEmpty ||
      l.costs.isNotEmpty ||
      l.crops.isNotEmpty;

  bool _isWarehouse(LocationEntity l) =>
      l.type.name.toLowerCase() == 'almacen' || l.type == LocationType.rancho;
}

class _LocationHeader extends StatelessWidget {
  const _LocationHeader({required this.location, required this.animalsHere});

  final LocationEntity location;
  final List<AnimalEntity> animalsHere;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dominantSpecies = _dominantSpeciesLabel(animalsHere);
    final systemLabel = _systemLabel(location.type);
    final typeIcon = _typeIcon(location.type);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF214035), Color(0xFF2E5B46)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Última actualización ${location.costs.isNotEmpty ? location.costs.last.date : 'N/D'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    location.type.name.toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    location.status.toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Icon(
                              typeIcon,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  location.name,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_capitalize(location.type.name)} • ${location.terrainType}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onPrimary
                                        .withValues(alpha: 0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const _MiniMapPlaceholder(),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoPill(
                  icon: Icons.badge_outlined,
                  label: dominantSpecies ?? 'Especie sin asignar',
                ),
                _InfoPill(icon: Icons.safety_divider, label: systemLabel),
                _InfoPill(
                  icon: Icons.water_drop_outlined,
                  label: location.waterSource,
                ),
                _InfoPill(
                  icon: Icons.landscape_outlined,
                  label: location.terrainType,
                ),
                _InfoPill(
                  icon: Icons.straighten,
                  label:
                      '${location.surfaceArea.toStringAsFixed(1)} ha superficie',
                ),
                _InfoPill(
                  icon: Icons.groups,
                  label: '${location.capacity} capacidad',
                ),
              ],
            ),

            const SizedBox(height: 12),
            const _GalleryStrip(),
          ],
        ),
      ),
    );
  }
}

IconData _typeIcon(LocationType type) {
  switch (type) {
    case LocationType.potrero:
      return Icons.agriculture_outlined;
    case LocationType.corral:
      return Icons.yard_outlined;
    case LocationType.rancho:
      return Icons.home_work_outlined;
    case LocationType.siembra:
      return Icons.grain_outlined;
  }
}

String _systemLabel(LocationType type) {
  switch (type) {
    case LocationType.potrero:
      return 'Pastoreo';
    case LocationType.corral:
      return 'Confinamiento';
    case LocationType.rancho:
      return 'Mixto';
    case LocationType.siembra:
      return 'Pastoreo / rotación';
  }
}

String? _dominantSpeciesLabel(List<AnimalEntity> animals) {
  if (animals.isEmpty) return null;
  final counts = <Species, int>{};
  for (final animal in animals) {
    counts[animal.species] = (counts[animal.species] ?? 0) + 1;
  }
  final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
  return top.key.displayName;
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMapPlaceholder extends StatelessWidget {
  const _MiniMapPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Icon(
              Icons.map_outlined,
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              size: 80,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'GPS pendiente',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryStrip extends StatelessWidget {
  const _GalleryStrip();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return Container(
            width: 88,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.photo_outlined),
                const SizedBox(height: 6),
                Text(
                  index == 0 ? 'Agregar foto' : 'Foto ${index + 1}',
                  style: theme.textTheme.labelSmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OccupancyCard extends StatelessWidget {
  const _OccupancyCard({required this.location, required this.animalsHere});

  final LocationEntity location;
  final List<AnimalEntity> animalsHere;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rawCapacity = location.capacity;
    final current = animalsHere.length;
    final ratio = rawCapacity <= 0 ? 0.0 : current / rawCapacity;
    final percent = (ratio * 100).clamp(0, 999).toDouble();
    final overCapacity = ratio > 1.0;
    final density = location.surfaceArea > 0
        ? current / location.surfaceArea
        : 0.0;

    final movementDates =
        animalsHere
            .map((a) => a.lastMovementDate)
            .whereType<DateTime>()
            .toList()
          ..sort();
    final entryDate = movementDates.isNotEmpty ? movementDates.first : null;
    final occupancyDays = entryDate == null
        ? null
        : DateTime.now().difference(entryDate).inDays;

    final lotCount = animalsHere
        .map((a) => a.batchUuid)
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet()
        .length;

    final dominantSpecies = _dominantSpeciesLabel(animalsHere);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Ocupación animal',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _StatusChip(status: overCapacity ? 'Excedido' : 'En rango'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${percent.toStringAsFixed(0)}% carga animal',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: ratio.clamp(0, 1),
                          minHeight: 12,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          color: overCapacity
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                        ),
                      ),
                      if (overCapacity)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'Capacidad sobrepasada: reasigna o mueve animales',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _MetricBadge(
                      label: 'Animales',
                      value: '$current',
                      icon: Icons.pets_outlined,
                    ),
                    const SizedBox(height: 8),
                    _MetricBadge(
                      label: 'Capacidad',
                      value: rawCapacity > 0 ? '$rawCapacity' : 'Sin dato',
                      icon: Icons.inventory_2_outlined,
                    ),
                    const SizedBox(height: 8),
                    _MetricBadge(
                      label: 'Densidad',
                      value: '${density.toStringAsFixed(2)} cab/ha',
                      icon: Icons.bubble_chart_outlined,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetricBadge(
                  label: 'Días de ocupación',
                  value: occupancyDays == null ? 'N/D' : '$occupancyDays días',
                  icon: Icons.calendar_today_outlined,
                ),
                _MetricBadge(
                  label: 'Entrada lote',
                  value: entryDate == null
                      ? 'Sin fecha'
                      : '${entryDate.day}/${entryDate.month}/${entryDate.year}',
                  icon: Icons.login_outlined,
                ),
                _MetricBadge(
                  label: 'Lotes presentes',
                  value: lotCount == 0 ? 'Sin lotes' : '$lotCount lotes',
                  icon: Icons.view_list_outlined,
                ),
                _MetricBadge(
                  label: 'Especie dominante',
                  value: dominantSpecies ?? 'Sin animales',
                  icon: Icons.compass_calibration_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InventorySection extends StatelessWidget {
  const _InventorySection({required this.location});

  final LocationEntity location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastWater = location.waters.isNotEmpty ? location.waters.last : null;
    final lastShade = location.shades.isNotEmpty ? location.shades.last : null;
    final lastPasture = location.pastures.isNotEmpty
        ? location.pastures.last
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Inventarios del potrero',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(Icons.storage_rounded),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 620;
                final itemWidth = isWide
                    ? (constraints.maxWidth - 12) / 2
                    : constraints.maxWidth;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: itemWidth,
                      child: _InventoryTile(
                        title: 'Agua',
                        icon: Icons.water_drop_outlined,
                        percent: lastWater?.level,
                        subtitle: location.waterSource,
                        meta: lastWater == null
                            ? 'Sin lecturas'
                            : 'Tipo ${_capitalize(lastWater.type.name)}',
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _InventoryTile(
                        title: 'Sombra / confort',
                        icon: Icons.park_outlined,
                        percent: lastShade?.shadePercent,
                        subtitle:
                            lastShade?.condition ?? 'Condición no registrada',
                        meta: 'Cobertura natural o artificial',
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _InventoryTile(
                        title: 'Forraje / pasto',
                        icon: Icons.grass_outlined,
                        percent: lastPasture?.carryingCapacity == null
                            ? null
                            : (lastPasture!.carryingCapacity * 10)
                                  .clamp(0, 100)
                                  .toDouble(),
                        subtitle:
                            lastPasture?.grassType ??
                            'Tipo de pasto no definido',
                        meta: lastPasture == null
                            ? 'Capacidad de carga sin registrar'
                            : 'Condición ${lastPasture.condition}',
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _InventoryTile(
                        title: 'Minerales y sal',
                        icon: Icons.scatter_plot_outlined,
                        percent: location.salts.isEmpty
                            ? null
                            : (50 + (10 * location.salts.length).clamp(0, 50))
                                  .toDouble(),
                        subtitle: 'Suministro estimado',
                        meta: location.salts.isEmpty
                            ? 'Registra ingestas para ver autonomía'
                            : 'Aplicaciones: ${location.salts.length}',
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ConditionSection extends StatelessWidget {
  const _ConditionSection({required this.location});

  final LocationEntity location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    double rain7 = 0;
    double rain30 = 0;
    DateTime? lastRainDate;
    double? lastRainMm;

    for (final rain in location.rains) {
      final diff = now.difference(rain.date).inDays;
      if (diff <= 30) rain30 += rain.millimeters;
      if (diff <= 7) rain7 += rain.millimeters;
      if (lastRainDate == null || rain.date.isAfter(lastRainDate)) {
        lastRainDate = rain.date;
        lastRainMm = rain.millimeters;
      }
    }

    final lastPasture = location.pastures.isNotEmpty
        ? location.pastures.last
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Condición del área',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(Icons.eco_outlined),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _ConditionRow(
                  icon: Icons.grass_outlined,
                  label: 'Condición pasto',
                  value: lastPasture?.condition ?? 'Sin registrar',
                ),
                _ConditionRow(
                  icon: Icons.cloudy_snowing,
                  label: 'Última lluvia',
                  value: lastRainDate == null
                      ? 'Sin registros'
                      : '${lastRainMm?.toStringAsFixed(1) ?? '-'} mm • ${lastRainDate.day}/${lastRainDate.month}',
                ),
                _ConditionRow(
                  icon: Icons.water_outlined,
                  label: 'Lluvia 7 días',
                  value: '${rain7.toStringAsFixed(1)} mm',
                ),
                _ConditionRow(
                  icon: Icons.water_outlined,
                  label: 'Lluvia 30 días',
                  value: '${rain30.toStringAsFixed(1)} mm',
                ),
                const _ConditionRow(
                  icon: Icons.warning_amber_outlined,
                  label: 'Erosión',
                  value: 'Inspección visual pendiente',
                ),
                const _ConditionRow(
                  icon: Icons.local_florist_outlined,
                  label: 'Maleza / arbustos',
                  value: 'Monitorea maleza y plantas tóxicas',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfrastructureSection extends StatelessWidget {
  const _InfrastructureSection({required this.location});

  final LocationEntity location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastWater = location.waters.isNotEmpty ? location.waters.last : null;
    final lastShade = location.shades.isNotEmpty ? location.shades.last : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Infraestructura',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(Icons.foundation_outlined),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _ConditionRow(
                  icon: Icons.water_drop_outlined,
                  label: 'Bebederos',
                  value: lastWater == null
                      ? 'Sin registrar'
                      : 'Fuente ${_capitalize(lastWater.type.name)}',
                ),
                _ConditionRow(
                  icon: Icons.park_outlined,
                  label: 'Sombras',
                  value: lastShade == null
                      ? 'Pendiente'
                      : '${lastShade.shadePercent.toStringAsFixed(0)}% • ${lastShade.condition}',
                ),
                const _ConditionRow(
                  icon: Icons.fence_outlined,
                  label: 'Cercos',
                  value: 'Estado pendiente de inspección',
                ),
                const _ConditionRow(
                  icon: Icons.agriculture_outlined,
                  label: 'Comederos / saladeros',
                  value: 'Registrar inspección y limpieza',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WarehouseSection extends StatelessWidget {
  const _WarehouseSection({required this.location});

  final LocationEntity location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Modo almacén',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(Icons.warehouse_outlined),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Configura inventarios de alimento y herramientas para ${location.name}.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            const Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ConditionRow(
                  icon: Icons.inventory_2_outlined,
                  label: 'Alimento',
                  value: 'Agrega existencias, capacidad y días de autonomía',
                ),
                _ConditionRow(
                  icon: Icons.handyman_outlined,
                  label: 'Herramientas',
                  value: 'Controla estado, cantidad y alertas de mantenimiento',
                ),
                _ConditionRow(
                  icon: Icons.warning_amber_outlined,
                  label: 'Alertas',
                  value: 'Genera alertas de bajo inventario o equipo en taller',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationRecords extends StatelessWidget {
  const _LocationRecords({required this.location});

  final LocationEntity location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bitácora',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                _RecordCount(label: 'Visitas', count: location.visits.length),
                _RecordCount(label: 'Agua', count: location.waters.length),
                _RecordCount(label: 'Sal', count: location.salts.length),
                _RecordCount(label: 'Sombra', count: location.shades.length),
                _RecordCount(
                  label: 'Pasturas',
                  count: location.pastures.length,
                ),
                _RecordCount(label: 'Siembra', count: location.seedings.length),
                _RecordCount(
                  label: 'Riego',
                  count: location.irrigations.length,
                ),
                _RecordCount(label: 'Lluvia', count: location.rains.length),
                _RecordCount(label: 'Costos', count: location.costs.length),
                _RecordCount(label: 'Cultivos', count: location.crops.length),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  const _MetricBadge({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InventoryTile extends StatelessWidget {
  const _InventoryTile({
    required this.title,
    required this.icon,
    required this.subtitle,
    required this.meta,
    this.percent,
  });

  final String title;
  final IconData icon;
  final double? percent;
  final String subtitle;
  final String meta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayPercent = percent?.clamp(0, 100).toDouble();
    final barColor = displayPercent == null
        ? theme.colorScheme.surfaceContainerHighest
        : displayPercent >= 75
        ? theme.colorScheme.primary
        : displayPercent >= 40
        ? theme.colorScheme.secondary
        : theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: barColor.withValues(alpha: 0.18),
                child: Icon(icon, color: barColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Text(
                displayPercent == null
                    ? 'N/D'
                    : '${displayPercent.toStringAsFixed(0)}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: displayPercent == null
                  ? 0
                  : (displayPercent / 100).clamp(0, 1),
              minHeight: 10,
              backgroundColor: theme.colorScheme.surface,
              color: barColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            meta,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConditionRow extends StatelessWidget {
  const _ConditionRow({
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Upcoming Tasks Card ─────────────────────────────────────────────────

class _UpcomingTasksCard extends StatelessWidget {
  const _UpcomingTasksCard({required this.location, required this.onComplete});

  final LocationEntity location;
  final void Function(String cropUuid, String taskUuid) onComplete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    // Collect all pending tasks across active crops
    final allTasks = <({CropRecord crop, CropTask task})>[];
    for (final crop in location.crops) {
      if (crop.status != CropStatus.active) continue;
      for (final task in crop.tasks) {
        if (!task.completed) {
          allTasks.add((crop: crop, task: task));
        }
      }
      // Auto-generate watering alert if overdue
      if (crop.isOverdueForWatering) {
        allTasks.add((
          crop: crop,
          task: CropTask(
            uuid: 'auto-water-${crop.uuid}',
            type: CropTaskType.water,
            dueDate: crop.nextWateringDate ?? now,
            notes: 'Riego atrasado',
          ),
        ));
      }
      // Harvest approaching alert
      final daysLeft = crop.daysUntilHarvest;
      if (daysLeft != null && daysLeft <= 7 && daysLeft >= 0) {
        allTasks.add((
          crop: crop,
          task: CropTask(
            uuid: 'auto-harvest-${crop.uuid}',
            type: CropTaskType.harvest,
            dueDate: crop.expectedHarvestDate ?? now,
            notes: '$daysLeft días para cosecha',
          ),
        ));
      }
    }

    allTasks.sort((a, b) => a.task.dueDate.compareTo(b.task.dueDate));

    if (allTasks.isEmpty) return const SizedBox.shrink();

    return Card(
      color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pending_actions_outlined,
                  color: theme.colorScheme.tertiary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tareas pendientes',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...allTasks.take(8).map((entry) {
              final isOverdue = entry.task.dueDate.isBefore(now);
              final isAuto = entry.task.uuid.startsWith('auto-');
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    if (!isAuto)
                      InkWell(
                        onTap: () =>
                            onComplete(entry.crop.uuid, entry.task.uuid),
                        child: Icon(
                          Icons.check_circle_outline,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    else
                      Icon(
                        isOverdue
                            ? Icons.warning_amber_outlined
                            : Icons.info_outline,
                        size: 20,
                        color: isOverdue
                            ? theme.colorScheme.error
                            : theme.colorScheme.tertiary,
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${entry.task.type.displayName} — ${entry.crop.cropName}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isOverdue ? theme.colorScheme.error : null,
                        ),
                      ),
                    ),
                    Text(
                      '${entry.task.dueDate.day}/${entry.task.dueDate.month}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isOverdue
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Crops Section ───────────────────────────────────────────────────────

class _CropsSection extends StatelessWidget {
  const _CropsSection({
    required this.location,
    required this.onAddCrop,
    required this.onEditCrop,
    required this.onDeleteCrop,
    required this.onWaterCrop,
    required this.onHarvestCrop,
    required this.onHealthCrop,
    required this.onAddTask,
    required this.onCompleteTask,
  });

  final LocationEntity location;
  final VoidCallback onAddCrop;
  final ValueChanged<CropRecord> onEditCrop;
  final ValueChanged<CropRecord> onDeleteCrop;
  final ValueChanged<CropRecord> onWaterCrop;
  final ValueChanged<CropRecord> onHarvestCrop;
  final ValueChanged<CropRecord> onHealthCrop;
  final ValueChanged<CropRecord> onAddTask;
  final void Function(CropRecord crop, String taskUuid) onCompleteTask;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeCrops = location.crops
        .where((c) => c.status == CropStatus.active)
        .toList();
    final pastCrops = location.crops
        .where((c) => c.status != CropStatus.active)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Cultivos (${location.crops.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: onAddCrop,
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (location.crops.isEmpty) const Text('Sin cultivos registrados'),
            if (activeCrops.isNotEmpty) ...[
              Text(
                'Activos',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              ...activeCrops.map(
                (crop) => _CropTile(
                  crop: crop,
                  onEdit: () => onEditCrop(crop),
                  onDelete: () => onDeleteCrop(crop),
                  onWater: () => onWaterCrop(crop),
                  onHarvest: () => onHarvestCrop(crop),
                  onHealth: () => onHealthCrop(crop),
                  onAddTask: () => onAddTask(crop),
                  onCompleteTask: (taskUuid) => onCompleteTask(crop, taskUuid),
                ),
              ),
            ],
            if (pastCrops.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Anteriores',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              ...pastCrops.map(
                (crop) => _CropTile(
                  crop: crop,
                  onEdit: () => onEditCrop(crop),
                  onDelete: () => onDeleteCrop(crop),
                  onWater: null,
                  onHarvest: null,
                  onHealth: null,
                  onAddTask: null,
                  onCompleteTask: null,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CropTile extends StatelessWidget {
  const _CropTile({
    required this.crop,
    required this.onEdit,
    required this.onDelete,
    required this.onWater,
    required this.onHarvest,
    required this.onHealth,
    required this.onAddTask,
    required this.onCompleteTask,
  });

  final CropRecord crop;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onWater;
  final VoidCallback? onHarvest;
  final VoidCallback? onHealth;
  final VoidCallback? onAddTask;
  final ValueChanged<String>? onCompleteTask;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = crop.status == CropStatus.active;
    final overdue = crop.isOverdueForWatering;
    final daysLeft = crop.daysUntilHarvest;
    final pendingTasks = crop.tasks.where((t) => !t.completed).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: overdue
            ? Border.all(color: theme.colorScheme.error.withValues(alpha: 0.5))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: isActive
                    ? theme.colorScheme.primary.withValues(alpha: 0.15)
                    : theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.eco_outlined,
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crop.cropName +
                          (crop.variety.isNotEmpty ? ' (${crop.variety})' : ''),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${crop.growthStage.displayName} • ${crop.status.displayName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                    case 'delete':
                      onDelete();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Timeline info
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _CropInfoChip(
                icon: Icons.calendar_today_outlined,
                label:
                    'Siembra: ${crop.plantingDate.day}/${crop.plantingDate.month}/${crop.plantingDate.year}',
              ),
              if (crop.expectedHarvestDate != null)
                _CropInfoChip(
                  icon: Icons.event_outlined,
                  label: daysLeft != null && daysLeft >= 0
                      ? 'Cosecha en $daysLeft días'
                      : 'Cosecha: ${crop.expectedHarvestDate!.day}/${crop.expectedHarvestDate!.month}',
                  isWarning: daysLeft != null && daysLeft <= 7,
                ),
              if (crop.lastWateredDate != null)
                _CropInfoChip(
                  icon: Icons.water_drop_outlined,
                  label: overdue
                      ? 'Riego atrasado'
                      : 'Regado: ${crop.lastWateredDate!.day}/${crop.lastWateredDate!.month}',
                  isError: overdue,
                ),
              if (crop.lastWateredDate == null && isActive)
                const _CropInfoChip(
                  icon: Icons.water_drop_outlined,
                  label: 'Sin riego registrado',
                  isError: true,
                ),
              if (crop.surface > 0)
                _CropInfoChip(
                  icon: Icons.straighten_outlined,
                  label: '${crop.surface.toStringAsFixed(1)} ha',
                ),
              if (crop.totalYieldKg > 0)
                _CropInfoChip(
                  icon: Icons.scale_outlined,
                  label: '${crop.totalYieldKg.toStringAsFixed(1)} kg cosechado',
                ),
              _CropInfoChip(
                icon: Icons.water_drop,
                label: 'Riegos: ${crop.waterings.length}',
              ),
              if (crop.harvests.isNotEmpty)
                _CropInfoChip(
                  icon: Icons.agriculture_outlined,
                  label: 'Cosechas: ${crop.harvests.length}',
                ),
              if (crop.healthRecords.isNotEmpty)
                _CropInfoChip(
                  icon: Icons.bug_report_outlined,
                  label: 'Salud: ${crop.healthRecords.length}',
                ),
            ],
          ),

          // Pending tasks
          if (pendingTasks.isNotEmpty && isActive) ...[
            const SizedBox(height: 8),
            ...pendingTasks
                .take(3)
                .map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => onCompleteTask?.call(task.uuid),
                          child: Icon(
                            Icons.check_circle_outline,
                            size: 18,
                            color: task.isOverdue
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${task.type.displayName} — ${task.dueDate.day}/${task.dueDate.month}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: task.isOverdue
                                  ? theme.colorScheme.error
                                  : null,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],

          // Action buttons
          if (isActive) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _CropActionChip(
                  icon: Icons.water_drop_outlined,
                  label: 'Regar',
                  onPressed: onWater,
                ),
                _CropActionChip(
                  icon: Icons.agriculture_outlined,
                  label: 'Cosechar',
                  onPressed: onHarvest,
                ),
                _CropActionChip(
                  icon: Icons.bug_report_outlined,
                  label: 'Salud',
                  onPressed: onHealth,
                ),
                _CropActionChip(
                  icon: Icons.add_task_outlined,
                  label: 'Tarea',
                  onPressed: onAddTask,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CropInfoChip extends StatelessWidget {
  const _CropInfoChip({
    required this.icon,
    required this.label,
    this.isWarning = false,
    this.isError = false,
  });

  final IconData icon;
  final String label;
  final bool isWarning;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isError
        ? theme.colorScheme.error
        : isWarning
        ? Colors.orange
        : theme.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isError
            ? theme.colorScheme.errorContainer.withValues(alpha: 0.3)
            : isWarning
            ? Colors.orange.withValues(alpha: 0.1)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CropActionChip extends StatelessWidget {
  const _CropActionChip({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}

class _RecordActions extends StatelessWidget {
  const _RecordActions({
    required this.onVisit,
    required this.onWater,
    required this.onSalt,
    required this.onShade,
    required this.onPasture,
    required this.onCost,
  });

  final VoidCallback onVisit;
  final VoidCallback onWater;
  final VoidCallback onSalt;
  final VoidCallback onShade;
  final VoidCallback onPasture;
  final VoidCallback onCost;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registrar',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ActionButton(
                  icon: Icons.fact_check_outlined,
                  label: 'Visita',
                  onPressed: onVisit,
                ),
                _ActionButton(
                  icon: Icons.water_drop_outlined,
                  label: 'Agua',
                  onPressed: onWater,
                ),
                _ActionButton(
                  icon: Icons.scatter_plot_outlined,
                  label: 'Sal',
                  onPressed: onSalt,
                ),
                _ActionButton(
                  icon: Icons.nature_outlined,
                  label: 'Sombra',
                  onPressed: onShade,
                ),
                _ActionButton(
                  icon: Icons.grass_outlined,
                  label: 'Pastura',
                  onPressed: onPasture,
                ),
                _ActionButton(
                  icon: Icons.payments_outlined,
                  label: 'Costo',
                  onPressed: onCost,
                ),
              ],
            ),
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
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
    );
  }
}

class _AnimalsSection extends StatelessWidget {
  const _AnimalsSection({
    required this.animalsHere,
    required this.location,
    required this.assigning,
    required this.onAssign,
  });

  final List<AnimalEntity> animalsHere;
  final LocationEntity location;
  final bool assigning;
  final VoidCallback onAssign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Animales (${animalsHere.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: assigning ? null : onAssign,
                  icon: const Icon(Icons.pets_outlined),
                  label: const Text('Asignar / mover'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (animalsHere.isEmpty)
              const Text('Sin animales en esta ubicación')
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: animalsHere.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final animal = animalsHere[index];
                  final subtitle = _animalSubtitle(animal);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_animalTitle(animal)),
                    subtitle: subtitle == null ? null : Text(subtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        context.push(AppRoutes.animalDetallePath(animal.uuid)),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _animalTitle(AnimalEntity animal) {
    return animal.earTagNumber.isNotEmpty
        ? animal.earTagNumber
        : (animal.visualId?.isNotEmpty == true ? animal.visualId! : 'Animal');
  }

  String? _animalSubtitle(AnimalEntity animal) {
    final breed = animal.breed;
    final species = animal.species.displayName;
    final stage = animal.lifeStage.displayName;
    final pieces = [breed, species, stage].where((e) => e.isNotEmpty).toList();
    if (pieces.isEmpty) return null;
    return pieces.join(' • ');
  }
}

class _ActionsRow extends StatelessWidget {
  const _ActionsRow({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Editar ubicación'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Eliminar'),
          ),
        ),
      ],
    );
  }
}

class _AssignAnimalsSheet extends StatefulWidget {
  const _AssignAnimalsSheet({
    required this.allAnimals,
    required this.initiallySelected,
    required this.locationName,
  });

  final List<AnimalEntity> allAnimals;
  final Set<String> initiallySelected;
  final String locationName;

  @override
  State<_AssignAnimalsSheet> createState() => _AssignAnimalsSheetState();
}

class _AssignAnimalsSheetState extends State<_AssignAnimalsSheet> {
  late final Set<String> _selected = Set<String>.from(widget.initiallySelected);

  @override
  Widget build(BuildContext context) {
    final animals = widget.allAnimals;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Asignar animales a ${widget.locationName}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 420),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: animals.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final animal = animals[index];
                  final checked = _selected.contains(animal.uuid);
                  return CheckboxListTile(
                    value: checked,
                    title: Text(_animalTitle(animal)),
                    subtitle: Text(
                      animal.breed.isNotEmpty
                          ? '${animal.breed} • ${animal.species.displayName}'
                          : animal.species.displayName,
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selected.add(animal.uuid);
                        } else {
                          _selected.remove(animal.uuid);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.save_outlined),
                label: const Text('Guardar'),
                onPressed: () => Navigator.of(context).pop(_selected),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _animalTitle(AnimalEntity animal) {
    return animal.earTagNumber.isNotEmpty
        ? animal.earTagNumber
        : (animal.visualId?.isNotEmpty == true ? animal.visualId! : 'Animal');
  }
}

class _RecordCount extends StatelessWidget {
  const _RecordCount({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        const SizedBox(width: 6),
        CircleAvatar(
          radius: 12,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.12),
          child: Text(
            '$count',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      label: Text(_capitalize(status)),
      backgroundColor: theme.colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: theme.colorScheme.onPrimaryContainer,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _VisitRecordSheet extends StatefulWidget {
  const _VisitRecordSheet({required this.locationName});

  final String locationName;

  @override
  State<_VisitRecordSheet> createState() => _VisitRecordSheetState();
}

class _VisitRecordSheetState extends State<_VisitRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _animalsController;
  late final TextEditingController _notesController;
  late final TextEditingController _userController;

  @override
  void initState() {
    super.initState();
    _animalsController = TextEditingController();
    _notesController = TextEditingController();
    _userController = TextEditingController();
  }

  @override
  void dispose() {
    _animalsController.dispose();
    _notesController.dispose();
    _userController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetHeader(
                title: 'Registrar visita',
                subtitle: widget.locationName,
              ),
              TextFormField(
                controller: _animalsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Animales observados',
                  prefixIcon: Icon(Icons.groups_outlined),
                ),
                validator: (value) {
                  final parsed = int.tryParse(value ?? '');
                  if (parsed == null || parsed < 0) {
                    return 'Ingresa un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _userController,
                decoration: const InputDecoration(
                  labelText: 'Responsable (opcional)',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar visita'),
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final animals = int.parse(_animalsController.text);
    final record = VisitRecord(
      date: DateTime.now(),
      animals: animals,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      user: _userController.text.trim().isEmpty
          ? null
          : _userController.text.trim(),
    );
    Navigator.of(context).pop(record);
  }
}

class _WaterRecordSheet extends StatefulWidget {
  const _WaterRecordSheet({required this.locationName});

  final String locationName;

  @override
  State<_WaterRecordSheet> createState() => _WaterRecordSheetState();
}

class _WaterRecordSheetState extends State<_WaterRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _levelController;
  late final TextEditingController _notesController;
  WaterType _type = WaterType.pozo;

  @override
  void initState() {
    super.initState();
    _levelController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _levelController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetHeader(
                title: 'Registrar agua',
                subtitle: widget.locationName,
              ),
              TextFormField(
                controller: _levelController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Nivel (%)',
                  prefixIcon: Icon(Icons.water_drop_outlined),
                ),
                validator: (value) {
                  final parsed = double.tryParse(value ?? '');
                  if (parsed == null || parsed < 0) return 'Ingresa un nivel';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<WaterType>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Tipo de agua',
                  prefixIcon: Icon(Icons.tune),
                ),
                items: WaterType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(_capitalize(type.name)),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _type = value ?? WaterType.pozo),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar agua'),
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final level = double.parse(_levelController.text);
    final record = WaterRecord(
      date: DateTime.now(),
      level: level,
      type: _type,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    Navigator.of(context).pop(record);
  }
}

class _SaltRecordSheet extends StatefulWidget {
  const _SaltRecordSheet({required this.locationName});

  final String locationName;

  @override
  State<_SaltRecordSheet> createState() => _SaltRecordSheetState();
}

class _SaltRecordSheetState extends State<_SaltRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetHeader(
                title: 'Registrar sal/mineral',
                subtitle: widget.locationName,
              ),
              TextFormField(
                controller: _quantityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Cantidad (kg)',
                  prefixIcon: Icon(Icons.scatter_plot_outlined),
                ),
                validator: (value) {
                  final parsed = double.tryParse(value ?? '');
                  if (parsed == null || parsed < 0) {
                    return 'Ingresa una cantidad';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar sal/mineral'),
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final qty = double.parse(_quantityController.text);
    final record = SaltRecord(
      date: DateTime.now(),
      quantityKg: qty,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    Navigator.of(context).pop(record);
  }
}

class _ShadeRecordSheet extends StatefulWidget {
  const _ShadeRecordSheet({required this.locationName});

  final String locationName;

  @override
  State<_ShadeRecordSheet> createState() => _ShadeRecordSheetState();
}

class _ShadeRecordSheetState extends State<_ShadeRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _percentController;
  late final TextEditingController _conditionController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _percentController = TextEditingController();
    _conditionController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _percentController.dispose();
    _conditionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetHeader(
                title: 'Registrar sombra',
                subtitle: widget.locationName,
              ),
              TextFormField(
                controller: _percentController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Cobertura (%)',
                  prefixIcon: Icon(Icons.park_outlined),
                ),
                validator: (value) {
                  final parsed = double.tryParse(value ?? '');
                  if (parsed == null || parsed < 0) {
                    return 'Ingresa un porcentaje';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _conditionController,
                decoration: const InputDecoration(
                  labelText: 'Condición / infraestructura',
                  prefixIcon: Icon(Icons.nature_outlined),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Ingresa una condición'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar sombra'),
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final percent = double.parse(_percentController.text);
    final record = ShadeRecord(
      date: DateTime.now(),
      shadePercent: percent,
      condition: _conditionController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    Navigator.of(context).pop(record);
  }
}

class _PastureRecordSheet extends StatefulWidget {
  const _PastureRecordSheet({required this.locationName});

  final String locationName;

  @override
  State<_PastureRecordSheet> createState() => _PastureRecordSheetState();
}

class _PastureRecordSheetState extends State<_PastureRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _grassController;
  late final TextEditingController _conditionController;
  late final TextEditingController _capacityController;

  @override
  void initState() {
    super.initState();
    _grassController = TextEditingController();
    _conditionController = TextEditingController();
    _capacityController = TextEditingController();
  }

  @override
  void dispose() {
    _grassController.dispose();
    _conditionController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetHeader(
                title: 'Registrar pastura',
                subtitle: widget.locationName,
              ),
              TextFormField(
                controller: _grassController,
                decoration: const InputDecoration(
                  labelText: 'Tipo de pasto',
                  prefixIcon: Icon(Icons.grass_outlined),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Ingresa el tipo de pasto'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _conditionController,
                decoration: const InputDecoration(
                  labelText: 'Condición',
                  prefixIcon: Icon(Icons.brightness_medium_outlined),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Ingresa la condición'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _capacityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Capacidad de carga (UA/ha)',
                  prefixIcon: Icon(Icons.timeline_outlined),
                ),
                validator: (value) {
                  final parsed = double.tryParse(value ?? '');
                  if (parsed == null || parsed < 0) {
                    return 'Ingresa una capacidad';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar pastura'),
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final record = PastureRecord(
      date: DateTime.now(),
      grassType: _grassController.text.trim(),
      condition: _conditionController.text.trim(),
      carryingCapacity: double.parse(_capacityController.text),
    );
    Navigator.of(context).pop(record);
  }
}

class _CostRecordSheet extends StatefulWidget {
  const _CostRecordSheet({required this.locationName});

  final String locationName;

  @override
  State<_CostRecordSheet> createState() => _CostRecordSheetState();
}

class _CostRecordSheetState extends State<_CostRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _maintenanceController;
  late final TextEditingController _fencesController;
  late final TextEditingController _repairsController;
  late final TextEditingController _laborController;
  late final TextEditingController _totalController;

  @override
  void initState() {
    super.initState();
    _maintenanceController = TextEditingController();
    _fencesController = TextEditingController();
    _repairsController = TextEditingController();
    _laborController = TextEditingController();
    _totalController = TextEditingController();
  }

  @override
  void dispose() {
    _maintenanceController.dispose();
    _fencesController.dispose();
    _repairsController.dispose();
    _laborController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetHeader(
                title: 'Registrar costo',
                subtitle: widget.locationName,
              ),
              _moneyField(
                _maintenanceController,
                'Mantenimiento',
                Icons.build_outlined,
              ),
              const SizedBox(height: 12),
              _moneyField(_fencesController, 'Cercas', Icons.fence_outlined),
              const SizedBox(height: 12),
              _moneyField(
                _repairsController,
                'Reparaciones',
                Icons.handyman_outlined,
              ),
              const SizedBox(height: 12),
              _moneyField(
                _laborController,
                'Mano de obra',
                Icons.badge_outlined,
              ),
              const SizedBox(height: 12),
              _moneyField(
                _totalController,
                'Total (opcional)',
                Icons.payments_outlined,
                required: false,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar costo'),
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _moneyField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: (value) {
        if (!required && (value == null || value.isEmpty)) return null;
        final parsed = double.tryParse(value ?? '');
        if (parsed == null || parsed < 0) return 'Ingresa un monto';
        return null;
      },
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    double parseOrZero(TextEditingController ctrl) =>
        double.tryParse(ctrl.text.isEmpty ? '0' : ctrl.text) ?? 0;

    final maintenance = parseOrZero(_maintenanceController);
    final fences = parseOrZero(_fencesController);
    final repairs = parseOrZero(_repairsController);
    final labor = parseOrZero(_laborController);
    final total = _totalController.text.trim().isEmpty
        ? (maintenance + fences + repairs + labor)
        : (double.tryParse(_totalController.text) ??
              maintenance + fences + repairs + labor);

    final record = CostRecord(
      date: DateTime.now(),
      maintenance: maintenance,
      fences: fences,
      repairs: repairs,
      labor: labor,
      total: total,
    );

    Navigator.of(context).pop(record);
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}
