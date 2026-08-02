/// core › demo › builders › demo_health — health log and care-calendar
/// history for the demo herd.
///
/// Two parallel systems both get exercised on purpose: [HealthRecord] (the
/// per-animal clinical log — vaccinated/dewormed/vitamins flags, withdrawal
/// tracking) and [CareRecord] (the rule-driven calendar behind the
/// "Cuidados" tab and the `auto:care:` agenda reminders). Every product name
/// is explicitly `"... DEMO"` — this scenario never invents a real dose or
/// veterinary recommendation.
library;

import 'package:libretapp/core/demo/builders/demo_animals.dart';
import 'package:libretapp/core/demo/demo_dates.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/care_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/care_rule.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/core/demo/demo_identity.dart';

/// Ids of the built-in rules from `DefaultCareRules` this scenario drives —
/// kept here instead of importing that class so a rule-set change there
/// cannot silently break which rule a demo care record points at.
const String careRuleCattleVaccination = 'default-cattle-vaccination';
const String careRuleCattleDeworming = 'default-cattle-deworming';
const String careRuleCattleTickBath = 'default-cattle-tick-bath';
const String careRuleCattleHoof = 'default-cattle-hoof';
const String careRuleGoatDeworming = 'default-goat-deworming';
const String careRuleSheepDeworming = 'default-sheep-deworming';
const String careRuleVitamins = 'default-vitamins';

class DemoHealthSeries {
  const DemoHealthSeries({required this.animalSlug, required this.records});
  final String animalSlug;
  final List<HealthRecord> records;
}

class DemoCareSeries {
  const DemoCareSeries({required this.animalSlug, required this.records});
  final String animalSlug;
  final List<CareRecord> records;
}

List<DemoHealthSeries> buildDemoHealthRecords({required DateTime reference}) {
  HealthRecord vaccine(
    int daysAgo, {
    int nextDueDays = 365,
    String appliedBy = 'Rodrigo Valenzuela (DEMO)',
  }) {
    final date = daysBefore(reference, daysAgo);
    return HealthRecord(
      date: date,
      type: HealthRecordType.vaccine,
      product: 'Vacuna reproductiva DEMO',
      dose: '5 mL (registro de demostración)',
      appliedBy: appliedBy,
      nextDueDate: daysAfter(date, nextDueDays),
      notes: 'Registro de demostración.',
    );
  }

  HealthRecord deworming(int daysAgo, {int nextDueDays = 180}) {
    final date = daysBefore(reference, daysAgo);
    return HealthRecord(
      date: date,
      type: HealthRecordType.deworming,
      product: 'Desparasitante DEMO',
      dose: 'Según peso (registro de demostración)',
      appliedBy: 'Capataz (DEMO)',
      nextDueDate: daysAfter(date, nextDueDays),
      notes: 'Registro de demostración.',
    );
  }

  return [
    // Vacunación vigente (aplicada hace poco, vence lejos en el futuro).
    DemoHealthSeries(animalSlug: aniWeraSlug, records: [vaccine(60)]),
    // Vacunación vencida.
    DemoHealthSeries(animalSlug: aniPelonaSlug, records: [vaccine(400)]),
    // Desparasitación próxima a vencer.
    DemoHealthSeries(
      animalSlug: aniMiguelitaSlug,
      records: [deworming(170, nextDueDays: 180)],
    ),
    // Baño garrapaticida periódico.
    DemoHealthSeries(
      animalSlug: aniBlanquitaSlug,
      records: [
        HealthRecord(
          date: daysBefore(reference, 15),
          type: HealthRecordType.tickBath,
          product: 'Garrapaticida DEMO',
          dose: 'Aspersión (registro de demostración)',
          appliedBy: 'Capataz (DEMO)',
          nextDueDate: daysAfter(daysBefore(reference, 15), 21),
          notes: 'Registro de demostración.',
        ),
      ],
    ),
    // Vitaminas.
    DemoHealthSeries(
      animalSlug: aniPintaSlug,
      records: [
        HealthRecord(
          date: daysBefore(reference, 45),
          type: HealthRecordType.vitamins,
          product: 'Complejo vitamínico DEMO',
          dose: '10 mL (registro de demostración)',
          appliedBy: 'Rodrigo Valenzuela (DEMO)',
          notes: 'Registro de demostración.',
        ),
      ],
    ),
    // Revisión general (checkup).
    DemoHealthSeries(
      animalSlug: aniGordaSlug,
      records: [
        HealthRecord(
          date: daysBefore(reference, 20),
          type: HealthRecordType.checkup,
          product: 'Revisión clínica general DEMO',
          appliedBy: 'Rodrigo Valenzuela (DEMO)',
          notes: 'Sin hallazgos relevantes. Registro de demostración.',
        ),
      ],
    ),
    // Caso bajo observación (además de underObservation=true en el animal).
    DemoHealthSeries(
      animalSlug: aniPrietitaSlug,
      records: [
        HealthRecord(
          date: daysBefore(reference, 6),
          type: HealthRecordType.checkup,
          product: 'Revisión de ingreso DEMO',
          appliedBy: 'Rodrigo Valenzuela (DEMO)',
          cause: 'Animal de compra reciente, en observación en cuarentena.',
          notes: 'Registro de demostración.',
        ),
      ],
    ),
    // Requiere atención (bajo peso).
    DemoHealthSeries(
      animalSlug: aniBecerra3Slug,
      records: [
        HealthRecord(
          date: daysBefore(reference, 4),
          type: HealthRecordType.disease,
          product: 'Diagnóstico DEMO',
          appliedBy: 'Rodrigo Valenzuela (DEMO)',
          cause: 'Bajo peso para su edad, en seguimiento.',
          notes: 'Registro de demostración.',
        ),
      ],
    ),
    // Tratamiento con retiro activo (excluye de ordeña).
    DemoHealthSeries(
      animalSlug: aniCuernitosSlug,
      records: [
        HealthRecord(
          date: daysBefore(reference, 4),
          type: HealthRecordType.treatment,
          product: 'Antibiótico DEMO',
          dose: 'Dosis de demostración — no usar como referencia clínica',
          appliedBy: 'Rodrigo Valenzuela (DEMO)',
          cause: 'Mastitis leve (registro de prueba).',
          medicineBatch: 'LOTE-DEMO-01',
          withdrawalDays: 10,
          withdrawalEndDate: daysAfter(daysBefore(reference, 4), 10),
          notes:
              'Retiro activo: no ordeñar para venta hasta que termine. '
              'Registro de demostración.',
        ),
      ],
    ),
  ];
}

