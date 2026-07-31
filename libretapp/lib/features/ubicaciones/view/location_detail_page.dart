/// features › ubicaciones › view › location_detail_page — detail page for a single location.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/ubicaciones/cubit/location_detail_cubit.dart';
import 'package:libretapp/features/ubicaciones/cubit/location_detail_state.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_records.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/features/ubicaciones/view/assign_animals_page.dart';
import 'package:libretapp/features/ubicaciones/view/location_detail_widgets.dart';
import 'package:libretapp/features/ubicaciones/view/location_record_sheets.dart';
import 'package:libretapp/features/ubicaciones/widgets/confirm_delete_location_dialog.dart';
import 'package:libretapp/features/ubicaciones/widgets/crop_sheets.dart';

class LocationDetailPage extends StatelessWidget {
  LocationDetailPage({
    super.key,
    required this.locationUuid,
    LocationRepository? locationRepository,
    AnimalRepository? animalRepository,
    MovementRecordRepository? movementRepository,
    LocationDetailCubit? cubit,
  }) : _locationRepository = locationRepository ?? locator<LocationRepository>(),
       _animalRepository = animalRepository ?? locator<AnimalRepository>(),
       _movementRepository =
           movementRepository ?? locator<MovementRecordRepository>(),
       _cubit = cubit;

  final String locationUuid;
  final LocationRepository _locationRepository;
  final AnimalRepository _animalRepository;
  final MovementRecordRepository _movementRepository;
  final LocationDetailCubit? _cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          _cubit ??
          LocationDetailCubit(
            locationUuid: locationUuid,
            locationRepository: _locationRepository,
            animalRepository: _animalRepository,
            movementRepository: _movementRepository,
          ),
      child: const _LocationDetailView(),
    );
  }
}

class _LocationDetailView extends StatelessWidget {
  const _LocationDetailView();

