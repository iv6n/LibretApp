/// features › directorio › animales › domain › services › animal_purpose_indicators — purpose-aware card indicators.
library;

import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_purpose.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/reproductive_status.dart';
import 'package:libretapp/features/directorio/animales/domain/services/reproductive_kpi_service.dart';

/// What an indicator is measuring. Typed so the UI can style or reorder
/// without parsing the rendered label, and so tests assert on meaning rather
/// than on wording.
enum PurposeIndicatorKind {
  weight,
  dailyGain,
  milkPerDay,
  daysInMilk,
  daysPregnant,
  daysOpen,
  calvingInterval,
  calvingCount,
  reproductiveState,
  age,
  bodyCondition,
  lastShearing,
  layingState,
  healthState,
  milkWithdrawal,
  overdueCalving,
  definePurpose,
}

/// How loudly an indicator should be shown. [critical] entries always win a
/// slot: a live withdrawal period is a food-safety matter, not a statistic.
enum IndicatorSeverity { neutral, attention, critical }

class PurposeIndicator {
  const PurposeIndicator({
    required this.kind,
    required this.label,
    this.severity = IndicatorSeverity.neutral,
  });

  final PurposeIndicatorKind kind;

  /// Ready-to-render text. Composed here rather than in the widget so the
  /// wording lives beside the rules that decide when it applies, matching how
  /// the domain enums already expose `displayName`.
  final String label;

  final IndicatorSeverity severity;
}

/// Facts pulled from the record collections that the animal row alone cannot
/// answer. Built once per page of results, never per card.
///
/// Every field is optional: when the snapshot is absent or incomplete the
/// service degrades to the denormalized fields on [AnimalEntity], so a card
/// is never blank while data is still loading.
class AnimalIndicatorSnapshot {
  const AnimalIndicatorSnapshot({
    this.lastWeightKg,
    this.averageDailyGainKg,
    this.milkLitersPerDay,
    this.daysInMilk,
    this.reproductiveKpis,
    this.withdrawalEndsOn,
    this.nextCareDueOn,
    this.lastShearingDate,
    this.eggsPerWeek,
  });

  static const AnimalIndicatorSnapshot empty = AnimalIndicatorSnapshot();

  final double? lastWeightKg;

  /// Ganancia diaria de peso measured between the two most recent weighings,
  /// as opposed to [AnimalEntity.dailyGainEstimate] which is typed in by hand.
  final double? averageDailyGainKg;

  final double? milkLitersPerDay;
  final int? daysInMilk;
  final AnimalReproductiveKpis? reproductiveKpis;

  /// End of an active medicine withdrawal period, if one is running.
  final DateTime? withdrawalEndsOn;

  final DateTime? nextCareDueOn;
  final DateTime? lastShearingDate;

  /// Placeholder for laying birds. There is no egg-production entity yet, so
  /// this stays null and the laying indicator falls back to age.
  final double? eggsPerWeek;
}

/// Days open past which a breeding female is worth flagging. Beyond roughly
/// four months open she will not hold a yearly calving interval.
const int _daysOpenAttentionThreshold = 120;

/// A calving interval above this has already cost a calf.
const double _calvingIntervalAttentionDays = 450;

