import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/care_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/care_rule.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/care_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/services/health_care_cycle_service.dart';

import 'advisor/rules/rule_test_fixtures.dart';

class _CareRepository implements CareRepository {
  final records = <String, CareRecord>{};
  final rules = <CareRule>[
    const CareRule(
      id: 'vaccination-rule',
      name: 'Vacunación',
      type: CareType.vaccination,
      intervalDays: 180,
    ),
    const CareRule(
      id: 'deworming-rule',
      name: 'Desparasitación',
      type: CareType.deworming,
      intervalDays: 90,
    ),
  ];

  @override
  Future<List<CareRule>> getRules() async => rules;

  @override
  Future<void> saveRecord(CareRecord record) async {
    records[record.id] = record;
  }

  @override
  Future<void> deleteRecord(String recordId) async {
    records.remove(recordId);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'replaces the deterministic care row when type or date changes',
    () async {
      final repository = _CareRepository();
      final service = HealthCareCycleService(repository);
      final animal = buildAnimal(uuid: 'animal-1');
      final original = HealthRecord(
        date: DateTime(2026, 1, 2),
        type: HealthRecordType.vaccine,
        product: 'Vacuna A',
      );
      final corrected = HealthRecord(
        date: DateTime(2026, 2, 3),
        type: HealthRecordType.deworming,
        product: 'Producto B',
      );

      await service.upsert(animal: animal, record: original);
      final oldId = HealthCareCycleService.recordId(animal.uuid, original)!;
      expect(repository.records, contains(oldId));

      await service.replace(
        animal: animal,
        previous: original,
        current: corrected,
      );

      final newId = HealthCareCycleService.recordId(animal.uuid, corrected)!;
      expect(repository.records, isNot(contains(oldId)));
      expect(repository.records[newId]?.ruleId, 'deworming-rule');
    },
  );

  test('ignores health types that do not drive a care cycle', () async {
    final repository = _CareRepository();
    final service = HealthCareCycleService(repository);
    final animal = buildAnimal(uuid: 'animal-2');
    final record = HealthRecord(
      date: DateTime(2026, 1, 2),
      type: HealthRecordType.checkup,
      product: 'Revisión',
    );

    await service.upsert(animal: animal, record: record);

    expect(repository.records, isEmpty);
  });
}
