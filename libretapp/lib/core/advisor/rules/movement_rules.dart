import 'package:libretapp/core/advisor/livestock_tip.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/health_status.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/life_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/reproductive_status.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/risk_level.dart';

/// Reglas de la biblia ganadera aplicables al mover un animal.
///
/// Cada función evalúa una condición específica del animal y retorna
/// un [LivestockTip] si aplica, o `null` si no.
List<LivestockTip> evaluateMovementRules(
  AnimalEntity animal,
  MovementRecord record,
) {
  return [
    _pregnantAnimalMovement(animal, record),
    _latePregnancyMovement(animal),
    _youngAnimalStress(animal),
    _dietTransition(animal, record),
    _healthCompromisedMovement(animal),
    _highRiskMovement(animal),
    _longDistanceTransport(record),
    _quarantineReminder(record),
    _recentMovementFrequency(animal),
    _lactatingCowMovement(animal),
  ].whereType<LivestockTip>().toList();
}

/// Animal gestante: evitar movimientos innecesarios.
LivestockTip? _pregnantAnimalMovement(
  AnimalEntity animal,
  MovementRecord record,
) {
  if (animal.reproductiveStatus != ReproductiveStatus.pregnant) return null;
  if (record.reason == MovementReason.treatment ||
      record.reason == MovementReason.quarantine) {
    return null; // Movimientos médicos justificados
  }

  return const LivestockTip(
    category: TipCategory.movement,
    severity: TipSeverity.warning,
    title: 'Animal gestante en movimiento',
    description:
        'Este animal está gestante. Los movimientos innecesarios pueden '
        'causar estrés y complicaciones. Evite arreos bruscos, '
        'larga distancia y mezcla con animales desconocidos. '
        'Asegúrese de que tenga acceso inmediato a agua y sombra '
        'en el destino.',
    source: 'Manual de Buenas Prácticas Ganaderas — Bienestar Animal',
  );
}

/// Gestación avanzada (último tercio): alto riesgo de aborto.
LivestockTip? _latePregnancyMovement(AnimalEntity animal) {
  if (animal.reproductiveStatus != ReproductiveStatus.pregnant) return null;
  if (animal.expectedCalvingDate == null) return null;

  final daysToCalving = animal.expectedCalvingDate!
      .difference(DateTime.now())
      .inDays;
  if (daysToCalving > 90) return null; // No está en el último tercio

  return LivestockTip(
    category: TipCategory.reproduction,
    severity: TipSeverity.critical,
    title: 'Gestación avanzada — $daysToCalving días para parto',
    description:
        'Este animal está en el último tercio de gestación. '
        'Mover animales en esta etapa aumenta significativamente '
        'el riesgo de aborto, parto prematuro y distocia. '
        'Solo mueva si es estrictamente necesario (emergencia médica). '
        'Si debe mover, hágalo lentamente, sin perros, y en horas frescas.',
    source: 'Fisiología Reproductiva Bovina — Gestación Tardía',
  );
}

/// Crías y animales jóvenes: estrés por separación y transporte.
LivestockTip? _youngAnimalStress(AnimalEntity animal) {
  final youngStages = {
    LifeStage.calf,
    LifeStage.calfMale,
    LifeStage.calfFemale,
    LifeStage.colt,
    LifeStage.filly,
  };

  if (!youngStages.contains(animal.lifeStage)) return null;

  return const LivestockTip(
    category: TipCategory.movement,
    severity: TipSeverity.warning,
    title: 'Cría joven — riesgo de estrés',
    description:
        'Las crías son especialmente susceptibles al estrés por '
        'movimiento y separación de la madre. Si es posible, mueva '
        'a la cría junto con su madre. Evite mezclar con animales '
        'adultos desconocidos. Asegure acceso a leche/alimento '
        'inmediatamente después del traslado.',
    source: 'Manual de Manejo de Crías — Destete y Transporte',
  );
}

/// Cambio de potrero: introducir nueva dieta gradualmente.
LivestockTip? _dietTransition(AnimalEntity animal, MovementRecord record) {
  if (record.reason != MovementReason.paddockRotation &&
      record.reason != MovementReason.feeding &&
      record.reason != MovementReason.relocation) {
    return null;
  }

  return const LivestockTip(
    category: TipCategory.nutrition,
    severity: TipSeverity.warning,
    title: 'Transición de dieta gradual',
    description:
        'Al cambiar de potrero o ubicación, el pasto y alimento '
        'disponible puede variar. Introduzca la nueva dieta '
        'gradualmente durante 7-10 días para evitar trastornos '
        'digestivos (timpanismo, acidosis). Si el nuevo potrero tiene '
        'leguminosas abundantes (alfalfa, trébol), limite el acceso '
        'inicial a 2-3 horas diarias.',
    source: 'Nutrición de Rumiantes — Adaptación Ruminal',
  );
}

