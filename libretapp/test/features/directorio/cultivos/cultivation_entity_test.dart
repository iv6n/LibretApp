import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_growth_stage.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_task_type.dart';

void main() {
  test('represents individual, group and normalized area scales', () {
    final date = DateTime(2026, 9, 3);
    final individual = CultivationEntity(name: 'Rosa', plantingDate: date);
    final group = CultivationEntity(
      name: 'Huerto',
      plantingDate: date,
      scale: CultivationScale.group,
      quantity: 12,
    );
    final area = CultivationEntity(
      name: 'Maíz blanco',
      plantingDate: date,
      scale: CultivationScale.area,
      areaSquareMeters: 42000,
      preferredAreaUnit: CultivationAreaUnit.hectares,
    );

    expect(individual.measureLabel, '1 planta');
    expect(group.measureLabel, '12 plantas');
    expect(area.measureLabel, '4.2 ha');
  });

  test(
    'legacy conversion preserves identity, history and preferred hectares',
    () {
      final planting = DateTime(2026, 1, 10);
      final crop = CropRecord(
        uuid: 'crop-1',
        cropName: 'Maíz',
        variety: 'Blanco',
        plantingDate: planting,
        expectedHarvestDate: DateTime(2026, 6, 10),
        growthStage: CropGrowthStage.flowering,
        lastWateredDate: DateTime(2026, 3, 1),
        status: CropStatus.active,
        surface: 4.2,
        harvests: [
          HarvestRecord(
            uuid: 'harvest-1',
            date: DateTime(2026, 5, 1),
            yieldKg: 150,
          ),
        ],
        waterings: [
          CropWateringRecord(date: DateTime(2026, 3, 1), amountLiters: 80),
        ],
        healthRecords: [
          CropHealthRecord(date: DateTime(2026, 2, 20), issue: 'Pulgón'),
        ],
        tasks: [
          CropTask(
            uuid: 'task-1',
            type: CropTaskType.fertilize,
            dueDate: DateTime(2026, 3, 15),
          ),
        ],
      );

      final cultivation = CultivationEntity.fromLegacyCrop(
        crop: crop,
        locationUuid: 'location-1',
      );

      expect(cultivation.uuid, crop.uuid);
      expect(cultivation.locationUuid, 'location-1');
      expect(cultivation.areaSquareMeters, 42000);
      expect(cultivation.preferredAreaUnit, CultivationAreaUnit.hectares);
      expect(cultivation.harvests.single.uuid, 'harvest-1');
      expect(cultivation.waterings, hasLength(1));
      expect(cultivation.healthRecords, hasLength(1));
      expect(cultivation.tasks.single.uuid, 'task-1');
    },
  );
}
