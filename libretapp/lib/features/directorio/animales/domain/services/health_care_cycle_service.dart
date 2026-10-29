/// Keeps the care-calendar projection linked to health records.
library;

import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/care_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/care_rule.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/care_repository.dart';

class HealthCareCycleService {
  const HealthCareCycleService(this._repository);

  final CareRepository _repository;

  static String? recordId(String animalUuid, HealthRecord record) {
    if (_careType(record.type) == null) return null;
    return 'health-care:$animalUuid:${record.type.name}:'
        '${record.date.millisecondsSinceEpoch}';
  }

  Future<void> replace({
    required AnimalEntity animal,
    HealthRecord? previous,
    required HealthRecord current,
  }) async {
    final previousId = previous == null
        ? null
        : recordId(animal.uuid, previous);
    final currentId = recordId(animal.uuid, current);
    if (previousId != null && previousId != currentId) {
      await _repository.deleteRecord(previousId);
    }
    await upsert(animal: animal, record: current);
  }

  Future<void> remove(String animalUuid, HealthRecord record) async {
    final id = recordId(animalUuid, record);
    if (id != null) await _repository.deleteRecord(id);
  }

  Future<void> upsert({
    required AnimalEntity animal,
    required HealthRecord record,
  }) async {
    final careType = _careType(record.type);
    final id = recordId(animal.uuid, record);
    if (careType == null || id == null) return;

    CareRule? rule;
    for (final candidate in await _repository.getRules()) {
      if (candidate.type != careType) continue;
      if ((animal.species == Species.canine || animal.species == Species.feline) &&
          candidate.species == null) continue;
      if (candidate.species != null && candidate.species != animal.species) {
        continue;
      }
      if (candidate.sex != null && candidate.sex != animal.sex) continue;
      if (!animal.hasKnownAge &&
          (candidate.minAgeMonths != null || candidate.maxAgeMonths != null)) continue;
      if (candidate.minAgeMonths != null &&
          animal.ageMonths < candidate.minAgeMonths!) {
        continue;
      }
      if (candidate.maxAgeMonths != null &&
          animal.ageMonths > candidate.maxAgeMonths!) {
        continue;
      }
      rule = candidate;
      break;
    }
    if (rule == null) return;
    await _repository.saveRecord(
      CareRecord(
        id: id,
        animalId: animal.uuid,
        ruleId: rule.id,
        type: rule.type,
        performedAt: record.date,
        notes: record.notes,
        performedBy: record.appliedBy,
      ),
    );
  }

  static CareType? _careType(HealthRecordType type) => switch (type) {
    HealthRecordType.vaccine => CareType.vaccination,
    HealthRecordType.deworming => CareType.deworming,
    HealthRecordType.tickBath => CareType.tickBath,
    HealthRecordType.vitamins => CareType.supplement,
    _ => null,
  };
}
