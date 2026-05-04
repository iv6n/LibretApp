/// features \u203a directorio \u203a animales \u203a application \u203a bloc \u203a animal_event \u2014 events for AnimalBloc.
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/commercial_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/cost_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/movement_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/production_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/weight_record.dart';

abstract class AnimalEvent extends Equatable {
  const AnimalEvent();
}

class LoadAnimals extends AnimalEvent {
  const LoadAnimals({this.onlyUnsynchronized});
  final bool? onlyUnsynchronized;

  @override
  List<Object?> get props => [onlyUnsynchronized];
}

class AddAnimal extends AnimalEvent {
  const AddAnimal(this.animal);
  final AnimalEntity animal;

  @override
  List<Object?> get props => [animal];
}

class UpdateAnimal extends AnimalEvent {
  const UpdateAnimal(this.animal);
  final AnimalEntity animal;

  @override
  List<Object?> get props => [animal];
}

class SelectAnimal extends AnimalEvent {
  const SelectAnimal(this.animalUuid);
  final String animalUuid;

  @override
  List<Object?> get props => [animalUuid];
}

class MarkAnimalAsSynced extends AnimalEvent {
  const MarkAnimalAsSynced(this.animalUuid, this.remoteId);
  final String animalUuid;
  final String remoteId;

  @override
  List<Object?> get props => [animalUuid, remoteId];
}

class FetchUnsynchronizedAnimals extends AnimalEvent {
  const FetchUnsynchronizedAnimals();

  @override
  List<Object?> get props => [];
}

class ClearSelection extends AnimalEvent {
  const ClearSelection();

  @override
  List<Object?> get props => [];
}

class AddWeightRecord extends AnimalEvent {
  const AddWeightRecord({required this.animalUuid, required this.record});
  final String animalUuid;
  final WeightRecord record;

  @override
  List<Object?> get props => [animalUuid, record];
}

class AddReproductionRecord extends AnimalEvent {
  const AddReproductionRecord({required this.animalUuid, required this.record});
  final String animalUuid;
  final ReproductionRecord record;

  @override
  List<Object?> get props => [animalUuid, record];
}

class AddProductionRecord extends AnimalEvent {
  const AddProductionRecord({required this.animalUuid, required this.record});
  final String animalUuid;
  final ProductionRecord record;

  @override
  List<Object?> get props => [animalUuid, record];
}

class AddHealthRecord extends AnimalEvent {
  const AddHealthRecord({required this.animalUuid, required this.record});
  final String animalUuid;
  final HealthRecord record;

  @override
  List<Object?> get props => [animalUuid, record];
}

class AddCommercialRecord extends AnimalEvent {
  const AddCommercialRecord({required this.animalUuid, required this.record});
  final String animalUuid;
  final CommercialRecord record;

  @override
  List<Object?> get props => [animalUuid, record];
}

class AddMovementRecord extends AnimalEvent {
  const AddMovementRecord({required this.animalUuid, required this.record});
  final String animalUuid;
  final MovementRecord record;

  @override
  List<Object?> get props => [animalUuid, record];
}

class AddCostRecord extends AnimalEvent {
  const AddCostRecord({required this.animalUuid, required this.record});
  final String animalUuid;
  final CostRecord record;

  @override
  List<Object?> get props => [animalUuid, record];
}

class AssignAnimalToBatch extends AnimalEvent {
  // null to unassign

  const AssignAnimalToBatch({
    required this.animalUuid,
    required this.batchUuid,
  });
  final String animalUuid;
  final String? batchUuid;

  @override
  List<Object?> get props => [animalUuid, batchUuid];
}
