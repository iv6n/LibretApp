/// core › demo › demo_data_integrity_validator — checks referential and
/// derived-data integrity across the whole demo scenario (and, since it
/// takes plain lists rather than a `demo-*` filter, across any real data
/// mixed in with it too).
///
/// Runnable standalone in debug builds or from a test: the caller fetches
/// each collection through the normal repositories and hands the lists to
/// [DemoDataIntegrityValidator.validate], which never touches Isar itself —
/// that is what keeps it usable from a plain-Dart test.
library;

import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/care_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/care_rule.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/scheduled_care.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/finanzas/domain/entities/general_expense_record.dart';
import 'package:libretapp/features/finanzas/domain/entities/income_record.dart';
import 'package:libretapp/features/milking/domain/milking_models.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';

class DemoDataIntegrityFinding {
  const DemoDataIntegrityFinding({
    required this.severity,
    required this.category,
    required this.message,
  });
  final DemoDataIntegritySeverity severity;
  final String category;
  final String message;

  @override
  String toString() => '[${severity.name.toUpperCase()}][$category] $message';
}

enum DemoDataIntegritySeverity { error, warning }

class DemoDataIntegrityReport {
  const DemoDataIntegrityReport(this.findings);
  final List<DemoDataIntegrityFinding> findings;

  List<DemoDataIntegrityFinding> get errors => findings
      .where((f) => f.severity == DemoDataIntegritySeverity.error)
      .toList(growable: false);
  List<DemoDataIntegrityFinding> get warnings => findings
      .where((f) => f.severity == DemoDataIntegritySeverity.warning)
      .toList(growable: false);

  bool get isValid => errors.isEmpty;

  /// Human-readable multi-line report — never just true/false.
  String describe() {
    if (findings.isEmpty) return 'Sin hallazgos: el escenario es íntegro.';
    final buffer = StringBuffer()
      ..writeln(
        '${errors.length} error(es), ${warnings.length} advertencia(s):',
      );
    for (final finding in findings) {
      buffer.writeln('- $finding');
    }
    return buffer.toString();
  }
}

/// Everything the validator needs, gathered ahead of time by the caller.
class DemoDataSnapshot {
  const DemoDataSnapshot({
    required this.animals,
    required this.lotes,
    required this.locations,
    this.weightsByAnimal = const {},
    this.healthByAnimal = const {},
    this.reproductionByAnimal = const {},
    this.careRecordsByAnimal = const {},
    this.scheduledCare = const [],
    this.careRules = const [],
    this.milkingSessions = const [],
    this.milkingEntries = const [],
    this.activeWithdrawalsByAnimal = const {},
    this.incomes = const [],
    this.expenses = const [],
    this.agendaEntries = const [],
    required this.asOf,
  });

  final List<AnimalEntity> animals;
  final List<LoteEntity> lotes;
  final List<LocationEntity> locations;
  final Map<String, List<WeightRecord>> weightsByAnimal;
  final Map<String, List<HealthRecord>> healthByAnimal;
  final Map<String, List<ReproductionRecord>> reproductionByAnimal;
  final Map<String, List<CareRecord>> careRecordsByAnimal;
  final List<ScheduledCare> scheduledCare;
  final List<CareRule> careRules;
  final List<MilkingSession> milkingSessions;
  final List<MilkingEntry> milkingEntries;
  final Map<String, DateTime> activeWithdrawalsByAnimal;
  final List<IncomeRecord> incomes;
  final List<GeneralExpenseRecord> expenses;
  final List<AgendaEntry> agendaEntries;
  final DateTime asOf;
}

class DemoDataIntegrityValidator {
  const DemoDataIntegrityValidator();

