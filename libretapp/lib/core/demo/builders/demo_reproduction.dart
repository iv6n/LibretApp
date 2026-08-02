/// core › demo › builders › demo_reproduction — reproduction cycle stories
/// for the demo herd.
///
/// Dates use an ~283-day bovine gestation throughout, so every
/// `expectedCalvingDate` is internally consistent with its `serviceDate` —
/// the same arithmetic `ReproductionScheduler` uses to judge whether a
/// calving reminder is upcoming or overdue.
library;

import 'package:libretapp/core/demo/builders/demo_animals.dart';
import 'package:libretapp/core/demo/demo_dates.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';

const int bovineGestationDays = 283;

class DemoReproductionEntry {
  const DemoReproductionEntry({required this.animalSlug, required this.record});
  final String animalSlug;
  final ReproductionRecord record;
}

List<DemoReproductionEntry> buildDemoReproductionRecords({
  required DateTime reference,
}) {
  // Gestante con parto esperado dentro de 7–14 días.
  final prietaCalving = daysAfter(reference, 10);
  final prietaService = daysBefore(prietaCalving, bovineGestationDays);

  // Gestante con parto esperado dentro de 30–60 días.
  final weraCalving = daysAfter(reference, 45);
  final weraService = daysBefore(weraCalving, bovineGestationDays);

  // Parto histórico exitoso: coincide con el nacimiento de "becerra-2".
  final cuernitosCalving = monthsBefore(reference, 4);
  final cuernitosService = daysBefore(cuernitosCalving, bovineGestationDays);

  return [
    DemoReproductionEntry(
      animalSlug: aniPrietaSlug,
      record: ReproductionRecord(
        id: 'demo-repro-prieta-1',
        serviceDate: prietaService,
        serviceType: ServiceType.naturalService,
        maleSireUuid: demoAnimalUuid(aniSasoSlug),
        pregnancyCheckDate: daysAfter(prietaService, 60),
        pregnancyResult: PregnancyCheckResult.positive,
        expectedCalvingDate: prietaCalving,
        servicedBy: 'Rodrigo Valenzuela (DEMO)',
        notes: 'Gestación en curso. Registro de demostración.',
      ),
    ),
    DemoReproductionEntry(
      animalSlug: aniWeraSlug,
      record: ReproductionRecord(
        id: 'demo-repro-wera-1',
        serviceDate: weraService,
        serviceType: ServiceType.artificialInsemination,
        maleSireIdentifier: externalSireIdentifier,
        pregnancyCheckDate: daysAfter(weraService, 60),
        pregnancyResult: PregnancyCheckResult.positive,
        expectedCalvingDate: weraCalving,
        servicedBy: 'Rodrigo Valenzuela (DEMO)',
        notes:
            'Inseminación artificial con semental externo. '
            'Registro de demostración.',
      ),
    ),
    DemoReproductionEntry(
      animalSlug: aniAlazanaSlug,
      record: ReproductionRecord(
        id: 'demo-repro-alazana-1',
        serviceDate: daysBefore(reference, 90),
        serviceType: ServiceType.naturalService,
        maleSireUuid: demoAnimalUuid(aniSasoSlug),
        pregnancyCheckDate: daysBefore(reference, 30),
        pregnancyResult: PregnancyCheckResult.negative,
        servicedBy: 'Rodrigo Valenzuela (DEMO)',
        notes:
            'Diagnóstico negativo, vacía para el próximo servicio. '
            'Registro de demostración.',
      ),
    ),
    DemoReproductionEntry(
      animalSlug: aniNancySlug,
      record: ReproductionRecord(
        id: 'demo-repro-nancy-1',
        serviceDate: daysBefore(reference, 20),
        serviceType: ServiceType.naturalService,
        maleSireUuid: demoAnimalUuid(aniSasoSlug),
        servicedBy: 'Rodrigo Valenzuela (DEMO)',
        notes:
            'Servicio reciente, pendiente de diagnóstico. '
            'Registro de demostración.',
      ),
    ),
    DemoReproductionEntry(
      animalSlug: aniCuernitosSlug,
      record: ReproductionRecord(
        id: 'demo-repro-cuernitos-1',
        serviceDate: cuernitosService,
        serviceType: ServiceType.naturalService,
        maleSireUuid: demoAnimalUuid(aniSasoSlug),
        pregnancyCheckDate: daysAfter(cuernitosService, 60),
        pregnancyResult: PregnancyCheckResult.positive,
        expectedCalvingDate: cuernitosCalving,
        actualCalvingDate: cuernitosCalving,
        calvingOutcome: CalvingOutcome.liveBirth,
        calvingEase: 1,
        offspringUuids: [demoAnimalUuid(aniBecerra2Slug)],
        calvingNotes: 'Parto sin asistencia. Cría activa en el hato.',
        servicedBy: 'Rodrigo Valenzuela (DEMO)',
        notes: 'Registro de demostración.',
      ),
    ),
  ];
}
