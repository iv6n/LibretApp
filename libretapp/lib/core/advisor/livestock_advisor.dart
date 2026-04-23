import 'package:libretapp/core/advisor/livestock_tip.dart';
import 'package:libretapp/core/advisor/rules/health_rules.dart';
import 'package:libretapp/core/advisor/rules/movement_rules.dart';
import 'package:libretapp/core/advisor/rules/nutrition_rules.dart';
import 'package:libretapp/core/advisor/rules/production_rules.dart';
import 'package:libretapp/core/advisor/rules/reproduction_rules.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';

/// Servicio central de la "Biblia Ganadera".
///
/// Orquesta la evaluación de reglas contextuales según la acción que
/// el usuario está realizando y el estado actual del animal.
///
/// Uso:
/// ```dart
/// final tips = LivestockAdvisor.forMovement(animal, record);
/// final tips = LivestockAdvisor.forHealth(animal, record);
/// final tips = LivestockAdvisor.forReproduction(animal, record);
/// final tips = LivestockAdvisor.forAnimalProfile(animal);
/// ```
class LivestockAdvisor {
  LivestockAdvisor._();

  /// Tips al registrar un movimiento.
  static List<LivestockTip> forMovement(
    AnimalEntity animal,
    MovementRecord record,
  ) {
    return _sortBySeverity(evaluateMovementRules(animal, record));
  }

  /// Tips al registrar un evento de salud.
  static List<LivestockTip> forHealth(
    AnimalEntity animal,
    HealthRecord record,
  ) {
    return _sortBySeverity(evaluateHealthRules(animal, record));
  }

  /// Tips al registrar un evento reproductivo.
  static List<LivestockTip> forReproduction(
    AnimalEntity animal,
    ReproductionRecord record,
  ) {
    return _sortBySeverity(evaluateReproductionRules(animal, record));
  }

  /// Tips generales al consultar el perfil de un animal.
  ///
  /// Combina reglas de nutrición y producción que no dependen
  /// de un registro específico.
  static List<LivestockTip> forAnimalProfile(AnimalEntity animal) {
    final tips = <LivestockTip>[
      ...evaluateNutritionRules(animal),
      ...evaluateProductionRules(animal),
    ];
    return _sortBySeverity(tips);
  }

  /// Ordena los tips poniendo los más severos primero.
  static List<LivestockTip> _sortBySeverity(List<LivestockTip> tips) {
    if (tips.isEmpty) return tips;
    return tips..sort((a, b) => b.severity.index.compareTo(a.severity.index));
  }
}