  DemoDataIntegrityReport validate(DemoDataSnapshot data) {
    final findings = <DemoDataIntegrityFinding>[];
    void err(String category, String message) => findings.add(
      DemoDataIntegrityFinding(
        severity: DemoDataIntegritySeverity.error,
        category: category,
        message: message,
      ),
    );
    void warn(String category, String message) => findings.add(
      DemoDataIntegrityFinding(
        severity: DemoDataIntegritySeverity.warning,
        category: category,
        message: message,
      ),
    );

    final animalByUuid = <String, AnimalEntity>{};
    for (final animal in data.animals) {
      if (animalByUuid.containsKey(animal.uuid)) {
        err('uuid-duplicado', 'UUID de animal duplicado: ${animal.uuid}');
      }
      animalByUuid[animal.uuid] = animal;
    }

    final loteByUuid = <String, LoteEntity>{};
    for (final lote in data.lotes) {
      if (loteByUuid.containsKey(lote.uuid)) {
        err('uuid-duplicado', 'UUID de lote duplicado: ${lote.uuid}');
      }
      loteByUuid[lote.uuid] = lote;
    }

    final locationByUuid = <String, LocationEntity>{};
    for (final location in data.locations) {
      if (locationByUuid.containsKey(location.uuid)) {
        err('uuid-duplicado', 'UUID de ubicación duplicado: ${location.uuid}');
      }
      locationByUuid[location.uuid] = location;
    }

    _checkDuplicateEarTags(data.animals, err);
    _checkParentage(data.animals, animalByUuid, err);
    _checkImpossibleDates(data.animals, data.asOf, err, warn);
    _checkAnimalLoteConsistency(data.animals, loteByUuid, err);
    _checkLocations(data.animals, locationByUuid, err);
    _checkCapacity(data.animals, data.locations, err);
    _checkWeightSummary(data.animals, data.weightsByAnimal, err);
    _checkReproductionCoherence(
      data.reproductionByAnimal,
      animalByUuid,
      err,
      warn,
    );
    _checkOrphanRecords(
      'careRecords',
      data.careRecordsByAnimal.keys,
      animalByUuid.keys.toSet(),
      err,
    );
    _checkCareForInactiveAnimals(data.scheduledCare, animalByUuid, err);
    _checkDuplicateAutoTasks(data.agendaEntries, err);
    _checkWithdrawalEndDates(data.healthByAnimal, err);
    _checkMilkingEligibility(
      data.milkingEntries,
      data.milkingSessions,
      animalByUuid,
      data.healthByAnimal,
      err,
    );
    _checkFinancialTotals(data.incomes, data.expenses, err, warn);

    return DemoDataIntegrityReport(findings);
  }

  void _checkDuplicateEarTags(
    List<AnimalEntity> animals,
    void Function(String, String) err,
  ) {
    final seen = <String, String>{};
    for (final animal in animals) {
      final tag = animal.earTagNumber.trim();
      if (tag.isEmpty) continue; // one demo animal is intentionally untagged
      final previous = seen[tag];
      if (previous != null) {
        err(
          'identificacion-duplicada',
          'Arete duplicado "$tag": ${animal.uuid} y $previous',
        );
      }
      seen[tag] = animal.uuid;
    }
  }

  void _checkParentage(
    List<AnimalEntity> animals,
    Map<String, AnimalEntity> byUuid,
    void Function(String, String) err,
  ) {
    for (final animal in animals) {
      final sire = animal.sireUuid?.trim();
      final dam = animal.damUuid?.trim();
      if (sire == animal.uuid || dam == animal.uuid) {
        err(
          'parentesco-circular',
          '${animal.uuid} aparece como su propio padre/madre',
        );
      }
      if (sire != null && sire.isNotEmpty && !byUuid.containsKey(sire)) {
        // A sire outside the herd (text-only external stud) is legitimate;
        // only a sireUuid that looks like it should resolve, and doesn't, is
        // an orphan reference. Demo/real animal uuids always resolve.
        if (sire.startsWith('demo-')) {
          err(
            'referencia-huerfana',
            '${animal.uuid} referencia un sireUuid inexistente: $sire',
          );
        }
      }
      if (dam != null && dam.isNotEmpty && !byUuid.containsKey(dam)) {
        err(
          'referencia-huerfana',
          '${animal.uuid} referencia un damUuid inexistente: $dam',
        );
      }
      // Cycle check: walk up from each animal through sireUuid/damUuid and
      // make sure it never revisits itself.
      for (final startUuid in [sire, dam]) {
        if (startUuid == null || startUuid.isEmpty) continue;
        final visited = <String>{animal.uuid};
        var current = byUuid[startUuid];
        var depth = 0;
        while (current != null && depth < 20) {
          if (!visited.add(current.uuid)) {
            err(
              'parentesco-circular',
              'Ciclo genealógico detectado a partir de ${animal.uuid}',
            );
            break;
          }
          final next = current.sireUuid ?? current.damUuid;
          current = next != null ? byUuid[next] : null;
          depth++;
        }
      }
    }
  }

