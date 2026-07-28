/// core › advisor › rules › health_rules — rules that generate health-related advisor tips.
library;

import 'package:libretapp/core/advisor/livestock_tip.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/health_status.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/reproductive_status.dart';

/// Reglas de la biblia ganadera aplicables a registros de salud.
List<LivestockTip> evaluateHealthRules(
  AnimalEntity animal,
  HealthRecord record,
) {
  return [
    _vaccinationSchedule(animal, record),
    _dewormingInterval(animal, record),
    _pregnantAnimalTreatment(animal, record),
    _youngAnimalDosage(animal, record),
    _chronicAnimalAlert(animal),
    _criticalHealthFollowUp(animal, record),
    _diseaseIsolation(record),
    _vitaminSupplementation(animal, record),
  ].whereType<LivestockTip>().toList();
}

/// Calendario de vacunación: recordar refuerzos.
LivestockTip? _vaccinationSchedule(AnimalEntity animal, HealthRecord record) {
  if (record.type != HealthRecordType.vaccine) return null;

  return const LivestockTip(
    category: TipCategory.health,
    severity: TipSeverity.info,
    title: 'Calendario de vacunación',
    description:
        'Recuerde programar el refuerzo según el calendario sanitario. '
        'Vacunas clave para bovinos: Aftosa (semestral), Brucella '
        '(3-8 meses, solo hembras), Carbunclo (anual), Clostridiales '
        '(anual con refuerzo). Consulte el calendario oficial de su '
        'país y registre la fecha del próximo refuerzo.',
    source: 'Plan Sanitario Nacional — Calendario de Vacunación',
  );
}

/// Desparasitación: respetar intervalos mínimos.
LivestockTip? _dewormingInterval(AnimalEntity animal, HealthRecord record) {
  if (record.type != HealthRecordType.deworming) return null;

  return const LivestockTip(
    category: TipCategory.health,
    severity: TipSeverity.info,
    title: 'Intervalo de desparasitación',
    description:
        'La desparasitación excesiva genera resistencia parasitaria. '
        'Intervalo recomendado: cada 60-90 días en sistemas pastoriles, '
        'o según conteo de huevos fecales (HPG). Rote principios activos '
        '(ivermectina, albendazol, levamisol) para reducir resistencia. '
        'No desparasite animales debilitados sin supervisión veterinaria.',
    source: 'Control Parasitario Estratégico — Resistencia Antihelmíntica',
  );
}

/// Animal gestante: cuidado con productos y dosis.
LivestockTip? _pregnantAnimalTreatment(
  AnimalEntity animal,
  HealthRecord record,
) {
  if (animal.reproductiveStatus != ReproductiveStatus.pregnant) return null;
  if (record.type == HealthRecordType.checkup) return null;

  return const LivestockTip(
    category: TipCategory.reproduction,
    severity: TipSeverity.critical,
    title: 'Animal gestante — verificar contraindicaciones',
    description:
        'Este animal está gestante. Muchos productos veterinarios están '
        'contraindicados durante la gestación (ej: prostaglandinas, '
        'algunos antibióticos, corticoides). Consulte la etiqueta '
        'del producto y al veterinario antes de aplicar. '
        'Algunos antiparasitarios son abortivos en dosis altas.',
    source: 'Farmacología Veterinaria — Uso en Gestación',
  );
}

/// Crías jóvenes: ajustar dosis por peso.
LivestockTip? _youngAnimalDosage(AnimalEntity animal, HealthRecord record) {
  if (animal.ageMonths > 6) return null;
  if (record.type == HealthRecordType.checkup ||
      record.type == HealthRecordType.other) {
    return null;
  }

  return const LivestockTip(
    category: TipCategory.health,
    severity: TipSeverity.warning,
    title: 'Cría joven — ajustar dosis',
    description:
        'En animales menores de 6 meses, la dosis debe calcularse '
        'cuidadosamente por peso vivo. No estime el peso — use '
        'báscula o cinta bovinométrica. La sobredosificación en '
        'crías puede ser fatal. Algunos productos no están aprobados '
        'para animales menores a cierta edad.',
    source: 'Dosificación en Terneros — Guía de Productos',
  );
}

/// Animal con problemas crónicos: registro especial.
LivestockTip? _chronicAnimalAlert(AnimalEntity animal) {
  if (!animal.hasChronicIssues) return null;

  return LivestockTip(
    category: TipCategory.health,
    severity: TipSeverity.info,
    title: 'Animal con antecedentes crónicos',
    description:
        'Este animal tiene registrados problemas crónicos'
        '${animal.chronicNotes != null ? ": ${animal.chronicNotes}" : ""}. '
        'Considere posibles interacciones con tratamientos previos. '
        'Registre detalladamente el producto, dosis y reacción '
        'para mantener un historial completo.',
    source: 'Historial Clínico Ganadero — Seguimiento Crónico',
  );
}

/// Estado de salud crítico: seguimiento obligatorio.
LivestockTip? _criticalHealthFollowUp(
  AnimalEntity animal,
  HealthRecord record,
) {
  if (animal.healthStatus != HealthStatus.critical &&
      animal.healthStatus != HealthStatus.poor) {
    return null;
  }

  return const LivestockTip(
    category: TipCategory.health,
    severity: TipSeverity.critical,
    title: 'Salud comprometida — seguimiento necesario',
    description:
        'Este animal tiene estado de salud comprometido. Después de '
        'aplicar cualquier tratamiento, programe revisiones a las 24h, '
        '72h y 7 días. Si no muestra mejoría en 48-72h, considere '
        'cambio de protocolo o consulta veterinaria especializada. '
        'Aísle si hay sospecha de enfermedad contagiosa.',
    source: 'Protocolo de Atención a Animales Críticos',
  );
}

/// Enfermedad detectada: considerar aislamiento del rebaño.
LivestockTip? _diseaseIsolation(HealthRecord record) {
  if (record.type != HealthRecordType.disease) return null;

  return const LivestockTip(
    category: TipCategory.health,
    severity: TipSeverity.critical,
    title: 'Enfermedad — evaluar aislamiento',
    description:
        'Se registra una enfermedad. Evalúe si es contagiosa y '
        'si requiere aislamiento inmediato del rebaño. Revise '
        'animales que compartieron potrero en las últimas 2 semanas. '
        'Notifique al veterinario y, si es enfermedad de reporte '
        'obligatorio (aftosa, brucelosis, rabia), informe a las '
        'autoridades sanitarias.',
    source: 'Bioseguridad Ganadera — Manejo de Brotes',
  );
}

/// Suplementación vitamínica: calendario y necesidades.
LivestockTip? _vitaminSupplementation(
  AnimalEntity animal,
  HealthRecord record,
) {
  if (record.type != HealthRecordType.vitamins) return null;

  return const LivestockTip(
    category: TipCategory.nutrition,
    severity: TipSeverity.info,
    title: 'Suplementación vitamínica',
    description:
        'Las vitaminas A, D y E son las más deficientes en pastoreo. '
        'Vitamina A: esencial en sequía cuando el pasto pierde color '
        'verde. Vitamina E + Selenio: clave en terneros para prevenir '
        'enfermedad del músculo blanco. Aplicar preferiblemente al '
        'inicio de la época seca o cuando el forraje es de baja calidad.',
    source: 'Suplementación Mineral y Vitamínica en Bovinos',
  );
}
