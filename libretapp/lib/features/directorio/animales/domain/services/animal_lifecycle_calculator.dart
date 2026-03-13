import 'package:libretapp/features/directorio/animales/domain/enums/life_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/sex.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';

/// Calcula la edad en meses y la etapa de vida de un animal a partir de su
/// fecha de nacimiento, especie y sexo.
class AnimalLifecycleCalculator {
  const AnimalLifecycleCalculator._();

  static AnimalLifecycleResult calculate({
    required DateTime birthDate,
    required Species species,
    required Sex sex,
    LifeStage? currentLifeStage,
    DateTime? now,
  }) {
    final referenceDate = now ?? DateTime.now();
    final ageMonths = _calculateAgeInMonths(birthDate, referenceDate);
    final resolvedLifeStage = _resolveLifeStage(
      species: species,
      sex: sex,
      ageMonths: ageMonths,
      fallback: currentLifeStage,
    );

    return AnimalLifecycleResult(
      ageMonths: ageMonths,
      lifeStage: resolvedLifeStage,
    );
  }

  static int _calculateAgeInMonths(DateTime birthDate, DateTime referenceDate) {
    var months =
        (referenceDate.year - birthDate.year) * 12 +
        (referenceDate.month - birthDate.month);

    if (referenceDate.day < birthDate.day) {
      months -= 1;
    }

    return months < 0 ? 0 : months;
  }

  static LifeStage _resolveLifeStage({
    required Species species,
    required Sex sex,
    required int ageMonths,
    LifeStage? fallback,
  }) {
    switch (species) {
      case Species.cattle:
        if (ageMonths < 12) {
          return sex == Sex.female ? LifeStage.calfFemale : LifeStage.calfMale;
        }
        if (ageMonths < 24) {
          return sex == Sex.female ? LifeStage.heifer : LifeStage.youngBull;
        }
        return sex == Sex.female ? LifeStage.cow : LifeStage.bull;
      case Species.equine:
        if (ageMonths < 36) {
          return sex == Sex.female ? LifeStage.filly : LifeStage.colt;
        }
        return sex == Sex.female ? LifeStage.mare : LifeStage.horse;
      default:
        if (ageMonths < 12) {
          return sex == Sex.female ? LifeStage.calfFemale : LifeStage.calfMale;
        }
        if (ageMonths < 24) {
          return sex == Sex.female ? LifeStage.heifer : LifeStage.youngBull;
        }
        return fallback ?? (sex == Sex.female ? LifeStage.cow : LifeStage.bull);
    }
  }
}

class AnimalLifecycleResult {
  const AnimalLifecycleResult({
    required this.ageMonths,
    required this.lifeStage,
  });
  final int ageMonths;
  final LifeStage lifeStage;
}