  void _checkImpossibleDates(
    List<AnimalEntity> animals,
    DateTime asOf,
    void Function(String, String) err,
    void Function(String, String) warn,
  ) {
    for (final animal in animals) {
      if (animal.birthDate.isAfter(asOf)) {
        err(
          'fecha-imposible',
          '${animal.uuid} nace en el futuro (${animal.birthDate})',
        );
      }
      if (animal.creationDate.isAfter(animal.lastUpdateDate)) {
        err(
          'fecha-imposible',
          '${animal.uuid}: creationDate posterior a lastUpdateDate',
        );
      }
    }
  }

  void _checkAnimalLoteConsistency(
    List<AnimalEntity> animals,
    Map<String, LoteEntity> lotesByUuid,
    void Function(String, String) err,
  ) {
    for (final animal in animals) {
      final batch = animal.batchUuid;
      if (batch == null) continue;
      final lote = lotesByUuid[batch];
      if (lote == null) {
        err(
          'lote-inconsistente',
          '${animal.uuid} referencia un lote inexistente: $batch',
        );
        continue;
      }
      if (!lote.animalUuids.contains(animal.uuid)) {
        err(
          'lote-inconsistente',
          '${animal.uuid} tiene batchUuid=$batch pero el lote no lo lista '
              'en animalUuids',
        );
      }
      if (!animal.status.isInActiveHerd) {
        err(
          'lote-inconsistente',
          '${animal.uuid} no está en el hato activo pero conserva batchUuid',
        );
      }
    }
    final animalsByUuid = {for (final a in animals) a.uuid: a};
    for (final lote in lotesByUuid.values) {
      final seen = <String>{};
      for (final uuid in lote.animalUuids) {
        if (!seen.add(uuid)) {
          err(
            'lote-inconsistente',
            'Lote ${lote.uuid} lista a $uuid más de una vez',
          );
        }
        final animal = animalsByUuid[uuid];
        if (animal != null && animal.batchUuid != lote.uuid) {
          err(
            'lote-inconsistente',
            'Lote ${lote.uuid} lista a $uuid pero su batchUuid es '
                '${animal.batchUuid}',
          );
        }
      }
    }
  }

  void _checkLocations(
    List<AnimalEntity> animals,
    Map<String, LocationEntity> locationsByUuid,
    void Function(String, String) err,
  ) {
    for (final animal in animals) {
      final locationUuid = animal.currentLocationId;
      if (locationUuid == null) continue;
      final location = locationsByUuid[locationUuid];
      if (location == null) {
        err(
          'ubicacion-inexistente',
          '${animal.uuid} referencia una ubicación inexistente: $locationUuid',
        );
        continue;
      }
      if (animal.status.isInActiveHerd && !location.type.supportsAnimals) {
        err(
          'ubicacion-incompatible',
          '${animal.uuid} está en ${location.uuid} '
              '(${location.type.name}), que no admite animales',
        );
      }
    }
  }

  void _checkCapacity(
    List<AnimalEntity> animals,
    List<LocationEntity> locations,
    void Function(String, String) err,
  ) {
    final occupancy = <String, int>{};
    for (final animal in animals) {
      if (!animal.status.isInActiveHerd) continue;
      final locationUuid = animal.currentLocationId;
      if (locationUuid == null) continue;
      occupancy[locationUuid] = (occupancy[locationUuid] ?? 0) + 1;
    }
    for (final location in locations) {
      if (location.capacity <= 0) continue;
      final count = occupancy[location.uuid] ?? 0;
      if (count > location.capacity) {
        err(
          'capacidad-excedida',
          '${location.uuid} tiene $count animales activos, capacidad '
              '${location.capacity}',
        );
      }
    }
  }