/// Builds the indicators shown on an animal card, chosen by production
/// purpose.
///
/// Returns at most [maxIndicators] entries, most severe first, so a card never
/// overflows and the urgent thing is never the one that got cut.
List<PurposeIndicator> indicatorsFor(
  AnimalEntity animal, {
  AnimalIndicatorSnapshot? snapshot,
  DateTime? now,
  int maxIndicators = 3,
}) {
  final reference = now ?? DateTime.now();
  final data = snapshot ?? AnimalIndicatorSnapshot.empty;
  final indicators = <PurposeIndicator>[];

  // Applies to every purpose: an animal under withdrawal must not have its
  // milk or meat sold, whatever it is being raised for.
  final withdrawal = _withdrawalIndicator(data, reference);
  if (withdrawal != null) indicators.add(withdrawal);

  switch (animal.productionPurpose) {
    case ProductionPurpose.meat:
      indicators.addAll(_meatIndicators(animal, data));
    case ProductionPurpose.dairy:
      indicators.addAll(_dairyIndicators(animal, data, reference));
    case ProductionPurpose.breeding:
    case ProductionPurpose.dual:
      indicators.addAll(_breedingIndicators(animal, data, reference));
    case ProductionPurpose.eggs:
      indicators.addAll(_eggIndicators(animal, data));
    case ProductionPurpose.fiber:
      indicators.addAll(_fiberIndicators(animal, data, reference));
    case ProductionPurpose.work:
    case ProductionPurpose.sport:
      indicators.addAll(_workIndicators(animal));
    case ProductionPurpose.guard:
    case ProductionPurpose.companion:
      indicators.addAll(_companionIndicators(animal, data, reference));
    case ProductionPurpose.undefined:
      indicators.add(
        const PurposeIndicator(
          kind: PurposeIndicatorKind.definePurpose,
          label: 'Definir propósito',
          severity: IndicatorSeverity.attention,
        ),
      );
    case ProductionPurpose.other:
      break;
  }

  indicators.sort(
    (a, b) => b.severity.index.compareTo(a.severity.index),
  );
  return List<PurposeIndicator>.unmodifiable(
    indicators.take(maxIndicators),
  );
}

PurposeIndicator? _withdrawalIndicator(
  AnimalIndicatorSnapshot data,
  DateTime now,
) {
  final endsOn = data.withdrawalEndsOn;
  if (endsOn == null || !endsOn.isAfter(now)) return null;

  final days = endsOn.difference(now).inDays + 1;
  return PurposeIndicator(
    kind: PurposeIndicatorKind.milkWithdrawal,
    label: 'Retiro $days ${days == 1 ? 'día' : 'días'}',
    severity: IndicatorSeverity.critical,
  );
}

List<PurposeIndicator> _meatIndicators(
  AnimalEntity animal,
  AnimalIndicatorSnapshot data,
) {
  final indicators = <PurposeIndicator>[];

  final weight = data.lastWeightKg ?? animal.weight;
  if (weight != null && weight > 0) {
    indicators.add(
      PurposeIndicator(
        kind: PurposeIndicatorKind.weight,
        label: _formatKg(weight),
      ),
    );
  }

  // Prefer the gain measured between real weighings over the typed estimate.
  final gain = data.averageDailyGainKg ?? animal.dailyGainEstimate;
  if (gain != null && gain != 0) {
    final sign = gain > 0 ? '+' : '';
    indicators.add(
      PurposeIndicator(
        kind: PurposeIndicatorKind.dailyGain,
        label: '$sign${_formatKg(gain)}/día',
        // Losing weight in a fattening animal is the whole signal.
        severity: gain < 0 ? IndicatorSeverity.attention : IndicatorSeverity.neutral,
      ),
    );
  }

  return indicators;
}

List<PurposeIndicator> _dairyIndicators(
  AnimalEntity animal,
  AnimalIndicatorSnapshot data,
  DateTime now,
) {
  final indicators = <PurposeIndicator>[];

  final liters = data.milkLitersPerDay;
  if (liters != null && liters > 0) {
    indicators.add(
      PurposeIndicator(
        kind: PurposeIndicatorKind.milkPerDay,
        label: '${_formatDecimal(liters)} L/día',
      ),
    );
  }

  final daysInMilk = data.daysInMilk;
  if (daysInMilk != null && daysInMilk >= 0) {
    indicators.add(
      PurposeIndicator(
        kind: PurposeIndicatorKind.daysInMilk,
        label: '$daysInMilk d. lactancia',
      ),
    );
  }

  final pregnancy = _pregnancyIndicator(animal, data, now);
  if (pregnancy != null) {
    indicators.add(pregnancy);
  } else if (liters == null) {
    // Nothing measured yet: fall back to the state stored on the animal so a
    // dry or lactating cow still says something.
    final state = _reproductiveStateIndicator(animal);
    if (state != null) indicators.add(state);
  }

  return indicators;
}

