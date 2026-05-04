/// core › advisor › rules › production_rules — rules that generate production-related advisor tips.
library;

import 'package:libretapp/core/advisor/livestock_tip.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_purpose.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';

/// Reglas de la biblia ganadera aplicables a producción.
///
/// Se evalúan sobre el estado productivo actual del animal.
List<LivestockTip> evaluateProductionRules(AnimalEntity animal) {
  return [
    _undefinedProductionPurpose(animal),
    _weightMonitoring(animal),
    _dailyGainEstimate(animal),
    _pastoreoIntensivo(animal),
    _dualPurposeManagement(animal),
    _finishingReadiness(animal),
    _idleStageReview(animal),
  ].whereType<LivestockTip>().toList();
}

/// Propósito productivo sin definir.
LivestockTip? _undefinedProductionPurpose(AnimalEntity animal) {
  if (animal.productionPurpose != ProductionPurpose.undefined) return null;

  return const LivestockTip(
    category: TipCategory.production,
    severity: TipSeverity.warning,
    title: 'Propósito productivo sin definir',
    description:
        'Este animal no tiene definido su propósito productivo '
        '(carne, leche, doble propósito, reproducción). Definirlo '
        'permite aplicar el manejo nutricional, sanitario y '
        'reproductivo adecuado. Un animal sin propósito claro '
        'recibe manejo genérico y no optimiza su potencial.',
    source: 'Planificación Ganadera — Clasificación Productiva',
  );
}

/// Monitoreo de peso: alertar si no tiene peso registrado.
LivestockTip? _weightMonitoring(AnimalEntity animal) {
  if (animal.weight != null) return null;

  return const LivestockTip(
    category: TipCategory.production,
    severity: TipSeverity.info,
    title: 'Sin registro de peso',
    description:
        'No hay peso registrado. El peso es el dato productivo '
        'más importante: determina dosis de medicamentos, momento '
        'de venta, ganancia diaria y estado nutricional. '
        'Pese mensualmente. Si no tiene báscula, use cinta '
        'bovinométrica (correlación del 95% con el peso real '
        'en animales con condición corporal normal).',
    source: 'Pesaje y Monitoreo — Herramientas de Campo',
  );
}

/// Ganancia diaria de peso estimada: evaluar si es adecuada.
LivestockTip? _dailyGainEstimate(AnimalEntity animal) {
  if (animal.dailyGainEstimate == null) return null;
  if (animal.dailyGainEstimate! >= 0.5) return null; // Aceptable

  return LivestockTip(
    category: TipCategory.production,
    severity: TipSeverity.warning,
    title: 'GDP baja (${animal.dailyGainEstimate!.toStringAsFixed(2)} kg/día)',
    description:
        'La ganancia diaria de peso estimada es '
        '${animal.dailyGainEstimate!.toStringAsFixed(2)} kg/día. '
        'Para bovinos en crecimiento, se espera ≥0.5 kg/día en '
        'pastoreo y ≥1.0 kg/día en corral. GDP baja indica '
        'deficiencias nutricionales o problemas sanitarios '
        '(parasitismo, infecciones subclínicas). '
        'Revise oferta forrajera y estado sanitario.',
    source: 'Indicadores Productivos — Ganancia Diaria de Peso',
  );
}

/// Sistema de pastoreo intensivo: manejo de potreros.
LivestockTip? _pastoreoIntensivo(AnimalEntity animal) {
  if (animal.productionSystem != ProductionSystem.intensive &&
      animal.productionSystem != ProductionSystem.feedlot) {
    return null;
  }
  // Solo si el animal está en especies de pastoreo.
  if (animal.species == Species.poultry) return null;

  return const LivestockTip(
    category: TipCategory.production,
    severity: TipSeverity.info,
    title: 'Manejo intensivo — rotación de potreros',
    description:
        'En sistemas intensivos y semi-intensivos, la rotación de '
        'potreros es clave para: mantener la calidad del forraje, '
        'romper ciclos parasitarios, y optimizar la carga animal. '
        'Período de ocupación: 1-3 días. Período de descanso: '
        '28-42 días según especie forrajera y época. '
        'Evite sobrepastoreo (pasto <5 cm residual).',
    source: 'Pastoreo Racional Voisin — Manejo de Praderas',
  );
}

/// Doble propósito: balance entre leche y carne.
LivestockTip? _dualPurposeManagement(AnimalEntity animal) {
  if (animal.productionPurpose != ProductionPurpose.dual) return null;

  return const LivestockTip(
    category: TipCategory.production,
    severity: TipSeverity.info,
    title: 'Doble propósito — balance leche/carne',
    description:
        'En sistemas doble propósito, se debe equilibrar la '
        'producción de leche con el crecimiento del ternero. '
        'Estrategia amamantamiento restringido: ordeñe parcial '
        'por la mañana y deje el ternero con la madre el resto '
        'del día. Esto mantiene producción láctea comercial '
        'y permite buen crecimiento del ternero. '
        'Destete a los 7-9 meses según condición.',
    source: 'Ganadería Doble Propósito — Manejo Productivo',
  );
}

/// Evaluar si animal está listo para pasar a engorde.
LivestockTip? _finishingReadiness(AnimalEntity animal) {
  if (animal.productionStage == ProductionStage.finishing) return null;
  if (animal.productionPurpose != ProductionPurpose.meat) return null;
  if (animal.weight == null) return null;
  if (animal.species != Species.cattle) return null;

  // Bovinos de carne: peso de ingreso a engorde ~300 kg.
  if (animal.weight! < 280 || animal.weight! > 350) return null;

  return LivestockTip(
    category: TipCategory.production,
    severity: TipSeverity.info,
    title:
        'Peso para ingreso a engorde (${animal.weight!.toStringAsFixed(0)} kg)',
    description:
        'Este animal pesa ${animal.weight!.toStringAsFixed(0)} kg, '
        'dentro del rango ideal para ingresar a etapa de engorde '
        '(280-350 kg en bovinos de carne). Si aún no está en '
        'etapa de engorde, considere iniciar el protocolo de '
        'finalización. Antes de iniciar: desparasite, vacune, '
        'y realice un período de adaptación a la dieta de corral.',
    source: 'Engorde Bovino — Criterios de Ingreso a Corral',
  );
}

/// Animal en etapa ociosa: revisar clasificación.
LivestockTip? _idleStageReview(AnimalEntity animal) {
  if (animal.productionStage != ProductionStage.idle) return null;

  return const LivestockTip(
    category: TipCategory.production,
    severity: TipSeverity.info,
    title: 'Etapa productiva sin definir',
    description:
        'Este animal está en etapa productiva "inactiva". Revise '
        'si debe reclasificarse según su edad, peso y propósito: '
        'cría (nacimiento-destete), recría/levante (destete-servicio '
        'o engorde), engorde (finalización), o producción '
        '(lactancia, reproducción activa). '
        'Un animal sin etapa definida no recibe manejo diferenciado.',
    source: 'Clasificación de Etapas Productivas del Hato',
  );
}
