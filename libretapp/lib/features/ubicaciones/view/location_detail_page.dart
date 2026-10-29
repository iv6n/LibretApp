/// features › ubicaciones › view › location_detail_page — detail page for a single location.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:libretapp/core/widgets/record_save_scope.dart';
import 'package:libretapp/core/widgets/app_empty_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/app/widgets/widgets.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/core/widgets/app_loading_indicator.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_repository.dart';
import 'package:libretapp/features/directorio/cultivos/view/linked_cultivations_section.dart';
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
import 'package:libretapp/features/agenda/data/agenda_reminder_sync_service.dart';

class LocationDetailPage extends StatelessWidget {
  LocationDetailPage({
    super.key,
    required this.locationUuid,
    LocationRepository? locationRepository,
    AnimalRepository? animalRepository,
    MovementRecordRepository? movementRepository,
    CultivationRepository? cultivationRepository,
    LocationDetailCubit? cubit,
  }) : _locationRepository =
           locationRepository ?? locator<LocationRepository>(),
       _animalRepository = animalRepository ?? locator<AnimalRepository>(),
       _movementRepository =
           movementRepository ?? locator<MovementRecordRepository>(),
       _cultivationRepository =
           cultivationRepository ??
           (locator.isRegistered<CultivationRepository>()
               ? locator<CultivationRepository>()
               : null),
       _cubit = cubit;

  final String locationUuid;
  final LocationRepository _locationRepository;
  final AnimalRepository _animalRepository;
  final MovementRecordRepository _movementRepository;
  final CultivationRepository? _cultivationRepository;
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
            onPlanningChanged: () async {
              await locator<AgendaReminderSyncService>().sync();
            },
          ),
      child: _LocationDetailView(cultivationRepository: _cultivationRepository),
    );
  }
}

class _LocationDetailView extends StatelessWidget {
  const _LocationDetailView({required this.cultivationRepository});

  final CultivationRepository? cultivationRepository;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = ShellInsets.bottomSafePadding(context);

