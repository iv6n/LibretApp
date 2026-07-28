/// core › advisor › rules › nutrition_rules — rules that generate nutrition-related advisor tips.
library;

import 'package:libretapp/core/advisor/livestock_tip.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/life_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_purpose.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/reproductive_status.dart';

/// Reglas de la biblia ganadera aplicables a nutrición.
///
/// Se evalúan de forma general sobre el estado actual del animal,
/// no requieren un registro específico — se muestran al consultar
/// el perfil del animal o al registrar cambios de peso/alimentación.
List<LivestockTip> evaluateNutritionRules(AnimalEntity animal) {
  return [
    _bodyConditionAlert(animal),
    _calfNutrition(animal),
    _pregnantCowNutrition(animal),
    _lactatingCowNutrition(animal),
    _feedTransitionAdvice(animal),
    _mineralSupplementation(animal),
    _fatteningNutrition(animal),
  ].whereType<LivestockTip>().toList();
}

/// Condición corporal baja o muy baja.
LivestockTip? _bodyConditionAlert(AnimalEntity animal) {
  if (animal.bodyConditionScore == null) {
    return const LivestockTip(
      category: TipCategory.nutrition,
      severity: TipSeverity.info,
      title: 'Sin registro de condición corporal',
      description:
          'No hay registro de condición corporal (CC) para este animal. '
          'La CC es una herramienta fundamental para evaluar el estado '
          'nutricional. Evalúe visualmente y por palpación en escala 1-5: '
          '1 (emaciado), 2 (flaco), 3 (ideal), 4 (gordo), 5 (obeso). '
          'Registre periódicamente para detectar tendencias.',
      source: 'Evaluación de Condición Corporal — Escala 1-5',
    );
  }

  if (animal.bodyConditionScore! >= 3) return null;

  return LivestockTip(
    category: TipCategory.nutrition,
    severity: animal.bodyConditionScore! <= 1
        ? TipSeverity.critical
        : TipSeverity.warning,
    title: 'Condición corporal baja (${animal.bodyConditionScore}/5)',
    description:
        'CC de ${animal.bodyConditionScore}/5 indica déficit nutricional. '
        '${animal.bodyConditionScore! <= 1 ? "Requiere intervención inmediata: suplementación energética y proteica de emergencia. " : ""}'
        'Aumente la oferta forrajera y considere suplementar con '
        'concentrado energético (maíz, sorgo) y fuente proteica '
        '(harina de soya, semilla de algodón). Recuperar un punto '
        'de CC toma 60-90 días con buena alimentación.',
    source: 'Nutrición Bovina — Recuperación de Condición Corporal',
  );
}

/// Nutrición de crías: destete y transición.
LivestockTip? _calfNutrition(AnimalEntity animal) {
  if (animal.lifeStage != LifeStage.calf &&
      animal.lifeStage != LifeStage.calfMale &&
      animal.lifeStage != LifeStage.calfFemale) {
    return null;
  }

  if (animal.ageMonths > 10) return null;

  return LivestockTip(
    category: TipCategory.nutrition,
    severity: TipSeverity.info,
    title: 'Nutrición de cría — ${animal.ageMonths} meses',
    description:
        'Cría de ${animal.ageMonths} meses. '
        '${animal.ageMonths < 3 ? "A esta edad, la leche materna es la principal fuente nutricional. Inicie oferta de forraje de calidad (heno fino) para estimular el desarrollo ruminal. " : ""}'
        '${animal.ageMonths >= 3 && animal.ageMonths <= 6 ? "Etapa crítica de desarrollo ruminal. Ofrezca concentrado iniciador (creep feeding) y forraje de calidad. El destete puede realizarse a los 6-8 meses si pesa ≥180 kg (bovinos). " : ""}'
        '${animal.ageMonths > 6 ? "Post-destete: momento de mayor estrés nutricional. Mantenga dieta de alta calidad con 14-16% proteína cruda. Evite cambios bruscos de alimentación." : ""}',
    source: 'Alimentación de Terneros — Desarrollo Ruminal y Destete',
  );
}