  @override
  Widget build(BuildContext context) {
    final bottomPadding = ShellInsets.bottomSafePadding(context);

    return ShellChromeScope(
      visible: false,
      child: Scaffold(
        appBar: AppBar(title: const Text('Ubicación')),
        body: BlocBuilder<LocationDetailCubit, LocationDetailState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.isNotFound) {
              return const Center(child: Text('Ubicación no encontrada'));
            }

            final location = state.location!;
            final animalsHere = state.animalsHere;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (location.imagePaths.isNotEmpty) ...[
                    _LocationDetailImageGallery(imagePaths: location.imagePaths),
                    const SizedBox(height: 12),
                  ],
                  LocationHeader(
                    location: location,
                    animalsHere: animalsHere,
                  ),
                  const SizedBox(height: 12),
                  if (location.type.isRootType) ...[
                    SublocationsSection(
                      location: location,
                      allLocations: state.allLocations,
                    ),
                    const SizedBox(height: 12),
                  ],
                  OccupancyCard(location: location, animalsHere: animalsHere),
                  const SizedBox(height: 12),
                  AdaptivePropertiesSection(location: location),
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
                    onVisit: () => _showVisitSheet(context, location),
                    onWater: () => _showWaterSheet(context, location),
                    onSalt: () => _showSaltSheet(context, location),
                    onShade: () => _showShadeSheet(context, location),
                    onPasture: () => _showPastureSheet(context, location),
                    onCost: () => _showCostSheet(context, location),
                  ),
                  if (_hasUpcomingTasks(location)) ...[
                    const SizedBox(height: 12),
                    UpcomingTasksCard(
                      location: location,
                      onComplete: (cropUuid, taskUuid) => context
                          .read<LocationDetailCubit>()
                          .completeCropTask(cropUuid, taskUuid),
                    ),
                  ],
                  const SizedBox(height: 12),
                  CropsSection(
                    location: location,
                    onAddCrop: () => _showCropFormSheet(context, location),
                    onEditCrop: (crop) =>
                        _showCropFormSheet(context, location, initial: crop),
                    onDeleteCrop: (crop) =>
                        _confirmDeleteCrop(context, location, crop),
                    onWaterCrop: (crop) =>
                        _showCropWateringSheet(context, location, crop),
                    onHarvestCrop: (crop) =>
                        _showHarvestSheet(context, location, crop),
                    onHealthCrop: (crop) =>
                        _showCropHealthSheet(context, location, crop),
                    onAddTask: (crop) =>
                        _showCropTaskSheet(context, location, crop),
                    onCompleteTask: (crop, taskUuid) => context
                        .read<LocationDetailCubit>()
                        .completeCropTask(crop.uuid, taskUuid),
                  ),
                  if (_hasRecords(location)) ...[
                    const SizedBox(height: 12),
                    LocationRecords(location: location),
                  ],
                  const SizedBox(height: 12),
                  ActivitiesSection(
                    location: location,
                    allLocations: state.allLocations,
                  ),
                  const SizedBox(height: 20),
                  AnimalsSection(
                    animalsHere: animalsHere,
                    location: location,
                    assigning: state.isAssigning,
                    onAssign: () => _showAssignAnimalsSheet(
                      context,
                      location,
                      state.allAnimals,
                      animalsHere,
                      state.allLocations,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ActionsRow(
                    onEdit: () => _openForm(context, location),
                    onDelete: () => _confirmDelete(context, location),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openForm(BuildContext context, LocationEntity initial) async {
    await context.pushNamed(
      AppRoutes.nameUbicacionEditar,
      pathParameters: {'uuid': initial.uuid},
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    LocationEntity location,
  ) async {
    final shouldDelete = await confirmDeleteLocation(context, location);
    if (!shouldDelete || !context.mounted) return;

    await context.read<LocationDetailCubit>().deleteLocation();
    if (!context.mounted) return;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _showAssignAnimalsSheet(
    BuildContext context,
    LocationEntity location,
    List<AnimalEntity> allAnimals,
    List<AnimalEntity> animalsHere,
    List<LocationEntity> allLocations,
  ) async {
    final cubit = context.read<LocationDetailCubit>();
    if (cubit.state.isAssigning) return;

    final selected = {for (final animal in animalsHere) animal.uuid};
    final result = await _openRecordFormPage<Set<String>>(
      context,
      AssignAnimalsPage(
        allAnimals: allAnimals,
        initiallySelected: selected,
        locationName: location.name,
        allLocations: allLocations,
      ),
    );

    if (!context.mounted || result == null) return;

    await cubit.assignAnimals(result);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Animales actualizados')),
    );
  }

  Future<T?> _openRecordFormPage<T>(
    BuildContext context,
    Widget child,
  ) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute<T>(
        fullscreenDialog: true,
        builder: (context) {
          return ShellChromeScope(visible: false, child: Scaffold(body: child));
        },
      ),
    );
  }

  Future<void> _showVisitSheet(
    BuildContext context,
    LocationEntity location,
  ) async {
    final record = await _openRecordFormPage<VisitRecord>(
      context,
      VisitRecordSheet(locationName: location.name),
    );
    if (record != null && context.mounted) {
      await context.read<LocationDetailCubit>().addVisit(record);
    }
  }

  Future<void> _showWaterSheet(
    BuildContext context,
    LocationEntity location,
  ) async {
    final record = await _openRecordFormPage<WaterRecord>(
      context,
      WaterRecordSheet(locationName: location.name),
    );
    if (record != null && context.mounted) {
      await context.read<LocationDetailCubit>().addWater(record);
    }
  }

  Future<void> _showSaltSheet(
    BuildContext context,
    LocationEntity location,
  ) async {
    final record = await _openRecordFormPage<SaltRecord>(
      context,
      SaltRecordSheet(locationName: location.name),
    );
    if (record != null && context.mounted) {
      await context.read<LocationDetailCubit>().addSalt(record);
    }
  }

  Future<void> _showShadeSheet(
    BuildContext context,
    LocationEntity location,
  ) async {
    final record = await _openRecordFormPage<ShadeRecord>(
      context,
      ShadeRecordSheet(locationName: location.name),
    );
    if (record != null && context.mounted) {
      await context.read<LocationDetailCubit>().addShade(record);
    }
  }

  Future<void> _showPastureSheet(
    BuildContext context,
    LocationEntity location,
  ) async {
    final record = await _openRecordFormPage<PastureRecord>(
      context,
      PastureRecordSheet(locationName: location.name),
    );
    if (record != null && context.mounted) {
      await context.read<LocationDetailCubit>().addPasture(record);
    }
  }

  Future<void> _showCostSheet(
    BuildContext context,
    LocationEntity location,
  ) async {
    final record = await _openRecordFormPage<LocationCostRecord>(
      context,
      CostRecordSheet(locationName: location.name),
    );
    if (record != null && context.mounted) {
      await context.read<LocationDetailCubit>().addCost(record);
    }
  }

  Future<void> _showCropFormSheet(
    BuildContext context,
    LocationEntity location, {
    CropRecord? initial,
  }) async {
    final crop = await _openRecordFormPage<CropRecord>(
      context,
      CropFormSheet(locationName: location.name, initial: initial),
    );
    if (crop == null || !context.mounted) return;

    final cubit = context.read<LocationDetailCubit>();
    if (initial != null) {
      await cubit.updateCrop(crop);
    } else {
      await cubit.addCrop(crop);
    }
  }

  Future<void> _confirmDeleteCrop(
    BuildContext context,
    LocationEntity location,
    CropRecord crop,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
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

    if (shouldDelete == true && context.mounted) {
      await context.read<LocationDetailCubit>().deleteCrop(crop.uuid);
    }
  }

  Future<void> _showCropWateringSheet(
    BuildContext context,
    LocationEntity location,
    CropRecord crop,
  ) async {
    final record = await _openRecordFormPage<CropWateringRecord>(
      context,
      CropWateringFormSheet(cropName: crop.cropName),
    );
    if (record != null && context.mounted) {
      await context
          .read<LocationDetailCubit>()
          .addCropWatering(crop.uuid, record);
    }
  }

  Future<void> _showHarvestSheet(
    BuildContext context,
    LocationEntity location,
    CropRecord crop,
  ) async {
    final record = await _openRecordFormPage<HarvestRecord>(
      context,
      HarvestFormSheet(cropName: crop.cropName),
    );
    if (record != null && context.mounted) {
      await context.read<LocationDetailCubit>().addHarvest(crop.uuid, record);
    }
  }

  Future<void> _showCropHealthSheet(
    BuildContext context,
    LocationEntity location,
    CropRecord crop,
  ) async {
    final record = await _openRecordFormPage<CropHealthRecord>(
      context,
      CropHealthFormSheet(cropName: crop.cropName),
    );
    if (record != null && context.mounted) {
      await context
          .read<LocationDetailCubit>()
          .addCropHealth(crop.uuid, record);
    }
  }

  Future<void> _showCropTaskSheet(
    BuildContext context,
    LocationEntity location,
    CropRecord crop,
  ) async {
    final task = await _openRecordFormPage<CropTask>(
      context,
      CropTaskFormSheet(cropName: crop.cropName),
    );
    if (task != null && context.mounted) {
      await context.read<LocationDetailCubit>().addCropTask(crop.uuid, task);
    }
  }

  bool _hasUpcomingTasks(LocationEntity location) {
    return location.crops.any(
      (crop) =>
          crop.status == CropStatus.active &&
          crop.tasks.any((task) => !task.completed),
    );
  }

  bool _hasRecords(LocationEntity location) =>
      location.visits.isNotEmpty ||
      location.waters.isNotEmpty ||
      location.salts.isNotEmpty ||
      location.shades.isNotEmpty ||
      location.pastures.isNotEmpty ||
      location.seedings.isNotEmpty ||
      location.irrigations.isNotEmpty ||
      location.rains.isNotEmpty ||
      location.costs.isNotEmpty ||
      location.crops.isNotEmpty;

  bool _isWarehouse(LocationEntity location) => location.type.supportsInventory;
}

class _LocationDetailImageGallery extends StatefulWidget {
  const _LocationDetailImageGallery({required this.imagePaths});

  final List<String> imagePaths;

  @override
  State<_LocationDetailImageGallery> createState() =>
      _LocationDetailImageGalleryState();
}

class _LocationDetailImageGalleryState
    extends State<_LocationDetailImageGallery> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 200,
            child: PageView.builder(
              itemCount: widget.imagePaths.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                final path = widget.imagePaths[index];
                return Image.file(
                  File(path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, err, __) => ColoredBox(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    child: Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 40,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.imagePaths.length > 1) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.imagePaths.length, (index) {
              final isActive = index == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