    return ShellChromeScope(
      visible: false,
      child: Scaffold(
        appBar: AppBar(title: const Text('Ubicación')),
        body: BlocConsumer<LocationDetailCubit, LocationDetailState>(
          listenWhen: (previous, current) =>
              current.errorMessage != null &&
              current.errorMessage != previous.errorMessage &&
              current.location != null,
          listener: (context, state) => ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!))),
          builder: (context, state) {
            if (state.isLoading) {
              return const AppLoadingIndicator();
            }

            if (state.errorMessage != null && state.location == null) {
              return AppEmptyState(
                title: 'No se pudo cargar la ubicación',
                action: FilledButton(
                  onPressed: context.read<LocationDetailCubit>().retry,
                  child: const Text('Reintentar'),
                ),
              );
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
                    _LocationDetailImageGallery(
                      imagePaths: location.imagePaths,
                    ),
                    const SizedBox(height: 12),
                  ],
                  LocationHeader(location: location, animalsHere: animalsHere),
                  const SizedBox(height: 12),
                  if (location.type.isRootType) ...[
                    SublocationsSection(
                      location: location,
                      allLocations: state.allLocations,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (location.type.supportsAnimals) ...[
                    OccupancyCard(location: location, animalsHere: animalsHere),
                    const SizedBox(height: 12),
                  ],
                  AdaptivePropertiesSection(location: location),
                  const SizedBox(height: 12),
                  if (location.type.supportsInventory) ...[
                    InventorySection(location: location),
                    const SizedBox(height: 12),
                  ],
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
                    onWater:
                        location.type.category.name == 'water' ||
                            location.type.supportsAnimals
                        ? () => _showWaterSheet(context, location)
                        : null,
                    onSalt: location.type.supportsAnimals
                        ? () => _showSaltSheet(context, location)
                        : null,
                    onShade: location.type.supportsAnimals
                        ? () => _showShadeSheet(context, location)
                        : null,
                    onPasture: location.type.supportsAnimals
                        ? () => _showPastureSheet(context, location)
                        : null,
                    onSeeding: location.type.supportsCrops
                        ? () => _showSeedingSheet(context, location)
                        : null,
                    onIrrigation: location.type.supportsCrops
                        ? () => _showIrrigationSheet(context, location)
                        : null,
                    onRain:
                        location.type.supportsCrops ||
                            location.type.supportsAnimals
                        ? () => _showRainSheet(context, location)
                        : null,
                    onMaintenance:
                        location.type.category.name != 'macro' &&
                            location.type.category.name != 'handling'
                        ? () => _showMaintenanceSheet(context, location)
                        : null,
                    onCost: () => _showCostSheet(context, location),
                  ),
                  if (cultivationRepository == null &&
                      _hasUpcomingTasks(location)) ...[
                    const SizedBox(height: 12),
                    UpcomingTasksCard(
                      location: location,
                      onComplete: (cropUuid, taskUuid) => context
                          .read<LocationDetailCubit>()
                          .completeCropTask(cropUuid, taskUuid),
                    ),
                  ],
                  if (cultivationRepository != null) ...[
                    const SizedBox(height: 12),
                    LinkedCultivationsSection(
                      location: location,
                      repository: cultivationRepository!,
                    ),
                  ] else if (location.type.supportsCrops) ...[
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
                  ],
                  if (_hasRecords(location)) ...[
                    const SizedBox(height: 12),
                    LocationRecords(location: location),
                  ],
                  const SizedBox(height: 12),
                  ActivitiesSection(
                    location: location,
                    allLocations: state.allLocations,
                  ),
                  if (location.type.supportsAnimals) ...[
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
                  ],
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Animales actualizados')));
  }

  Future<T?> _openRecordFormPage<T>(
    BuildContext context,
    Widget child, {
    Future<void> Function(T)? onSave,
  }) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute<T>(
        fullscreenDialog: true,
        builder: (context) {
          return ShellChromeScope(
            visible: false,
            child: Scaffold(
              body: onSave == null
                  ? child
                  : RecordSaveScope(
                      onSave: (value) => onSave(value as T),
                      child: child,
                    ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showVisitSheet(
    BuildContext context,
    LocationEntity location,
  ) async {
    await _openRecordFormPage<VisitRecord>(
      context,
      VisitRecordSheet(locationName: location.name),
      onSave: (value) => context.read<LocationDetailCubit>().addVisit(value),
    );
  }

  Future<void> _showWaterSheet(
    BuildContext context,
    LocationEntity location,
  ) async {
    await _openRecordFormPage<WaterRecord>(
      context,
      WaterRecordSheet(locationName: location.name),
      onSave: (value) => context.read<LocationDetailCubit>().addWater(value),
    );
  }

  Future<void> _showSaltSheet(
    BuildContext context,
    LocationEntity location,
  ) async {
    await _openRecordFormPage<SaltRecord>(
      context,
      SaltRecordSheet(locationName: location.name),
      onSave: (value) => context.read<LocationDetailCubit>().addSalt(value),
    );
  }

  Future<void> _showShadeSheet(
    BuildContext context,
    LocationEntity location,
  ) async {
    await _openRecordFormPage<ShadeRecord>(
      context,
      ShadeRecordSheet(locationName: location.name),
      onSave: (value) => context.read<LocationDetailCubit>().addShade(value),
    );
  }

  Future<void> _showPastureSheet(
    BuildContext context,
    LocationEntity location,
  ) async {
    await _openRecordFormPage<PastureRecord>(
      context,
      PastureRecordSheet(locationName: location.name),
      onSave: (value) => context.read<LocationDetailCubit>().addPasture(value),
    );
  }

  Future<void> _showSeedingSheet(
    BuildContext context,
    LocationEntity location,
  ) async {
    await _openRecordFormPage<SeedingRecord>(
      context,
      SeedingRecordSheet(locationName: location.name),
      onSave: (value) => context.read<LocationDetailCubit>().addSeeding(value),
    );
  }

  Future<void> _showIrrigationSheet(
    BuildContext context,
    LocationEntity location,
  ) async {
    await _openRecordFormPage<IrrigationRecord>(
      context,
      IrrigationRecordSheet(locationName: location.name),
      onSave: (value) =>
          context.read<LocationDetailCubit>().addIrrigation(value),
    );
  }

  Future<void> _showRainSheet(
    BuildContext context,
    LocationEntity location,
  ) async {
    await _openRecordFormPage<RainRecord>(
      context,
      RainRecordSheet(locationName: location.name),
      onSave: (value) => context.read<LocationDetailCubit>().addRain(value),
    );
  }

  Future<void> _showMaintenanceSheet(
    BuildContext context,
    LocationEntity location,
  ) async {
    await _openRecordFormPage<MaintenanceRecord>(
      context,
      MaintenanceRecordSheet(locationName: location.name),
      onSave: (value) =>
          context.read<LocationDetailCubit>().addMaintenance(value),
    );
  }

  Future<void> _showCostSheet(
    BuildContext context,
    LocationEntity location,
  ) async {
    await _openRecordFormPage<LocationCostRecord>(
      context,
      CostRecordSheet(locationName: location.name),
      onSave: (value) => context.read<LocationDetailCubit>().addCost(value),
    );
  }

  Future<void> _showCropFormSheet(
    BuildContext context,
    LocationEntity location, {
    CropRecord? initial,
  }) async {
    await _openRecordFormPage<CropRecord>(
      context,
      CropFormSheet(locationName: location.name, initial: initial),
      onSave: (crop) => initial == null
          ? context.read<LocationDetailCubit>().addCrop(crop)
          : context.read<LocationDetailCubit>().updateCrop(crop),
    );
  }

  Future<void> _confirmDeleteCrop(
    BuildContext context,
    LocationEntity location,
    CropRecord crop,
  ) async {
    final shouldArchive = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        title: const Text('Archivar ciclo de cultivo'),
        content: Text(
          '¿Deseas archivar "${crop.cropName}"? Se conservarán sus registros y dejará de generar pendientes.',
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

    if (shouldArchive == true && context.mounted) {
      await context.read<LocationDetailCubit>().deleteCrop(crop.uuid);
    }
  }

  Future<void> _showCropWateringSheet(
    BuildContext context,
    LocationEntity location,
    CropRecord crop,
  ) async {
    await _openRecordFormPage<CropWateringRecord>(
      context,
      CropWateringFormSheet(cropName: crop.cropName),
      onSave: (value) =>
          context.read<LocationDetailCubit>().addCropWatering(crop.uuid, value),
    );
  }

  Future<void> _showHarvestSheet(
    BuildContext context,
    LocationEntity location,
    CropRecord crop,
  ) async {
    await _openRecordFormPage<HarvestRecord>(
      context,
      HarvestFormSheet(cropName: crop.cropName),
      onSave: (value) =>
          context.read<LocationDetailCubit>().addHarvest(crop.uuid, value),
    );
  }

  Future<void> _showCropHealthSheet(
    BuildContext context,
    LocationEntity location,
    CropRecord crop,
  ) async {
    await _openRecordFormPage<CropHealthRecord>(
      context,
      CropHealthFormSheet(cropName: crop.cropName),
      onSave: (value) =>
          context.read<LocationDetailCubit>().addCropHealth(crop.uuid, value),
    );
  }

  Future<void> _showCropTaskSheet(
    BuildContext context,
    LocationEntity location,
    CropRecord crop,
  ) async {
    await _openRecordFormPage<CropTask>(
      context,
      CropTaskFormSheet(cropName: crop.cropName),
      onSave: (value) =>
          context.read<LocationDetailCubit>().addCropTask(crop.uuid, value),
    );
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
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
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
