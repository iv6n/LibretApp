/// Assigns animals to a location and records movement history.
library;

import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:uuid/uuid.dart';

class LocationAnimalAssignmentService {
  const LocationAnimalAssignmentService({
    required AnimalRepository animalRepository,
    required MovementRecordRepository movementRepository,
  }) : _movementRepository = movementRepository;

  final MovementRecordRepository _movementRepository;

  Future<void> assign({
    required LocationEntity location,
    required List<AnimalEntity> animals,
    required Set<String> selectedUuids,
  }) async {
    final now = DateTime.now();
    final entries = <MovementBatchEntry>[];

    for (final animal in animals) {
      final oldLocId = animal.currentLocationId;
      final shouldBeHere = selectedUuids.contains(animal.uuid);
      final alreadyHere = oldLocId == location.uuid;
      if (shouldBeHere == alreadyHere) continue;

      final newLocId = shouldBeHere ? location.uuid : null;
      if (newLocId != null || oldLocId != null) {
        final record = MovementRecord(
          fromLocation: oldLocId,
          toLocation: newLocId ?? '',
          clearsLocation: newLocId == null,
          recordUuid: const Uuid().v4(),
          date: now,
          reason: MovementReason.paddockRotation,
        );
        entries.add(MovementBatchEntry(animal.uuid, record));
      }
    }

    if (entries.isEmpty) return;
    final repository = _movementRepository;
    if (repository is! AtomicMovementRepository) {
      throw StateError('Este almacenamiento no admite asignaciones atómicas.');
    }
    await (repository as AtomicMovementRepository).addMovementRecordsAtomically(entries);
  }
}