  void _checkWeightSummary(
    List<AnimalEntity> animals,
    Map<String, List<WeightRecord>> weightsByAnimal,
    void Function(String, String) err,
  ) {
    for (final animal in animals) {
      final records = weightsByAnimal[animal.uuid];
      if (records == null || records.isEmpty) continue;
      final sorted = [...records]..sort((a, b) => a.date.compareTo(b.date));
      final last = sorted.last;
      if (animal.weight == null ||
          (animal.weight! - last.weight).abs() > 0.01) {
        err(
          'peso-inconsistente',
          '${animal.uuid}: peso resumen ${animal.weight} no coincide con el '
              'último pesaje ${last.weight}',
        );
      }
    }
  }

  void _checkReproductionCoherence(
    Map<String, List<ReproductionRecord>> reproductionByAnimal,
    Map<String, AnimalEntity> animalByUuid,
    void Function(String, String) err,
    void Function(String, String) warn,
  ) {
    const gestationTolerance = 10;
    for (final entry in reproductionByAnimal.entries) {
      for (final record in entry.value) {
        final expected = record.expectedCalvingDate;
        if (expected != null) {
          final gestation = expected.difference(record.serviceDate).inDays;
          if ((gestation - bovineGestationDaysForValidation).abs() >
              gestationTolerance) {
            warn(
              'parto-incoherente',
              '${entry.key}: gestación de $gestation días fuera del rango '
                  'usual (~283 ± $gestationTolerance)',
            );
          }
        }
        if (record.actualCalvingDate != null && record.calvingOutcome == null) {
          err(
            'parto-incoherente',
            '${entry.key}: actualCalvingDate sin calvingOutcome',
          );
        }
        for (final offspringUuid in record.offspringUuids) {
          final offspring = animalByUuid[offspringUuid];
          if (offspring == null) {
            err(
              'referencia-huerfana',
              '${entry.key}: cría referenciada inexistente $offspringUuid',
            );
            continue;
          }
          if (offspring.damUuid != entry.key) {
            err(
              'parto-incoherente',
              'Cría $offspringUuid no tiene a ${entry.key} como damUuid',
            );
          }
        }
      }
    }
  }

  void _checkOrphanRecords(
    String category,
    Iterable<String> animalUuidsWithRecords,
    Set<String> knownAnimalUuids,
    void Function(String, String) err,
  ) {
    for (final uuid in animalUuidsWithRecords) {
      if (!knownAnimalUuids.contains(uuid)) {
        err(
          'referencia-huerfana',
          '$category tiene registros para un animal inexistente: $uuid',
        );
      }
    }
  }

  void _checkCareForInactiveAnimals(
    List<ScheduledCare> scheduledCare,
    Map<String, AnimalEntity> animalByUuid,
    void Function(String, String) err,
  ) {
    for (final task in scheduledCare) {
      if (task.done) continue;
      final animal = animalByUuid[task.animalId];
      if (animal == null) {
        err(
          'referencia-huerfana',
          'ScheduledCare ${task.id} referencia un animal inexistente: '
              '${task.animalId}',
        );
        continue;
      }
      if (task.autoGenerated && !animal.status.isInActiveHerd) {
        err(
          'cuidado-animal-inactivo',
          '${animal.uuid} (${animal.status.name}) tiene un cuidado '
              'automático pendiente: ${task.id}',
        );
      }
    }
  }

  void _checkDuplicateAutoTasks(
    List<AgendaEntry> agendaEntries,
    void Function(String, String) err,
  ) {
    final seen = <String>{};
    for (final entry in agendaEntries) {
      if (!entry.id.startsWith('auto:')) continue;
      if (!seen.add(entry.id)) {
        err(
          'tarea-automatica-duplicada',
          'Entrada de agenda duplicada: ${entry.id}',
        );
      }
    }
  }

