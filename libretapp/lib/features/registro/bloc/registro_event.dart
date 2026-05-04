/// registro › bloc › RegistroEvent
///
/// Sealed event hierarchy for [RegistroBloc]. One submit event per record
/// type handled in the registro feature, plus [RegistroReset].
///
/// Layer: application (state management)
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/commercial_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/cost_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/production_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/weight_record.dart';

/// Base class for all registro events.
sealed class RegistroEvent extends Equatable {
  const RegistroEvent();
}

/// Persists a [WeightRecord] for the animal identified by [animalUuid].
final class RegistroPesoSubmitted extends RegistroEvent {
  const RegistroPesoSubmitted({required this.animalUuid, required this.record});

  final String animalUuid;
  final WeightRecord record;

  @override
  List<Object?> get props => [animalUuid, record];
}

/// Persists a [HealthRecord] (vaccine, treatment, etc.) for [animalUuid].
final class RegistroSanitarioSubmitted extends RegistroEvent {
  const RegistroSanitarioSubmitted({
    required this.animalUuid,
    required this.record,
  });

  final String animalUuid;
  final HealthRecord record;

  @override
  List<Object?> get props => [animalUuid, record];
}

/// Persists a [ProductionRecord] for [animalUuid].
final class RegistroProduccionSubmitted extends RegistroEvent {
  const RegistroProduccionSubmitted({
    required this.animalUuid,
    required this.record,
  });

  final String animalUuid;
  final ProductionRecord record;

  @override
  List<Object?> get props => [animalUuid, record];
}

/// Persists a [ReproductionRecord] for [animalUuid].
final class RegistroReproduccionSubmitted extends RegistroEvent {
  const RegistroReproduccionSubmitted({
    required this.animalUuid,
    required this.record,
  });

  final String animalUuid;
  final ReproductionRecord record;

  @override
  List<Object?> get props => [animalUuid, record];
}

/// Persists a [CommercialRecord] (purchase, sale, etc.) for [animalUuid].
final class RegistroComercialSubmitted extends RegistroEvent {
  const RegistroComercialSubmitted({
    required this.animalUuid,
    required this.record,
  });

  final String animalUuid;
  final CommercialRecord record;

  @override
  List<Object?> get props => [animalUuid, record];
}

/// Persists a [MovementRecord] (location transfer) for [animalUuid].
final class RegistroMovimientoSubmitted extends RegistroEvent {
  const RegistroMovimientoSubmitted({
    required this.animalUuid,
    required this.record,
  });

  final String animalUuid;
  final MovementRecord record;

  @override
  List<Object?> get props => [animalUuid, record];
}

/// Persists a [CostRecord] (medication, feed, etc.) for [animalUuid].
final class RegistroCostoSubmitted extends RegistroEvent {
  const RegistroCostoSubmitted({
    required this.animalUuid,
    required this.record,
  });

  final String animalUuid;
  final CostRecord record;

  @override
  List<Object?> get props => [animalUuid, record];
}

/// Resets [RegistroState] back to idle after a success or failure.
///
/// Form pages dispatch this after reacting to the result so the BLoC
/// does not emit the same terminal state on a hot rebuild.
final class RegistroReset extends RegistroEvent {
  const RegistroReset();

  @override
  List<Object?> get props => [];
}
