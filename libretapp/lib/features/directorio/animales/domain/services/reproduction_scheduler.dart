import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';

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

  ReproductionScheduleResult estimate({
    required DateTime serviceDate,
    int gestationDays = 283,
    int pregCheckAfterDays = 35,
    int dryOffBeforeDays = 60,
    int closeUpBeforeDays = 21,
  }) {
    final dueDate = serviceDate.add(Duration(days: gestationDays));
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
    int gestationDays = 283,
    int pregCheckAfterDays = 35,
    int dryOffBeforeDays = 60,
    int closeUpBeforeDays = 21,
  }) {
    final schedule = estimate(
      serviceDate: record.serviceDate,
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
