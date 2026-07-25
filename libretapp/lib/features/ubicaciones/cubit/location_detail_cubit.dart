/// Cubit for a single location detail screen.
library;

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/ubicaciones/cubit/location_detail_state.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/inventory_item.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_records.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/services/location_animal_assignment_service.dart';

class LocationDetailCubit extends Cubit<LocationDetailState> {
  LocationDetailCubit({
    required String locationUuid,
    required LocationRepository locationRepository,
    required AnimalRepository animalRepository,
    required MovementRecordRepository movementRepository,
  }) : _locationUuid = locationUuid,
       _locationRepository = locationRepository,
       _assignmentService = LocationAnimalAssignmentService(
         animalRepository: animalRepository,
         movementRepository: movementRepository,
       ),
       super(const LocationDetailState()) {
    _locationSub = _locationRepository.watchAll().listen(
      _onLocationsUpdated,
      onError: (Object error) {
        if (!isClosed) {
          emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
        }
      },
    );
    _animalSub = animalRepository.watchAll().listen(
      (animals) {
        if (!isClosed) {
          emit(state.copyWith(allAnimals: animals));
        }
      },
      onError: (_) {},
    );
  }

  final String _locationUuid;
  final LocationRepository _locationRepository;
  final LocationAnimalAssignmentService _assignmentService;
  StreamSubscription<List<LocationEntity>>? _locationSub;
  StreamSubscription<List<AnimalEntity>>? _animalSub;

  void _onLocationsUpdated(List<LocationEntity> locations) {
    if (isClosed) return;
    final match = locations
        .where((location) => location.uuid == _locationUuid)
        .firstOrNull;
    emit(
      state.copyWith(
        location: match,
        allLocations: locations,
        isLoading: false,
        errorMessage: null,
      ),
    );
  }

  Future<void> deleteLocation() async {
    final location = state.location;
    if (location == null) return;
    await _locationRepository.deleteByUuid(location.uuid);
  }

  Future<void> assignAnimals(Set<String> selectedUuids) async {
    final location = state.location;
    if (location == null || state.isAssigning) return;

    emit(state.copyWith(isAssigning: true));
    try {
      await _assignmentService.assign(
        location: location,
        animals: state.allAnimals,
        selectedUuids: selectedUuids,
      );
    } finally {
      if (!isClosed) {
        emit(state.copyWith(isAssigning: false));
      }
    }
  }

  Future<void> addVisit(VisitRecord record) =>
      _mutate(() => _locationRepository.addVisit(_locationUuid, record));

  Future<void> addWater(WaterRecord record) =>
      _mutate(() => _locationRepository.addWater(_locationUuid, record));

  Future<void> addSalt(SaltRecord record) =>
      _mutate(() => _locationRepository.addSalt(_locationUuid, record));

  Future<void> addShade(ShadeRecord record) =>
      _mutate(() => _locationRepository.addShade(_locationUuid, record));

  Future<void> addPasture(PastureRecord record) =>
      _mutate(() => _locationRepository.addPasture(_locationUuid, record));

  Future<void> addCost(CostRecord record) =>
      _mutate(() => _locationRepository.addCost(_locationUuid, record));

  Future<void> addCrop(CropRecord crop) =>
      _mutate(() => _locationRepository.addCrop(_locationUuid, crop));

  Future<void> updateCrop(CropRecord crop) =>
      _mutate(() => _locationRepository.updateCrop(_locationUuid, crop));

  Future<void> deleteCrop(String cropUuid) => _mutate(
    () => _locationRepository.deleteCrop(_locationUuid, cropUuid),
  );

  Future<void> addCropWatering(String cropUuid, CropWateringRecord record) =>
      _mutate(
        () => _locationRepository.addCropWatering(
          _locationUuid,
          cropUuid,
          record,
        ),
      );

  Future<void> addHarvest(String cropUuid, HarvestRecord record) => _mutate(
    () => _locationRepository.addHarvest(_locationUuid, cropUuid, record),
  );

  Future<void> addCropHealth(String cropUuid, CropHealthRecord record) =>
      _mutate(
        () => _locationRepository.addCropHealth(_locationUuid, cropUuid, record),
      );

  Future<void> addCropTask(String cropUuid, CropTask task) => _mutate(
    () => _locationRepository.addCropTask(_locationUuid, cropUuid, task),
  );

  Future<void> completeCropTask(String cropUuid, String taskUuid) => _mutate(
    () => _locationRepository.completeCropTask(
      _locationUuid,
      cropUuid,
      taskUuid,
    ),
  );

  Future<void> addInventoryItem(InventoryItem item) => _mutate(
    () => _locationRepository.addInventoryItem(_locationUuid, item),
  );

  Future<void> updateInventoryItem(InventoryItem item) => _mutate(
    () => _locationRepository.updateInventoryItem(_locationUuid, item),
  );

  Future<void> removeInventoryItem(String itemUuid) => _mutate(
    () => _locationRepository.removeInventoryItem(_locationUuid, itemUuid),
  );

  Future<void> _mutate(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: error.toString()));
      }
    }
  }

  @override
  Future<void> close() async {
    await _locationSub?.cancel();
    await _animalSub?.cancel();
    return super.close();
  }
}
