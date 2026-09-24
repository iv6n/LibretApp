/// Cultivation examples for the demo scenario at all supported scales.
library;

import 'package:libretapp/core/demo/builders/demo_locations.dart';
import 'package:libretapp/core/demo/demo_identity.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_growth_stage.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_task_type.dart';

List<CultivationEntity> buildDemoCultivations({required DateTime reference}) {
  return [
    CultivationEntity(
      uuid: demoId('cultivation', 'rosa-individual'),
      name: 'Rosa del desierto',
      variety: 'Adenium obesum',
      scale: CultivationScale.individual,
      plantingDate: reference.subtract(const Duration(days: 95)),
      growthStage: CropGrowthStage.flowering,
      wateringFrequencyDays: 5,
      lastWateredDate: reference.subtract(const Duration(days: 2)),
      notes: 'Ejemplo de una planta individual sin ubicación.',
      healthRecords: [
        CropHealthRecord(
          date: reference.subtract(const Duration(days: 20)),
          issue: 'Hojas amarillas',
          treatment: 'Ajuste de riego',
          severity: 'baja',
        ),
      ],
    ),
    CultivationEntity(
      uuid: demoId('cultivation', 'huerto-patio'),
      name: 'Huerto casero',
      variety: 'Tomate, chile y hierbas',
      scale: CultivationScale.group,
      locationUuid: demoId('location', locPatioSlug),
      plantingDate: reference.subtract(const Duration(days: 35)),
      expectedHarvestDate: reference.add(const Duration(days: 40)),
      growthStage: CropGrowthStage.flowering,
      wateringFrequencyDays: 2,
      lastWateredDate: reference.subtract(const Duration(days: 1)),
      quantity: 18,
      notes: 'Ejemplo de huerto vinculado a Patio.',
      tasks: [
        CropTask(
          uuid: demoId('cultivation-task', 'huerto-fertilizar'),
          type: CropTaskType.fertilize,
          dueDate: reference.add(const Duration(days: 4)),
        ),
      ],
    ),
    CultivationEntity(
      uuid: demoId('cultivation', 'maiz-blanco'),
      name: 'Maíz blanco',
      variety: 'Criollo sonorense',
      scale: CultivationScale.area,
      locationUuid: demoId('location', locMilpaSlug),
      plantingDate: reference.subtract(const Duration(days: 60)),
      expectedHarvestDate: reference.add(const Duration(days: 45)),
      growthStage: CropGrowthStage.vegetative,
      wateringFrequencyDays: 7,
      lastWateredDate: reference.subtract(const Duration(days: 7)),
      areaSquareMeters: 42000,
      preferredAreaUnit: CultivationAreaUnit.hectares,
      notes: 'Ejemplo de siembra de 4.2 ha en Milpa.',
      tasks: [
        CropTask(
          uuid: demoId('cultivation-task', 'maiz-riego'),
          type: CropTaskType.water,
          dueDate: reference.add(const Duration(days: 2)),
        ),
        CropTask(
          uuid: demoId('cultivation-task', 'maiz-fertilizar'),
          type: CropTaskType.fertilize,
          dueDate: reference.add(const Duration(days: 5)),
        ),
      ],
    ),
    CultivationEntity(
      uuid: demoId('cultivation', 'sorgo-historico'),
      name: 'Sorgo forrajero',
      variety: 'Sorgo criollo',
      scale: CultivationScale.area,
      locationUuid: demoId('location', locMilpaSlug),
      plantingDate: reference.subtract(const Duration(days: 240)),
      expectedHarvestDate: reference.subtract(const Duration(days: 150)),
      growthStage: CropGrowthStage.harvested,
      status: CropStatus.harvested,
      areaSquareMeters: 50000,
      preferredAreaUnit: CultivationAreaUnit.hectares,
      notes: 'Ciclo anterior, ya cosechado.',
      harvests: [
        HarvestRecord(
          uuid: demoId('harvest', 'sorgo-historico'),
          date: reference.subtract(const Duration(days: 150)),
          yieldKg: 3200,
          qualityRating: 4,
        ),
      ],
    ),
  ];
}
