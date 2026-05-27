/// features \u203a ubicaciones \u203a view \u203a location_detail_page \u2014 detail page for a single location.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_records.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/features/ubicaciones/widgets/crop_sheets.dart';
import 'package:libretapp/features/ubicaciones/view/assign_animals_page.dart';
import 'package:libretapp/features/ubicaciones/view/location_detail_widgets.dart';
import 'package:libretapp/features/ubicaciones/view/location_record_sheets.dart';

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
  late final MovementRecordRepository _movementRepository;
  bool _assigning = false;

  @override
  void initState() {
    super.initState();
    _locationRepository =
        widget.locationRepository ?? locator<LocationRepository>();
    _animalRepository = widget.animalRepository ?? locator<AnimalRepository>();
    _movementRepository = locator<MovementRecordRepository>();
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
                      LocationHeader(
                        location: location,
                        animalsHere: animalsHere,
                      ),
                      const SizedBox(height: 12),
                      OccupancyCard(
                        location: location,
                        animalsHere: animalsHere,
                      ),
                      const SizedBox(height: 12),
                      InventorySection(location: location),
                      const SizedBox(height: 12),
                      ConditionSection(location: location),
                      const SizedBox(height: 12),
                      InfrastructureSection(location: location),
                      if (_isWarehouse(location)) ...[
                        const SizedBox(height: 12),
                        WarehouseSection(location: location),
                      ],
                      const SizedBox(height: 12),
                      RecordActions(
                        onVisit: () => _showVisitSheet(location),
                        onWater: () => _showWaterSheet(location),
                        onSalt: () => _showSaltSheet(location),
                        onShade: () => _showShadeSheet(location),
                        onPasture: () => _showPastureSheet(location),
                        onCost: () => _showCostSheet(location),
                      ),
                      if (_hasUpcomingTasks(location)) ...[
                        const SizedBox(height: 12),
                        UpcomingTasksCard(
                          location: location,
                          onComplete: (cropUuid, taskUuid) =>
                              _completeCropTask(location, cropUuid, taskUuid),
                        ),
                      ],
                      const SizedBox(height: 12),
                      CropsSection(
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
                        LocationRecords(location: location),
                      ],
                      const SizedBox(height: 12),
                      ActivitiesSection(location: location),
                      const SizedBox(height: 20),
                      AnimalsSection(
                        animalsHere: animalsHere,
                        location: location,
                        assigning: _assigning,
                        onAssign: () => _showAssignAnimalsSheet(
                          location,
                          animals,
                          animalsHere,
                          locations,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ActionsRow(
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
    List<LocationEntity> allLocations,
  ) async {
    if (_assigning) return;
    setState(() => _assigning = true);
    final selected = {for (final animal in animalsHere) animal.uuid};

    final result = await _openRecordFormPage<Set<String>>(
      AssignAnimalsPage(
        allAnimals: allAnimals,
        initiallySelected: selected,
        locationName: location.name,
        allLocations: allLocations,
      ),
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
    final now = DateTime.now();
    final updateTasks = <Future<void>>[];
    final movementTasks = <Future<void>>[];

    for (final animal in animals) {
      final oldLocId = animal.currentPaddockId ?? animal.initialLocationId;
      final shouldBeHere = selected.contains(animal.uuid);
      final alreadyHere = oldLocId == location.uuid;
      if (shouldBeHere == alreadyHere) continue;

      final newLocId = shouldBeHere ? location.uuid : null;
      final updated = animal.copyWith(
        currentPaddockId: newLocId,
        initialLocationId: animal.initialLocationId ?? newLocId,
        lastMovementDate: shouldBeHere ? now : animal.lastMovementDate,
        lastUpdateDate: now,
        synced: false,
      );
      updateTasks.add(_animalRepository.update(updated));

      // Create a movement record with real FK UUIDs.
      if (newLocId != null || oldLocId != null) {
        final record = MovementRecord(
          fromLocation: oldLocId,
          toLocation: newLocId ?? oldLocId ?? '',
          date: now,
          reason: MovementReason.paddockRotation,
        );
        movementTasks.add(
          _movementRepository.addMovementRecord(animal.uuid, record),
        );
      }
    }

    await Future.wait(updateTasks);
    await Future.wait(movementTasks);
  }

  Future<T?> _openRecordFormPage<T>(Widget child) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute<T>(
        fullscreenDialog: true,
        builder: (context) {
          return ShellChromeScope(visible: false, child: Scaffold(body: child));
        },
      ),
    );
  }

  Future<void> _showVisitSheet(LocationEntity location) async {
    final record = await _openRecordFormPage<VisitRecord>(
      VisitRecordSheet(locationName: location.name),
    );

    if (record != null) {
      await _locationRepository.addVisit(location.uuid, record);
    }
  }

  Future<void> _showWaterSheet(LocationEntity location) async {
    final record = await _openRecordFormPage<WaterRecord>(
      WaterRecordSheet(locationName: location.name),
    );

    if (record != null) {
      await _locationRepository.addWater(location.uuid, record);
    }
  }

  Future<void> _showSaltSheet(LocationEntity location) async {
    final record = await _openRecordFormPage<SaltRecord>(
      SaltRecordSheet(locationName: location.name),
    );

    if (record != null) {
      await _locationRepository.addSalt(location.uuid, record);
    }
  }

  Future<void> _showShadeSheet(LocationEntity location) async {
    final record = await _openRecordFormPage<ShadeRecord>(
      ShadeRecordSheet(locationName: location.name),
    );

    if (record != null) {
      await _locationRepository.addShade(location.uuid, record);
    }
  }

  Future<void> _showPastureSheet(LocationEntity location) async {
    final record = await _openRecordFormPage<PastureRecord>(
      PastureRecordSheet(locationName: location.name),
    );

    if (record != null) {
      await _locationRepository.addPasture(location.uuid, record);
    }
  }

  Future<void> _showCostSheet(LocationEntity location) async {
    final record = await _openRecordFormPage<CostRecord>(
      CostRecordSheet(locationName: location.name),
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
    final crop = await _openRecordFormPage<CropRecord>(
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
    final record = await _openRecordFormPage<CropWateringRecord>(
      CropWateringFormSheet(cropName: crop.cropName),
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
    final record = await _openRecordFormPage<HarvestRecord>(
      HarvestFormSheet(cropName: crop.cropName),
    );

    if (record != null) {
      await _locationRepository.addHarvest(location.uuid, crop.uuid, record);
    }
  }

  Future<void> _showCropHealthSheet(
    LocationEntity location,
    CropRecord crop,
  ) async {
    final record = await _openRecordFormPage<CropHealthRecord>(
      CropHealthFormSheet(cropName: crop.cropName),
    );

    if (record != null) {
      await _locationRepository.addCropHealth(location.uuid, crop.uuid, record);
    }
  }

  Future<void> _showCropTaskSheet(
    LocationEntity location,
    CropRecord crop,
  ) async {
    final task = await _openRecordFormPage<CropTask>(
      CropTaskFormSheet(cropName: crop.cropName),
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

  bool _isWarehouse(LocationEntity l) => l.type.supportsInventory;
}
