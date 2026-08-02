/// core › demo › builders › demo_production — body-condition production
/// records for a few representative demo animals.
///
/// `ProductionRecordRepository` copies a `bodyConditionScore` record onto
/// the animal unconditionally, so the score here always matches the score
/// already authored on the corresponding [AnimalEntity] in
/// `demo_animals.dart` — this is the record trail behind that number, not a
/// contradicting one.
library;

import 'package:libretapp/core/demo/builders/demo_animals.dart';
import 'package:libretapp/core/demo/demo_dates.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/production_record.dart';

class DemoProductionEntry {
  const DemoProductionEntry({required this.animalSlug, required this.record});
  final String animalSlug;
  final ProductionRecord record;
}

List<DemoProductionEntry> buildDemoProductionRecords({
  required DateTime reference,
}) {
  ProductionRecord bcs(int daysAgo, int score) => ProductionRecord(
    date: daysBefore(reference, daysAgo),
    type: ProductionRecordType.bodyConditionScore,
    score: score,
    notes: 'Registro de demostración.',
  );

  return [
    DemoProductionEntry(animalSlug: aniPrietaSlug, record: bcs(45, 4)),
    DemoProductionEntry(animalSlug: aniWeraSlug, record: bcs(45, 3)),
    DemoProductionEntry(animalSlug: aniNancySlug, record: bcs(30, 3)),
    DemoProductionEntry(
      animalSlug: aniNovillo1Slug,
      record: ProductionRecord(
        date: daysBefore(reference, 8),
        type: ProductionRecordType.weightGain,
        value: 2.4,
        unit: 'kg/día',
        notes:
            'Ganancia diaria estimada en corral de engorda. '
            'Registro de demostración.',
      ),
    ),
  ];
}
