import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/registro/lotes/batch_record_service.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/dynamic_attribute.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/inventory_item.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_records.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_task_type.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/water_type.dart';

import '../../support/web_batch_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late WebBatchFixture f;
  setUp(() async {
    f = WebBatchFixture();
    await f.open();
    await f.seed();
  });
  tearDown(() => f.dispose());

  test(
    'web destinations retain complete location history and inventory after edits and reopening',
    () async {
      final now = DateTime.now();
      final original = (await f.locations.getByUuid('south'))!.copyWith(
        geometry: '{"type":"Point","coordinates":[-110,29]}',
        isShared: true,
        isCommunal: true,
        imagePaths: ['photo-local'],
        attributes: [
          DynamicAttribute.number(
            key: 'altitude',
            label: 'Altitud',
            value: 120,
            unit: 'm',
          ),
        ],
        inventory: [
          InventoryItem(
            uuid: 'medicine',
            name: 'Vacuna',
            quantity: 10,
            unit: 'dosis',
            category: InventoryCategory.medicine,
            activeIngredient: 'Registrado',
            batchNumber: 'MED-1',
            withdrawalDays: 7,
            unitCost: 10.5,
            expiryDate: now.add(const Duration(days: 30)),
          ),
        ],
        visits: [
          VisitRecord(date: now, animals: 2, notes: 'Inspección', user: 'Ana'),
        ],
        waters: [
          WaterRecord(
            date: now,
            level: 80,
            type: WaterType.well,
            notes: 'Operativo',
          ),
        ],
        salts: [SaltRecord(date: now, quantityKg: 2)],
        shades: [ShadeRecord(date: now, shadePercent: 20, condition: 'Buena')],
        pastures: [
          PastureRecord(
            date: now,
            grassType: 'Buffel',
            condition: 'Bueno',
            carryingCapacity: 2,
          ),
        ],
        seedings: [
          SeedingRecord(date: now, crop: 'Maíz', surface: 1, cost: 200),
        ],
        irrigations: [
          IrrigationRecord(
            date: now,
            type: 'Goteo',
            duration: const Duration(minutes: 12),
            cost: 20,
          ),
        ],
        rains: [RainRecord(date: now, millimeters: 25, location: 'Sur')],
        costs: [
          LocationCostRecord(
            date: now,
            maintenance: 1,
            fences: 2,
            repairs: 3,
            labor: 4,
            total: 10,
          ),
        ],
        maintenances: [
          MaintenanceRecord(
            uuid: 'pump',
            date: now,
            assetName: 'Bomba',
            maintenanceType: 'Servicio',
            nextDueDate: now.add(const Duration(days: 30)),
            meterReading: 12,
            meterUnit: 'h',
            cost: 40,
          ),
        ],
        crops: [
          CropRecord(
            uuid: 'corn',
            cropName: 'Maíz',
            plantingDate: now,
            harvests: [HarvestRecord(uuid: 'harvest', date: now, yieldKg: 500)],
            waterings: [CropWateringRecord(date: now, amountLiters: 100)],
            healthRecords: [
              CropHealthRecord(
                date: now,
                issue: 'Revisión',
                notes: 'Sin incidencia',
              ),
            ],
            tasks: [
              CropTask(uuid: 'task', type: CropTaskType.water, dueDate: now),
            ],
          ),
        ],
      );
      await f.locations.upsert(original);
      final saved = (await f.locations.getByUuid('south'))!;
      await f.reopen();
      expect(await f.locations.getByUuid('south'), saved);
      await f.locations.upsert(saved.copyWith(name: 'Potrero sur'));
      final edited = (await f.locations.getByUuid('south'))!;
      expect(edited.crops, original.crops);
      expect(edited.inventory, original.inventory);
      expect(edited.maintenances, original.maintenances);
      await f.locations.completeCropTask('south', 'corn', 'task');
      expect(
        (await f.locations.getByUuid(
          'south',
        ))!.crops.single.tasks.single.completed,
        isTrue,
      );
    },
  );

  test(
    'a closed or archived web destination cannot partially apply a batch movement',
    () async {
      var session = await f.batch().start(
        lotUuid: f.lotUuid,
        kind: BatchRecordKind.movement,
      );
      session = await f.batch().saveDraft(
        session.copyWith(destinationId: 'south'),
        expectedVersion: 0,
      );
      await f.locations.deleteByUuid('south');
      expect(
        (await f.locations.getByUuid('south'))!.status,
        LocationStatus.closed,
      );
      expect(
        (await f.locations.getAll()).map((l) => l.uuid),
        isNot(contains('south')),
      );
      await expectLater(
        f.batch().complete(session.uuid, expectedVersion: session.version),
        throwsStateError,
      );
      expect(await f.movements.getMovementRecords('a'), isEmpty);
      expect((await f.animals.getByUuid('a'))!.currentLocationId, 'north');
      expect((await f.batch().open(session.uuid)).isCompleted, isFalse);
    },
  );
}
