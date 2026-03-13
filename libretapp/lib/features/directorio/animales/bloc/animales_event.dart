import 'package:equatable/equatable.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';

abstract class AnimalesEvent extends Equatable {
  const AnimalesEvent();

  @override
  List<Object> get props => [];
}

class LoadAnimales extends AnimalesEvent {
  const LoadAnimales({this.forceRefresh = false});

  final bool forceRefresh;

  @override
  List<Object> get props => [forceRefresh];
}

class AddAnimal extends AnimalesEvent {
  const AddAnimal(this.animal);
  final AnimalEntity animal;

  @override
  List<Object> get props => [animal];
}

class UpdateAnimal extends AnimalesEvent {
  const UpdateAnimal(this.animal);
  final AnimalEntity animal;

  @override
  List<Object> get props => [animal];
}

class DeleteAnimal extends AnimalesEvent {
  const DeleteAnimal(this.id);
  final String id;

  @override
  List<Object> get props => [id];
}

class AssignAnimalLocationBatch extends AnimalesEvent {
  const AssignAnimalLocationBatch({
    required this.uuid,
    this.locationId,
    this.batchId,
  });
  final String uuid;
  final String? locationId;
  final String? batchId;

  @override
  List<Object> get props => [uuid, locationId ?? '', batchId ?? ''];
}

class RenameBatch extends AnimalesEvent {
  const RenameBatch({required this.oldBatchId, required this.newBatchId});
  final String oldBatchId;
  final String newBatchId;

  @override
  List<Object> get props => [oldBatchId, newBatchId];
}

class AnimalesStreamUpdated extends AnimalesEvent {
  const AnimalesStreamUpdated(this.animales);
  final List<AnimalEntity> animales;

  @override
  List<Object> get props => [animales];
}

class AnimalesStreamFailed extends AnimalesEvent {
  const AnimalesStreamFailed(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

class ToggleSearch extends AnimalesEvent {
  const ToggleSearch({required this.enabled});

  final bool enabled;

  @override
  List<Object> get props => [enabled];
}

class SearchQueryChanged extends AnimalesEvent {
  const SearchQueryChanged(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}

class ClearSearch extends AnimalesEvent {
  const ClearSearch();
}

class ToggleAnimalSelection extends AnimalesEvent {
  const ToggleAnimalSelection(this.animalUuid);

  final String animalUuid;

  @override
  List<Object> get props => [animalUuid];
}

class SelectAllVisibleAnimals extends AnimalesEvent {
  const SelectAllVisibleAnimals(this.visibleAnimalUuids);

  final List<String> visibleAnimalUuids;

  @override
  List<Object> get props => [visibleAnimalUuids];
}

class ClearAnimalSelection extends AnimalesEvent {
  const ClearAnimalSelection();
}
