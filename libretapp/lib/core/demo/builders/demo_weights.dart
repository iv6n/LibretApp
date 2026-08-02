/// core › demo › builders › demo_weights — longitudinal weighings for a
/// handful of representative demo animals.
///
/// Records are returned oldest-first per animal: `WeightRecordRepository`
/// stamps `AnimalEntity.weight` from whichever record was added last (no
/// date comparison), so insertion order has to be chronological for the
/// animal's summary weight to end up matching its own last weighing.
library;

import 'package:libretapp/core/demo/builders/demo_animals.dart';
import 'package:libretapp/core/demo/demo_dates.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/weight_record.dart';

/// One animal's weighings, oldest first.
class DemoWeightSeries {
  const DemoWeightSeries({required this.animalSlug, required this.records});
  final String animalSlug;
  final List<WeightRecord> records;
}

List<DemoWeightSeries> buildDemoWeights({required DateTime reference}) {
  WeightRecord w(
    int daysAgo,
    double weight, {
    WeightMethod method = WeightMethod.scale,
    String? measuredBy,
  }) => WeightRecord(
    date: daysBefore(reference, daysAgo),
    weight: weight,
    method: method,
    measuredBy: measuredBy,
    notes: 'Registro de demostración.',
  );

  return [
    DemoWeightSeries(
      animalSlug: aniPrietaSlug,
      records: [
        w(120, 418, measuredBy: 'Rodrigo Valenzuela (DEMO)'),
        w(90, 424, measuredBy: 'Rodrigo Valenzuela (DEMO)'),
        w(60, 431, measuredBy: 'Rodrigo Valenzuela (DEMO)'),
        w(
          30,
          437,
          method: WeightMethod.estimated,
          measuredBy: 'Capataz (DEMO)',
        ),
        w(5, 441, measuredBy: 'Rodrigo Valenzuela (DEMO)'),
      ],
    ),
    DemoWeightSeries(
      animalSlug: aniBecerraNancySlug,
      records: [
        w(170, 42, measuredBy: 'Rodrigo Valenzuela (DEMO)'),
        w(90, 98, measuredBy: 'Rodrigo Valenzuela (DEMO)'),
        w(10, 162, measuredBy: 'Rodrigo Valenzuela (DEMO)'),
      ],
    ),
    DemoWeightSeries(
      animalSlug: aniNovillo1Slug,
      records: [
        w(100, 322, measuredBy: 'Capataz (DEMO)'),
        w(70, 351, measuredBy: 'Capataz (DEMO)'),
        w(40, 379, measuredBy: 'Capataz (DEMO)'),
        w(8, 405, measuredBy: 'Capataz (DEMO)'),
      ],
    ),
    DemoWeightSeries(
      animalSlug: aniCabra1Slug,
      records: [
        w(80, 44, method: WeightMethod.estimated),
        w(40, 47, method: WeightMethod.estimated),
        w(6, 49, method: WeightMethod.estimated),
      ],
    ),
    DemoWeightSeries(
      animalSlug: aniCerda1Slug,
      records: [
        w(60, 128, measuredBy: 'Capataz (DEMO)'),
        w(30, 139, measuredBy: 'Capataz (DEMO)'),
        w(4, 148, measuredBy: 'Capataz (DEMO)'),
      ],
    ),
  ];
}