/// Vaca gestante: requerimientos del último tercio.
LivestockTip? _pregnantCowNutrition(AnimalEntity animal) {
  if (animal.reproductiveStatus != ReproductiveStatus.pregnant) return null;
  if (animal.expectedCalvingDate == null) return null;

  final daysToCalving = animal.expectedCalvingDate!
      .difference(DateTime.now())
      .inDays;
  if (daysToCalving > 90 || daysToCalving < 0) return null;

  return const LivestockTip(
    category: TipCategory.nutrition,
    severity: TipSeverity.warning,
    title: 'Último tercio de gestación — aumentar nutrición',
    description:
        'En el último tercio de gestación, el 70% del crecimiento '
        'fetal ocurre en este período. Los requerimientos energéticos '
        'aumentan 30-50%. Asegure forraje de calidad, suplementación '
        'proteica y minerales (Ca, P, Se, Vitaminas A-D-E). '
        'La subnutrición en esta etapa causa terneros débiles, '
        'menor producción de calostro y mayor intervalo hasta '
        'el primer celo post-parto.',
    source: 'Nutrición de la Vaca Gestante — Último Tercio',
  );
}

/// Vaca lactante: alta demanda energética.
LivestockTip? _lactatingCowNutrition(AnimalEntity animal) {
  if (animal.reproductiveStatus != ReproductiveStatus.lactating) return null;

  return const LivestockTip(
    category: TipCategory.nutrition,
    severity: TipSeverity.info,
    title: 'Vaca en lactación — alta demanda nutricional',
    description:
        'La lactación es el estado fisiológico de mayor demanda '
        'energética. Una vaca lactante necesita el doble de energía '
        'que una seca. El balance energético negativo es normal '
        'las primeras 8-10 semanas pero no debe ser excesivo. '
        'Asegure: forraje de calidad ad libitum, suplemento energético '
        'y proteico, y agua limpia abundante (60-80 litros/día).',
    source: 'Nutrición de la Vaca Lechera — Balance Energético',
  );
}

/// Consejo general de transición alimenticia.
LivestockTip? _feedTransitionAdvice(AnimalEntity animal) {
  if (animal.feedType == null || animal.feedType!.isEmpty) return null;

  return const LivestockTip(
    category: TipCategory.nutrition,
    severity: TipSeverity.info,
    title: 'Cambios de dieta graduales',
    description:
        'Todo cambio de alimentación debe ser gradual (7-14 días). '
        'La flora ruminal necesita adaptarse al nuevo sustrato. '
        'Cambios bruscos causan acidosis ruminal (exceso de grano), '
        'timpanismo (exceso de leguminosas frescas), o pérdida '
        'de condición. Mezcle progresivamente la nueva dieta '
        'con la anterior en proporciones crecientes.',
    source: 'Nutrición de Rumiantes — Adaptación Ruminal',
  );
}

/// Suplementación mineral: período crítico.
LivestockTip? _mineralSupplementation(AnimalEntity animal) {
  if (animal.productionPurpose == ProductionPurpose.undefined) return null;

  return const LivestockTip(
    category: TipCategory.nutrition,
    severity: TipSeverity.info,
    title: 'Suplementación mineral continua',
    description:
        'Los minerales críticos en ganadería son: Fósforo (P) — '
        'deficiente en pasturas tropicales; Calcio (Ca) — clave en '
        'lactación; Cobre (Cu) y Zinc (Zn) — inmunidad y fertilidad; '
        'Selenio (Se) — antioxidante, previene músculo blanco en crías. '
        'Ofrezca sal mineralizada ad libitum todo el año. '
        'Calcule 60-80 g/animal/día de consumo esperado.',
    source: 'Mineralización del Ganado — Macro y Microminerales',
  );
}

/// Engorde: protocolo nutricional.
LivestockTip? _fatteningNutrition(AnimalEntity animal) {
  if (animal.productionStage != ProductionStage.finishing) return null;

  return const LivestockTip(
    category: TipCategory.production,
    severity: TipSeverity.info,
    title: 'Protocolo de engorde',
    description:
        'En etapa de engorde, el objetivo es maximizar la ganancia '
        'de peso diaria (GDP). Dieta típica de finalización: '
        '70-80% concentrado energético + 20-30% forraje. '
        'GDP esperada: 1.0-1.5 kg/día en corral. Monitoree '
        'consumo de materia seca (2.5-3% del peso vivo). '
        'Acidosis es el principal riesgo — adapte gradualmente '
        'al grano (21 días mínimo).',
    source: 'Engorde Intensivo — Protocolo de Finalización',
  );
}