List<PurposeIndicator> _breedingIndicators(
  AnimalEntity animal,
  AnimalIndicatorSnapshot data,
  DateTime now,
) {
  final indicators = <PurposeIndicator>[];
  final kpis = data.reproductiveKpis;

  final pregnancy = _pregnancyIndicator(animal, data, now);
  if (pregnancy != null) {
    indicators.add(pregnancy);
  } else {
    final daysOpen = kpis?.daysOpen;
    if (daysOpen != null && (kpis?.daysOpenIsOngoing ?? false)) {
      indicators.add(
        PurposeIndicator(
          kind: PurposeIndicatorKind.daysOpen,
          label: '$daysOpen d. abierta',
          severity: daysOpen > _daysOpenAttentionThreshold
              ? IndicatorSeverity.attention
              : IndicatorSeverity.neutral,
        ),
      );
    } else {
      final state = _reproductiveStateIndicator(animal);
      if (state != null) indicators.add(state);
    }
  }

  final interval = kpis?.averageCalvingIntervalDays;
  if (interval != null) {
    indicators.add(
      PurposeIndicator(
        kind: PurposeIndicatorKind.calvingInterval,
        label: 'IEP ${interval.round()} d',
        severity: interval > _calvingIntervalAttentionDays
            ? IndicatorSeverity.attention
            : IndicatorSeverity.neutral,
      ),
    );
  }

  final calvings = kpis?.calvingCount ?? 0;
  if (calvings > 0) {
    indicators.add(
      PurposeIndicator(
        kind: PurposeIndicatorKind.calvingCount,
        label: '$calvings ${calvings == 1 ? 'parto' : 'partos'}',
      ),
    );
  }

  return indicators;
}

List<PurposeIndicator> _eggIndicators(
  AnimalEntity animal,
  AnimalIndicatorSnapshot data,
) {
  final eggs = data.eggsPerWeek;
  if (eggs != null && eggs > 0) {
    return [
      PurposeIndicator(
        kind: PurposeIndicatorKind.layingState,
        label: '${_formatDecimal(eggs)} huevos/sem',
      ),
    ];
  }

  // No egg records exist in the model yet; age is the honest stand-in, since
  // it is what tells the breeder whether a bird should be laying at all.
  return [_ageIndicator(animal)];
}

List<PurposeIndicator> _fiberIndicators(
  AnimalEntity animal,
  AnimalIndicatorSnapshot data,
  DateTime now,
) {
  final shearing = data.lastShearingDate;
  if (shearing == null || shearing.isAfter(now)) {
    return [_ageIndicator(animal)];
  }

  final months = (now.difference(shearing).inDays / 30.44).floor();
  return [
    PurposeIndicator(
      kind: PurposeIndicatorKind.lastShearing,
      label: months <= 0
          ? 'Esquila reciente'
          : 'Esquila hace $months ${months == 1 ? 'mes' : 'meses'}',
      // Fleece is usually harvested yearly; well past that is money on the hoof.
      severity: months >= 12
          ? IndicatorSeverity.attention
          : IndicatorSeverity.neutral,
    ),
  ];
}

List<PurposeIndicator> _workIndicators(AnimalEntity animal) {
  final indicators = <PurposeIndicator>[_ageIndicator(animal)];

  final score = animal.bodyConditionScore;
  if (score != null) {
    indicators.add(
      PurposeIndicator(
        kind: PurposeIndicatorKind.bodyCondition,
        label: 'CC $score/5',
        severity: score <= 2 ? IndicatorSeverity.attention : IndicatorSeverity.neutral,
      ),
    );
  }

  return indicators;
}

