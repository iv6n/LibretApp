import 'package:libretapp/core/advisor/livestock_tip.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/reproductive_status.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/sex.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';

/// Reglas de la biblia ganadera aplicables a eventos reproductivos.
List<LivestockTip> evaluateReproductionRules(
  AnimalEntity animal,
  ReproductionRecord record,
) {
  return [
    _youngAnimalService(animal),
    _serviceIntervalCheck(animal, record),
    _artificialInseminationTiming(animal, record),
    _pregnancyCheckReminder(record),
    _calvingPreparation(animal),
    _postPartumRecovery(animal),
    _consanguinityWarning(animal, record),
    _seasonalBreedingTip(animal, record),
    _bodyConditionForService(animal),
    _repeatedServiceFailure(animal, record),
  ].whereType<LivestockTip>().toList();
}

/// Hembra muy joven para servicio.
LivestockTip? _youngAnimalService(AnimalEntity animal) {
  if (animal.sex != Sex.female) return null;
  if (animal.ageMonths >= 15) return null; // Edad mínima recomendada bovinos

  return LivestockTip(
    category: TipCategory.reproduction,
    severity: TipSeverity.critical,
    title: 'Animal joven — ${animal.ageMonths} meses',
    description:
        'Esta hembra tiene ${animal.ageMonths} meses. La edad mínima '
        'recomendada para el primer servicio en bovinos es 15 meses '
        '(o 60-65% del peso adulto). Servir hembras inmaduras causa '
        'partos distócicos, menor producción láctea y mayor intervalo '
        'entre partos. Consulte la tabla de pesos mínimos por raza.',
    source: 'Reproducción Bovina — Edad y Peso al Primer Servicio',
  );
}

/// Intervalo entre servicios: verificar que haya suficiente recuperación.
LivestockTip? _serviceIntervalCheck(
  AnimalEntity animal,
  ReproductionRecord record,
) {
  if (animal.lastServiceDate == null) return null;

  final daysSinceLastService = record.serviceDate
      .difference(animal.lastServiceDate!)
      .inDays;

  if (daysSinceLastService >= 21) return null; // Intervalo normal

  return LivestockTip(
    category: TipCategory.reproduction,
    severity: TipSeverity.warning,
    title: 'Servicio reciente — hace $daysSinceLastService días',
    description:
        'El último servicio fue hace solo $daysSinceLastService días. '
        'El ciclo estral bovino es de 18-24 días (promedio 21). '
        'Si se hace un nuevo servicio fuera de ciclo, la tasa de '
        'concepción será muy baja. Verifique que el animal '
        'está en celo real antes de servir.',
    source: 'Fisiología Reproductiva — Ciclo Estral Bovino',
  );
}

/// Inseminación artificial: horario óptimo.
LivestockTip? _artificialInseminationTiming(
  AnimalEntity animal,
  ReproductionRecord record,
) {
  if (record.serviceType != ServiceType.artificialInsemination) return null;

  return const LivestockTip(
    category: TipCategory.reproduction,
    severity: TipSeverity.info,
    title: 'Timing de inseminación artificial',
    description:
        'La regla AM-PM: si detecta celo en la mañana, inseminar en '
        'la tarde; si detecta celo en la tarde, inseminar en la mañana '
        'siguiente. El óvulo es fértil por 6-12 horas; los espermatozoides '
        'necesitan 6-8h de capacitación. El descongelamiento del semen '
        'debe seguir el protocolo: 35-37°C por 30-60 segundos.',
    source: 'Inseminación Artificial Bovina — Protocolo de Timing',
  );
}

/// Chequeo de preñez: recordar diagnóstico a los 30-45 días.
LivestockTip? _pregnancyCheckReminder(ReproductionRecord record) {
  if (record.pregnancyResult != null &&
      record.pregnancyResult != PregnancyCheckResult.notChecked) {
    return null;
  }

  final daysSinceService = DateTime.now().difference(record.serviceDate).inDays;

  if (daysSinceService < 28) {
    return LivestockTip(
      category: TipCategory.reproduction,
      severity: TipSeverity.info,
      title: 'Diagnóstico de preñez pendiente',
      description:
          'Servicio realizado hace $daysSinceService días. '
          'El diagnóstico de gestación por palpación rectal puede '
          'realizarse a partir de los 35-45 días post-servicio. '
          'Por ecografía se puede diagnosticar desde los 28-30 días. '
          'Programe el chequeo para confirmar la preñez.',
      source: 'Diagnóstico de Gestación — Métodos y Tiempos',
    );
  }

  return null;
}

/// Preparación para el parto: últimas semanas de gestación.
LivestockTip? _calvingPreparation(AnimalEntity animal) {
  if (animal.reproductiveStatus != ReproductiveStatus.pregnant) return null;
  if (animal.expectedCalvingDate == null) return null;

  final daysToCalving = animal.expectedCalvingDate!
      .difference(DateTime.now())
      .inDays;

  if (daysToCalving > 30 || daysToCalving < 0) return null;

  return LivestockTip(
    category: TipCategory.reproduction,
    severity: TipSeverity.warning,
    title: 'Parto próximo — $daysToCalving días',
    description:
        'Faltan aproximadamente $daysToCalving días para la fecha '
        'estimada de parto. Prepare el potrero de maternidad: '
        'limpio, con sombra, agua fresca y acceso fácil para '
        'observación. Tenga disponible kit obstétrico (lazos, '
        'guantes, desinfectante). Vigile signos de parto '
        '(relajación ligamentos, edema vulvar, inquietud).',
    source: 'Manejo Preparto — Preparación para la Parición',
  );
}

