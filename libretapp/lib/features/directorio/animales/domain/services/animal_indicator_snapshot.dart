/// Shared, measured figures for list cards and the animal summary.
library;

import '../animal_domain.dart';
import 'package:libretapp/features/milking/domain/milking_models.dart';

AnimalIndicatorSnapshot buildAnimalIndicatorSnapshot({
  required AnimalEntity animal,
  List<WeightRecord> weights = const [],
  List<ReproductionRecord> reproductions = const [],
  List<MilkingRecord> milkings = const [],
  DateTime? withdrawalEndsOn,
  DateTime? nextCareDueOn,
  DateTime? now,
}) {
  final reference = now ?? DateTime.now();
  final orderedWeights =
      weights.where((w) => !w.date.isAfter(reference)).toList()..sort((a, b) {
        final date = b.date.compareTo(a.date);
        if (date != 0) return date;
        final created = (b.createdAt ?? b.date).compareTo(
          a.createdAt ?? a.date,
        );
        if (created != 0) return created;
        return (b.recordUuid ?? b.id ?? '').compareTo(
          a.recordUuid ?? a.id ?? '',
        );
      });
  final measuredWeights = orderedWeights
      .where((w) => w.method == WeightMethod.scale)
      .toList();
  final distinctDays = <DateTime, WeightRecord>{};
  for (final record in measuredWeights) {
    distinctDays.putIfAbsent(
      DateTime(record.date.year, record.date.month, record.date.day),
      () => record,
    );
  }
  final measured = distinctDays.values.toList();
  double? dailyGain;
  if (measured.length >= 2) {
    final days =
        DateTime(
              measured[0].date.year,
              measured[0].date.month,
              measured[0].date.day,
            )
            .difference(
              DateTime(
                measured[1].date.year,
                measured[1].date.month,
                measured[1].date.day,
              ),
            )
            .inDays;
    if (days > 0) {
      dailyGain = (measured[0].weight - measured[1].weight) / days;
    }
  }
  final litersByDay = <DateTime, double>{};
  final since = reference.subtract(const Duration(days: 7));
  for (final record in milkings) {
    final occurred = record.session.occurredAt;
    if (occurred.isBefore(since) || occurred.isAfter(reference)) continue;
    final day = DateTime(occurred.year, occurred.month, occurred.day);
    litersByDay.update(
      day,
      (liters) => liters + record.entry.liters,
      ifAbsent: () => record.entry.liters,
    );
  }
  return AnimalIndicatorSnapshot(
    lastWeightKg: orderedWeights.firstOrNull?.weight,
    lastWeightDate: orderedWeights.firstOrNull?.date,
    lastWeightMethod: orderedWeights.firstOrNull?.method,
    averageDailyGainKg: dailyGain,
    milkLitersPerDay: litersByDay.isEmpty
        ? null
        : litersByDay.values.reduce((a, b) => a + b) / litersByDay.length,
    reproductiveKpis: animal.sex != Sex.female || reproductions.isEmpty
        ? null
        : const ReproductiveKpiService().forAnimal(
            records: reproductions,
            birthDate: animal.birthDate,
            now: reference,
          ),
    withdrawalEndsOn: withdrawalEndsOn,
    nextCareDueOn: animal.status.isInActiveHerd ? nextCareDueOn : null,
  );
}
