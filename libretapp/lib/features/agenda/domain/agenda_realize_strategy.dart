/// features › agenda › domain › agenda_realize_strategy — maps a pending
/// task's categoría to how a batch of selected animals gets "realizada".
library;

import 'package:libretapp/features/agenda/domain/agenda_categoria.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';

enum AgendaRealizeStrategy {
  bulkHealth,
  bulkMovement,
  queuedReproduction,
  queuedWeight,
  none,
}

AgendaRealizeStrategy realizeStrategyForCategoria(AgendaCategoria categoria) =>
    switch (categoria) {
      AgendaCategoria.sanidad => AgendaRealizeStrategy.bulkHealth,
      AgendaCategoria.movimientos => AgendaRealizeStrategy.bulkMovement,
      AgendaCategoria.reproduccion => AgendaRealizeStrategy.queuedReproduction,
      AgendaCategoria.produccion => AgendaRealizeStrategy.queuedWeight,
      AgendaCategoria.administracion ||
      AgendaCategoria.otros => AgendaRealizeStrategy.none,
    };

/// Suggested starting [HealthRecordType] for a Sanidad `tipo` string, used to
/// pre-select the bulk health form's dropdown. Imprecise for casco/
/// veterinaria/cuidado (no matching enum value) — the dropdown stays
/// editable, so this is only a convenience default, not the final value.
HealthRecordType? healthRecordTypeForAgendaTipo(String tipo) =>
    switch (tipo.toLowerCase()) {
      'vacunación' => HealthRecordType.vaccine,
      'desparasitación' => HealthRecordType.deworming,
      'baño garrapaticida' => HealthRecordType.tickBath,
      'suplemento/vitaminas' => HealthRecordType.vitamins,
      'revisión de casco' || 'revisión veterinaria' => HealthRecordType.checkup,
      'cuidado' => HealthRecordType.other,
      _ => null,
    };