List<DemoCareSeries> buildDemoCareRecords({required DateTime reference}) {
  CareRecord rec(String slug, String ruleId, CareType type, int daysAgo) =>
      CareRecord(
        id: demoId('care-record', '$slug-$ruleId'),
        animalId: demoAnimalUuid(slug),
        ruleId: ruleId,
        type: type,
        performedAt: daysBefore(reference, daysAgo),
        performedBy: 'Rodrigo Valenzuela (DEMO)',
        notes: 'Registro de demostración.',
      );

  return [
    // Vigente: aplicada hace poco, próxima muy lejos.
    DemoCareSeries(
      animalSlug: aniPrietaSlug,
      records: [
        rec(aniPrietaSlug, careRuleCattleVaccination, CareType.vaccination, 60),
      ],
    ),
    // Vencida: pasó de sobra el intervalo de 365 días.
    DemoCareSeries(
      animalSlug: aniNancySlug,
      records: [
        rec(aniNancySlug, careRuleCattleVaccination, CareType.vaccination, 400),
      ],
    ),
    // Próxima: dentro de la ventana de aviso (10 días).
    DemoCareSeries(
      animalSlug: aniAlazanaSlug,
      records: [
        rec(aniAlazanaSlug, careRuleCattleDeworming, CareType.deworming, 172),
      ],
    ),
    DemoCareSeries(
      animalSlug: aniWeraSlug,
      records: [
        rec(aniWeraSlug, careRuleCattleTickBath, CareType.tickBath, 15),
      ],
    ),
    DemoCareSeries(
      animalSlug: aniPintaSlug,
      records: [rec(aniPintaSlug, careRuleVitamins, CareType.supplement, 100)],
    ),
    DemoCareSeries(
      animalSlug: aniSasoSlug,
      records: [rec(aniSasoSlug, careRuleCattleHoof, CareType.hoofCare, 90)],
    ),
    DemoCareSeries(
      animalSlug: aniCabra2Slug,
      records: [
        rec(aniCabra2Slug, careRuleGoatDeworming, CareType.deworming, 100),
      ],
    ),
    DemoCareSeries(
      animalSlug: aniOveja1Slug,
      records: [
        rec(aniOveja1Slug, careRuleSheepDeworming, CareType.deworming, 60),
      ],
    ),
  ];
}