/// Animal con salud comprometida: mover con precaución extrema.
LivestockTip? _healthCompromisedMovement(AnimalEntity animal) {
  if (animal.healthStatus != HealthStatus.poor &&
      animal.healthStatus != HealthStatus.critical) {
    return null;
  }

  return LivestockTip(
    category: TipCategory.health,
    severity: animal.healthStatus == HealthStatus.critical
        ? TipSeverity.critical
        : TipSeverity.warning,
    title: 'Salud comprometida — mover con precaución',
    description:
        'Este animal tiene estado de salud '
        '"${animal.healthStatus.displayName}". El estrés del '
        'movimiento puede agravar su condición. Consulte con un '
        'veterinario antes de mover. Si debe trasladar, hágalo '
        'en vehículo (no a pie), con cama suave y sin otros animales '
        'que puedan empujarlo.',
    source: 'Protocolo de Manejo de Animales Enfermos',
  );
}

/// Animal con riesgo alto o crítico.
LivestockTip? _highRiskMovement(AnimalEntity animal) {
  if (animal.riskLevel != RiskLevel.high &&
      animal.riskLevel != RiskLevel.critical) {
    return null;
  }
  // No duplicar si ya se generó tip de salud comprometida
  if (animal.healthStatus == HealthStatus.poor ||
      animal.healthStatus == HealthStatus.critical) {
    return null;
  }

  return const LivestockTip(
    category: TipCategory.health,
    severity: TipSeverity.warning,
    title: 'Animal con nivel de riesgo elevado',
    description:
        'Este animal tiene un nivel de riesgo elevado. '
        'Considere si el movimiento es realmente necesario. '
        'Monitoree de cerca las primeras 48 horas en la nueva '
        'ubicación. Tenga un plan de contingencia veterinaria.',
    source: 'Gestión de Riesgo Ganadero',
  );
}

/// Transporte largo: medidas especiales.
LivestockTip? _longDistanceTransport(MovementRecord record) {
  if (record.reason != MovementReason.transport) return null;

  return const LivestockTip(
    category: TipCategory.movement,
    severity: TipSeverity.warning,
    title: 'Transporte — cuidados especiales',
    description:
        'Durante el transporte: provea agua y descanso cada 4-6 horas. '
        'No mezcle animales de diferentes orígenes. Evite transportar '
        'en horas de máximo calor. Asegure ventilación adecuada. '
        'Revise que el vehículo tenga piso antideslizante. '
        'Al llegar al destino, permita descanso de 24h antes de '
        'realizar cualquier procedimiento.',
    source: 'Reglamento de Transporte de Ganado — Bienestar Animal',
  );
}

/// Movimiento por cuarentena: recordar protocolos.
LivestockTip? _quarantineReminder(MovementRecord record) {
  if (record.reason != MovementReason.quarantine) return null;

  return const LivestockTip(
    category: TipCategory.health,
    severity: TipSeverity.info,
    title: 'Protocolo de cuarentena',
    description:
        'Al mover a cuarentena: aísle completamente del resto del rebaño '
        '(mínimo 50m de distancia o barrera física). Duración mínima '
        'recomendada: 21-30 días. Use equipos exclusivos (comederos, '
        'bebederos). El personal debe atender primero animales sanos '
        'y luego los cuarentenados. Registre temperatura y '
        'comportamiento diariamente.',
    source: 'Protocolo de Bioseguridad Ganadera — Cuarentena',
  );
}

/// Movimientos frecuentes: estrés acumulado.
LivestockTip? _recentMovementFrequency(AnimalEntity animal) {
  if (animal.lastMovementDate == null) return null;

  final daysSinceLastMove = DateTime.now()
      .difference(animal.lastMovementDate!)
      .inDays;
  if (daysSinceLastMove > 14) return null;

  return LivestockTip(
    category: TipCategory.movement,
    severity: TipSeverity.info,
    title: 'Movimiento reciente hace $daysSinceLastMove días',
    description:
        'Este animal fue movido hace poco. Los movimientos frecuentes '
        'causan estrés acumulado que puede afectar ganancia de peso, '
        'inmunidad y fertilidad. Permita al menos 14 días de '
        'adaptación entre movimientos cuando sea posible.',
    source: 'Manejo de Estrés en Bovinos — Periodo de Adaptación',
  );
}

/// Vaca lactante: asegurar disponibilidad de la cría.
LivestockTip? _lactatingCowMovement(AnimalEntity animal) {
  if (animal.reproductiveStatus != ReproductiveStatus.lactating) return null;

  return const LivestockTip(
    category: TipCategory.reproduction,
    severity: TipSeverity.warning,
    title: 'Vaca lactante — asegurar acceso a cría',
    description:
        'Este animal está en lactación. Si se mueve sin su cría, '
        'puede sufrir estrés severo y retención de leche (mastitis). '
        'Mueva madre y cría juntas siempre que sea posible. '
        'Si la separación es temporal, no exceda 6-8 horas.',
    source: 'Manejo de Vacas Lactantes — Bienestar',
  );
}
