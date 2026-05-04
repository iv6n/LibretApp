/// features \u203a directorio \u203a lotes \u203a bloc \u203a lotes_event \u2014 events for LotesBloc.
library;

import 'package:equatable/equatable.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';

abstract class LotesEvent extends Equatable {
  const LotesEvent();

  @override
  List<Object> get props => [];
}

/// Evento para cargar los lotes desde el repositorio
class LoadLotes extends LotesEvent {
  const LoadLotes({this.forceRefresh = false});

  final bool forceRefresh;

  @override
  List<Object> get props => [forceRefresh];
}

/// Evento para crear un nuevo lote
class CreateLote extends LotesEvent {
  const CreateLote({required this.nombre, this.descripcion, this.notas});

  final String nombre;
  final String? descripcion;
  final String? notas;

  @override
  List<Object> get props => [nombre, descripcion ?? '', notas ?? ''];
}

/// Evento para actualizar un lote existente
class UpdateLote extends LotesEvent {
  const UpdateLote(this.lote);

  final LoteEntity lote;

  @override
  List<Object> get props => [lote];
}

/// Evento para eliminar un lote
class DeleteLote extends LotesEvent {
  const DeleteLote(this.uuid);

  final String uuid;

  @override
  List<Object> get props => [uuid];
}

/// Evento para agregar un animal a un lote
class AddAnimalToLote extends LotesEvent {
  const AddAnimalToLote({required this.loteUuid, required this.animalUuid});

  final String loteUuid;
  final String animalUuid;

  @override
  List<Object> get props => [loteUuid, animalUuid];
}

/// Evento para agregar múltiples animales a un lote
class AddAnimalsToLote extends LotesEvent {
  const AddAnimalsToLote({required this.loteUuid, required this.animalUuids});

  final String loteUuid;
  final List<String> animalUuids;

  @override
  List<Object> get props => [loteUuid, animalUuids];
}

/// Evento para remover un animal de un lote
class RemoveAnimalFromLote extends LotesEvent {
  const RemoveAnimalFromLote({
    required this.loteUuid,
    required this.animalUuid,
  });

  final String loteUuid;
  final String animalUuid;

  @override
  List<Object> get props => [loteUuid, animalUuid];
}

/// Evento para remover múltiples animales de un lote
class RemoveAnimalsFromLote extends LotesEvent {
  const RemoveAnimalsFromLote({
    required this.loteUuid,
    required this.animalUuids,
  });

  final String loteUuid;
  final List<String> animalUuids;

  @override
  List<Object> get props => [loteUuid, animalUuids];
}

/// Evento cuando el stream de lotes se actualiza
class LotesStreamUpdated extends LotesEvent {
  const LotesStreamUpdated(this.lotes);

  final List<LoteEntity> lotes;

  @override
  List<Object> get props => [lotes];
}

/// Evento cuando el stream de lotes falla
class LotesStreamFailed extends LotesEvent {
  const LotesStreamFailed(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}

/// Evento para cerrar un lote (marcarlo como inactivo)
class CloseLote extends LotesEvent {
  const CloseLote(this.uuid);

  final String uuid;

  @override
  List<Object> get props => [uuid];
}

/// Evento para reabrir un lote (marcarlo como activo)
class ReopenLote extends LotesEvent {
  const ReopenLote(this.uuid);

  final String uuid;

  @override
  List<Object> get props => [uuid];
}
