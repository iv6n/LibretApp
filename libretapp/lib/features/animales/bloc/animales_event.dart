import 'package:equatable/equatable.dart';
import 'package:libretapp/features/animales/domain/entities/animal_entity.dart';

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
  final AnimalEntity animal;

  const AddAnimal(this.animal);

  @override
  List<Object> get props => [animal];
}

class UpdateAnimal extends AnimalesEvent {
  final AnimalEntity animal;

  const UpdateAnimal(this.animal);

  @override
  List<Object> get props => [animal];
}

class DeleteAnimal extends AnimalesEvent {
  final String id;

  const DeleteAnimal(this.id);

  @override
  List<Object> get props => [id];
}

class AssignAnimalLocationBatch extends AnimalesEvent {
  final String uuid;
  final String? locationId;
  final String? batchId;

  const AssignAnimalLocationBatch({
    required this.uuid,
    this.locationId,
    this.batchId,
  });

  @override
  List<Object> get props => [uuid, locationId ?? '', batchId ?? ''];
}

class RenameBatch extends AnimalesEvent {
  final String oldBatchId;
  final String newBatchId;

  const RenameBatch({required this.oldBatchId, required this.newBatchId});

  @override
  List<Object> get props => [oldBatchId, newBatchId];
}

class SearchAnimales extends AnimalesEvent {
  final String query;

  const SearchAnimales(this.query);

  @override
  List<Object> get props => [query];
}

class AnimalesStreamUpdated extends AnimalesEvent {
  final List<AnimalEntity> animales;

  const AnimalesStreamUpdated(this.animales);

  @override
  List<Object> get props => [animales];
}

class AnimalesStreamFailed extends AnimalesEvent {
  final String message;

  const AnimalesStreamFailed(this.message);

  @override
  List<Object> get props => [message];
}
