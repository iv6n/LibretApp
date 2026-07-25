/// Assigns animals to a location and records movement history.
library;

import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';

class LocationAnimalAssignmentService {
  const LocationAnimalAssignmentService({
    required AnimalRepository animalRepository,
    required MovementRecordRepository movementRepository,
  }) : _animalRepository = animalRepository,
       _movementRepository = movementRepository;

  final AnimalRepository _animalRepository;
  final MovementRecordRepository _movementRepository;

  Future<void> assign({
    required LocationEntity location,
    required List<AnimalEntity> animals,
    required Set<String> selectedUuids,
  }) async {
    final now = DateTime.now();
    final updateTasks = <Future<void>>[];
    final movementTasks = <Future<void>>[];

    for (final animal in animals) {
      final oldLocId = animal.currentLocationId ?? animal.initialLocationId;
      final shouldBeHere = selectedUuids.contains(animal.uuid);
      final alreadyHere = oldLocId == location.uuid;
      if (shouldBeHere == alreadyHere) continue;

      final newLocId = shouldBeHere ? location.uuid : null;
      final updated = animal.copyWith(
        currentLocationId: newLocId,
        initialLocationId: animal.initialLocationId ?? newLocId,
        lastMovementDate: shouldBeHere ? now : animal.lastMovementDate,
        lastUpdateDate: now,
        synced: false,
      );
      updateTasks.add(_animalRepository.update(updated));

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
}
