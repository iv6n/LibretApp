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
  final bool? onlyUnsynchronized;

  const LoadAnimals({this.onlyUnsynchronized});

  @override
  List<Object?> get props => [onlyUnsynchronized];
}

class AddAnimal extends AnimalEvent {
  final AnimalEntity animal;

  const AddAnimal(this.animal);

  @override
  List<Object?> get props => [animal];
}

class UpdateAnimal extends AnimalEvent {
  final AnimalEntity animal;

  const UpdateAnimal(this.animal);

  @override
  List<Object?> get props => [animal];
}

class SelectAnimal extends AnimalEvent {
  final String animalUuid;

  const SelectAnimal(this.animalUuid);

  @override
  List<Object?> get props => [animalUuid];
}

class MarkAnimalAsSynced extends AnimalEvent {
  final String animalUuid;
  final String remoteId;

  const MarkAnimalAsSynced(this.animalUuid, this.remoteId);

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
  final String animalUuid;
  final WeightRecord record;

  const AddWeightRecord({required this.animalUuid, required this.record});

  @override
  List<Object?> get props => [animalUuid, record];
}

class AddReproductionRecord extends AnimalEvent {
  final String animalUuid;
  final ReproductionRecord record;

  const AddReproductionRecord({required this.animalUuid, required this.record});

  @override
  List<Object?> get props => [animalUuid, record];
}

class AddProductionRecord extends AnimalEvent {
  final String animalUuid;
  final ProductionRecord record;

  const AddProductionRecord({required this.animalUuid, required this.record});

  @override
  List<Object?> get props => [animalUuid, record];
}

class AddHealthRecord extends AnimalEvent {
  final String animalUuid;
  final HealthRecord record;

  const AddHealthRecord({required this.animalUuid, required this.record});

  @override
  List<Object?> get props => [animalUuid, record];
}

class AddCommercialRecord extends AnimalEvent {
  final String animalUuid;
  final CommercialRecord record;

  const AddCommercialRecord({required this.animalUuid, required this.record});

  @override
  List<Object?> get props => [animalUuid, record];
}

class AddMovementRecord extends AnimalEvent {
  final String animalUuid;
  final MovementRecord record;

  const AddMovementRecord({required this.animalUuid, required this.record});

  @override
  List<Object?> get props => [animalUuid, record];
}

class AddCostRecord extends AnimalEvent {
  final String animalUuid;
  final CostRecord record;

  const AddCostRecord({required this.animalUuid, required this.record});

  @override
  List<Object?> get props => [animalUuid, record];
}

class AssignAnimalToBatch extends AnimalEvent {
  final String animalUuid;
  final String? batchUuid; // null to unassign

  const AssignAnimalToBatch({
    required this.animalUuid,
    required this.batchUuid,
  });

  @override
  List<Object?> get props => [animalUuid, batchUuid];
}