List<PurposeIndicator> _companionIndicators(
  AnimalEntity animal,
  AnimalIndicatorSnapshot data,
  DateTime now,
) {
  final indicators = <PurposeIndicator>[
    PurposeIndicator(
      kind: PurposeIndicatorKind.healthState,
      label: animal.healthStatus.displayName,
    ),
  ];

  final due = data.nextCareDueOn;
  if (due != null) {
    final days = due.difference(now).inDays;
    indicators.add(
      PurposeIndicator(
        kind: PurposeIndicatorKind.healthState,
        label: days < 0
            ? 'Vacuna vencida'
            : 'Vacuna en $days ${days == 1 ? 'día' : 'días'}',
        severity: days < 0
            ? IndicatorSeverity.attention
            : IndicatorSeverity.neutral,
      ),
    );
  }

  return indicators;
}

/// Days pregnant, preferring the measured cycle over the denormalized status.
PurposeIndicator? _pregnancyIndicator(
  AnimalEntity animal,
  AnimalIndicatorSnapshot data,
  DateTime now,
) {
  final gestationDays = data.reproductiveKpis?.currentGestationDays;
  if (gestationDays != null) {
    final expected = data.reproductiveKpis?.expectedCalvingDate;
    if (expected != null && expected.isBefore(now)) {
      final overdue = now.difference(expected).inDays;
      return PurposeIndicator(
        kind: PurposeIndicatorKind.overdueCalving,
        label: 'Parto vencido $overdue d',
        severity: IndicatorSeverity.critical,
      );
    }
    return PurposeIndicator(
      kind: PurposeIndicatorKind.daysPregnant,
      label: '$gestationDays d. preñez',
    );
  }

  if (animal.reproductiveStatus != ReproductiveStatus.pregnant) return null;

  final months = _pregnancyMonthsFromEntity(animal, now);
  return PurposeIndicator(
    kind: PurposeIndicatorKind.daysPregnant,
    label: months == null
        ? 'Gestante'
        : '$months ${months == 1 ? 'mes' : 'meses'} preñez',
  );
}

PurposeIndicator? _reproductiveStateIndicator(AnimalEntity animal) {
  switch (animal.reproductiveStatus) {
    case ReproductiveStatus.virgin:
    case ReproductiveStatus.active:
    case ReproductiveStatus.lactating:
    case ReproductiveStatus.dry:
    case ReproductiveStatus.pregnant:
      return PurposeIndicator(
        kind: PurposeIndicatorKind.reproductiveState,
        label: animal.reproductiveStatus.displayName,
      );
    case ReproductiveStatus.neutered:
    case ReproductiveStatus.retired:
    case ReproductiveStatus.unknown:
      return null;
  }
}

PurposeIndicator _ageIndicator(AnimalEntity animal) {
  final months = animal.ageMonths;
  final years = months ~/ 12;
  final label = years > 0
      ? '$years ${years == 1 ? 'año' : 'años'}'
      : '$months ${months == 1 ? 'mes' : 'meses'}';
  return PurposeIndicator(kind: PurposeIndicatorKind.age, label: label);
}

// Standard bovine gestation length, mirroring ReproductionScheduler's default.
const int _gestationDays = 283;

int? _pregnancyMonthsFromEntity(AnimalEntity animal, DateTime now) {
  var serviceDate = animal.lastServiceDate ?? animal.firstServiceDate;
  if (serviceDate == null && animal.expectedCalvingDate != null) {
    serviceDate = animal.expectedCalvingDate!.subtract(
      const Duration(days: _gestationDays),
    );
  }
  if (serviceDate == null || serviceDate.isAfter(now)) return null;

  final months = (now.difference(serviceDate).inDays / 30.44).floor();
  return months.clamp(0, 9);
}

String _formatKg(double value) => '${_formatDecimal(value)} kg';

String _formatDecimal(double value) {
  return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
}
