/// features \u203a directorio \u203a animales \u203a domain \u203a services \u203a reproduction_scheduler \u2014 schedules reproduction-cycle alerts.
library;

import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';

class ReproductionScheduleResult {
  const ReproductionScheduleResult({
    required this.dueDate,
    this.pregnancyCheckDate,
    this.dryOffDate,
    this.closeUpDate,
  });
  final DateTime dueDate;
  final DateTime? pregnancyCheckDate;
  final DateTime? dryOffDate;
  final DateTime? closeUpDate;
}

/// Calcula hitos básicos de gestación y parto.
class ReproductionScheduler {
  const ReproductionScheduler();

  static int gestationDaysFor(Species species) => switch (species) {
    Species.sheep => 147,
    Species.goat => 150,
    // Retain the established default for species outside this first release.
    _ => 283,
  };

  ReproductionScheduleResult estimate({
    required DateTime serviceDate,
    Species species = Species.cattle,
    int? gestationDays,
    int pregCheckAfterDays = 35,
    int dryOffBeforeDays = 60,
    int closeUpBeforeDays = 21,
  }) {
    final dueDate = serviceDate.add(
      Duration(days: gestationDays ?? gestationDaysFor(species)),
    );
    final pregCheckDate = serviceDate.add(Duration(days: pregCheckAfterDays));
    final dryOffDate = dueDate.subtract(Duration(days: dryOffBeforeDays));
    final closeUpDate = dueDate.subtract(Duration(days: closeUpBeforeDays));
    return ReproductionScheduleResult(
      dueDate: dueDate,
      pregnancyCheckDate: pregCheckDate,
      dryOffDate: dryOffDate,
      closeUpDate: closeUpDate,
    );
  }

  /// Actualiza un registro de reproducción con fechas calculadas.
  ReproductionRecord withDates({
    required ReproductionRecord record,
    Species species = Species.cattle,
    int? gestationDays,
    int pregCheckAfterDays = 35,
    int dryOffBeforeDays = 60,
    int closeUpBeforeDays = 21,
  }) {
    if (record.serviceDate == null) return record;
    final schedule = estimate(
      serviceDate: record.serviceDate!,
      species: species,
      gestationDays: gestationDays,
      pregCheckAfterDays: pregCheckAfterDays,
      dryOffBeforeDays: dryOffBeforeDays,
      closeUpBeforeDays: closeUpBeforeDays,
    );
    return record.copyWith(
      expectedCalvingDate: schedule.dueDate,
      pregnancyCheckDate: schedule.pregnancyCheckDate,
    );
  }
}