/// Post-parto: período de recuperación uterina.
LivestockTip? _postPartumRecovery(AnimalEntity animal) {
  if (animal.reproductiveStatus != ReproductiveStatus.lactating) return null;

  return const LivestockTip(
    category: TipCategory.reproduction,
    severity: TipSeverity.info,
    title: 'Período de espera voluntario',
    description:
        'Después del parto, respete el período de espera voluntario '
        'de 45-60 días antes de volver a servir. El útero necesita '
        'involución completa (30-45 días). Servir antes del día 45 '
        'reduce la tasa de concepción significativamente. '
        'Controle que no exista retención placentaria o metritis.',
    source: 'Reproducción Post-Parto — Involución Uterina',
  );
}

/// Consanguinidad: advertir si toro y vaca son del mismo hato sin registro.
LivestockTip? _consanguinityWarning(
  AnimalEntity animal,
  ReproductionRecord record,
) {
  if (record.serviceType != ServiceType.naturalService) return null;
  if (record.maleSireUuid == null || record.maleSireUuid!.isEmpty) {
    return const LivestockTip(
      category: TipCategory.reproduction,
      severity: TipSeverity.warning,
      title: 'Registrar identificación del toro',
      description:
          'No se registró la identificación del macho reproductor. '
          'Registrar el toro usado en cada monta es fundamental '
          'para evitar consanguinidad y hacer mejora genética. '
          'La consanguinidad causa menor fertilidad, menor peso '
          'al nacer, y mayor mortalidad de crías.',
      source: 'Mejoramiento Genético — Control de Consanguinidad',
    );
  }

  // Si el toro está en el mismo hato, advertir sobre genealogía.
  if (animal.sireUuid != null && animal.sireUuid == record.maleSireUuid) {
    return const LivestockTip(
      category: TipCategory.reproduction,
      severity: TipSeverity.critical,
      title: 'Posible consanguinidad directa',
      description:
          'El toro seleccionado coincide con el padre registrado de '
          'esta hembra. Cruzar padre con hija genera un 25% de '
          'consanguinidad, lo cual es inaceptable. Esto causa '
          'depresión endogámica: menor fertilidad, defectos '
          'congénitos y menor vigor. Use un toro no emparentado.',
      source: 'Genética Animal — Depresión Endogámica',
    );
  }

  return null;
}

/// Temporada de monta: considerar estacionalidad.
LivestockTip? _seasonalBreedingTip(
  AnimalEntity animal,
  ReproductionRecord record,
) {
  // Relevante principalmente para ovinos y caprinos (fotoperiódicos).
  if (animal.species != Species.sheep && animal.species != Species.goat) {
    return null;
  }

  final month = record.serviceDate.month;
  // Temporada natural de celo en ovejas/cabras: marzo-mayo (trópico)
  // y febrero-junio (zonas templadas del hemisferio sur).
  final isOffSeason = month >= 8 && month <= 12;

  if (!isOffSeason) return null;

  return const LivestockTip(
    category: TipCategory.reproduction,
    severity: TipSeverity.info,
    title: 'Fuera de temporada reproductiva natural',
    description:
        'Ovinos y caprinos son reproductores estacionales '
        '(fotoperiódicos, días cortos). Si está en contra-estación, '
        'considere protocolo hormonal de sincronización o el '
        '"efecto macho" (introducir machos 2-3 semanas antes). '
        'La tasa de concepción fuera de temporada es menor.',
    source: 'Reproducción de Pequeños Rumiantes — Estacionalidad',
  );
}

/// Condición corporal mínima para servicio.
LivestockTip? _bodyConditionForService(AnimalEntity animal) {
  if (animal.bodyConditionScore == null) return null;
  if (animal.bodyConditionScore! >= 3) return null; // Escala 1-5, ≥3 OK

  return LivestockTip(
    category: TipCategory.nutrition,
    severity: TipSeverity.warning,
    title: 'Condición corporal baja (${animal.bodyConditionScore}/5)',
    description:
        'Este animal tiene condición corporal ${animal.bodyConditionScore}/5. '
        'Para óptima fertilidad, se recomienda condición corporal ≥3 '
        'al momento del servicio. Hembras con CC baja tienen menores '
        'tasas de concepción y mayor mortalidad embrionaria temprana. '
        'Considere flushing nutricional 3-4 semanas antes del servicio.',
    source: 'Nutrición y Reproducción — Condición Corporal al Servicio',
  );
}

/// Servicios repetidos sin preñez: posible problema de fertilidad.
LivestockTip? _repeatedServiceFailure(
  AnimalEntity animal,
  ReproductionRecord record,
) {
  if (animal.reproductiveStatus != ReproductiveStatus.active) return null;
  if (animal.firstServiceDate == null || animal.lastServiceDate == null) {
    return null;
  }

  // Si hay más de 3 ciclos desde el primer servicio sin quedar preñada.
  final daysSinceFirstService = record.serviceDate
      .difference(animal.firstServiceDate!)
      .inDays;
  if (daysSinceFirstService < 63) return null; // 3 ciclos x 21 días

  return const LivestockTip(
    category: TipCategory.reproduction,
    severity: TipSeverity.warning,
    title: 'Múltiples servicios sin preñez',
    description:
        'Este animal lleva más de 3 ciclos estrales sin concebir. '
        'Las causas comunes incluyen: problemas ováricos (quistes), '
        'infecciones uterinas subclínicas, problemas del toro, '
        'o fallas en la detección de celo. Considere ecografía '
        'reproductiva, cambio de toro, y evaluación del tracto '
        'reproductivo. Si persiste, evalúe descarte.',
    source: 'Infertilidad Bovina — Vaca Repetidora',
  );
}