  void _checkWithdrawalEndDates(
    Map<String, List<HealthRecord>> healthByAnimal,
    void Function(String, String) err,
  ) {
    for (final entry in healthByAnimal.entries) {
      for (final record in entry.value) {
        final days = record.withdrawalDays;
        final end = record.withdrawalEndDate;
        if (days == null || end == null) continue;
        final expected = DateTime(
          record.date.year,
          record.date.month,
          record.date.day,
        ).add(Duration(days: days));
        final actual = DateTime(end.year, end.month, end.day);
        if (!actual.isAtSameMomentAs(expected)) {
          err(
            'retiro-incorrecto',
            '${entry.key}: withdrawalEndDate $actual no coincide con '
                'date+withdrawalDays ($expected)',
          );
        }
      }
    }
  }

  void _checkMilkingEligibility(
    List<MilkingEntry> entries,
    List<MilkingSession> sessions,
    Map<String, AnimalEntity> animalByUuid,
    Map<String, List<HealthRecord>> healthByAnimal,
    void Function(String, String) err,
  ) {
    final sessionByUuid = {for (final s in sessions) s.uuid: s};
    for (final entry in entries) {
      final animal = animalByUuid[entry.animalUuid];
      if (animal == null) {
        err(
          'referencia-huerfana',
          'MilkingEntry ${entry.uuid} referencia un animal inexistente: '
              '${entry.animalUuid}',
        );
        continue;
      }
      if (animal.species != Species.cattle ||
          animal.sex != Sex.female ||
          animal.status != AnimalStatus.active) {
        err(
          'ordena-no-elegible',
          '${animal.uuid} no es una hembra bovina activa pero tiene '
              'MilkingEntry ${entry.uuid}',
        );
      }
      final session = sessionByUuid[entry.sessionUuid];
      if (session == null) continue;

      // A withdrawal is only relevant while `session.occurredAt` actually
      // falls inside its `[date, withdrawalEndDate]` window — checking only
      // "before withdrawalEndDate" (as a live "asOf today" snapshot would)
      // is wrong here because these sessions span weeks in the past, most
      // of them well before the treatment that started the withdrawal.
      for (final record in healthByAnimal[animal.uuid] ?? const []) {
        final end = record.withdrawalEndDate;
        if (end == null) continue;
        final start = record.date;
        if (!session.occurredAt.isBefore(start) &&
            session.occurredAt.isBefore(end)) {
          err(
            'ordena-no-elegible',
            '${animal.uuid} está en retiro sanitario ($start a $end) pero '
                'tiene una sesión de ordeña en ${session.occurredAt}',
          );
        }
      }
    }
  }

  void _checkFinancialTotals(
    List<IncomeRecord> incomes,
    List<GeneralExpenseRecord> expenses,
    void Function(String, String) err,
    void Function(String, String) warn,
  ) {
    for (final income in incomes) {
      if (income.amount.isNaN || income.amount <= 0) {
        err(
          'finanzas-inconsistentes',
          'Ingreso ${income.id ?? income.date} con monto inválido: '
              '${income.amount}',
        );
      }
      if (income.currency != null && income.currency != 'MXN') {
        warn(
          'finanzas-inconsistentes',
          'Ingreso ${income.id ?? income.date} en moneda ${income.currency}, '
              'se esperaba MXN',
        );
      }
    }
    for (final expense in expenses) {
      if (expense.amount.isNaN || expense.amount <= 0) {
        err(
          'finanzas-inconsistentes',
          'Gasto ${expense.id ?? expense.date} con monto inválido: '
              '${expense.amount}',
        );
      }
    }
  }
}

/// Kept separate from `bovineGestationDays` in `demo_reproduction.dart` so
/// this file has no dependency on the demo builders — the validator is
/// meant to check real data too, not just the demo scenario.
const int bovineGestationDaysForValidation = 283;
