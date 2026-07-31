/// features \u203a directorio \u203a animales \u203a domain \u203a services \u203a animal_lifecycle_calculator \u2014 calculates age and lifecycle stage for animals.
library;

import 'package:libretapp/features/directorio/animales/domain/enums/life_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/sex.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_taxonomy.dart';

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

  /// Whole months elapsed between two dates, clamped at zero.
  ///
  /// Shared so every age-like figure in the app (animal age, age at first
  /// calving, months since an event) is counted the same way.
  static int monthsBetween(DateTime from, DateTime to) {
    var months = (to.year - from.year) * 12 + (to.month - from.month);

    if (to.day < from.day) {
      months -= 1;
    }

    return months < 0 ? 0 : months;
  }

  static int _calculateAgeInMonths(DateTime birthDate, DateTime referenceDate) {
    return monthsBetween(birthDate, referenceDate);
  }

  static LifeStage _resolveLifeStage({
    required Species species,
    required Sex sex,
    required int ageMonths,
    LifeStage? fallback,
  }) {
    return AnimalTaxonomy.resolveLifeStage(
      species: species,
      sex: sex,
      ageMonths: ageMonths,
      fallback: fallback,
    );
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
