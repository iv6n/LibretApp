import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/directorio/lotes/bloc/lotes_event.dart';
import 'package:libretapp/features/directorio/lotes/bloc/lotes_state.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';

class LotesBloc extends Bloc<LotesEvent, LotesState> {
  LotesBloc(this.repository) : super(const LotesInitial()) {
    on<LoadLotes>(_onLoadLotes);
    on<LotesStreamUpdated>(_onStreamUpdated);
    on<LotesStreamFailed>(_onStreamFailed);
    on<CreateLote>(_onCreateLote);
    on<UpdateLote>(_onUpdateLote);
    on<DeleteLote>(_onDeleteLote);
    on<AddAnimalToLote>(_onAddAnimalToLote);
    on<AddAnimalsToLote>(_onAddAnimalsToLote);
    on<RemoveAnimalFromLote>(_onRemoveAnimalFromLote);
    on<RemoveAnimalsFromLote>(_onRemoveAnimalsFromLote);
    on<CloseLote>(_onCloseLote);
    on<ReopenLote>(_onReopenLote);
  }
  final LotesRepository repository;

  StreamSubscription<List<LoteEntity>>? _subscription;

  /// Carga los lotes desde el repositorio
  Future<void> _onLoadLotes(LoadLotes event, Emitter<LotesState> emit) async {
    _emitIfActive(emit, const LotesLoading());
    try {
      await _subscription?.cancel();
      _subscription = repository.watchAll().listen(
        (lotes) => add(LotesStreamUpdated(lotes)),
        onError: (error, _) {
          if (!isClosed) {
            add(LotesStreamFailed(error.toString()));
          }
        },
      );
    } catch (e) {
      _emitIfActive(emit, LotesError('Error al cargar lotes: $e'));
    }
  }

  /// Maneja la actualización del stream de lotes
  void _onStreamUpdated(LotesStreamUpdated event, Emitter<LotesState> emit) {
    _emitIfActive(emit, LotesLoaded(lotes: event.lotes));
  }

  /// Maneja errores del stream de lotes
  void _onStreamFailed(LotesStreamFailed event, Emitter<LotesState> emit) {
    _emitIfActive(emit, LotesError(event.error));
  }

  void _emitErrorAndRestore(
    Emitter<LotesState> emit,
    String message,
    List<LoteEntity> lotes,
  ) {
    _emitIfActive(emit, LotesError(message));
    _emitIfActive(emit, LotesLoaded(lotes: lotes));
  }

  void _emitIfActive(Emitter<LotesState> emit, LotesState nextState) {
    if (emit.isDone || isClosed) return;
    emit(nextState);
  }

  /// Crea un nuevo lote
  Future<void> _onCreateLote(CreateLote event, Emitter<LotesState> emit) async {
    final currentState = state;
    if (currentState is! LotesLoaded) return;

    _emitIfActive(
      emit,
      LotesActionInProgress(
        action: 'Creando lote...',
        lotes: currentState.lotes,
      ),
    );

    try {
      final newLote = await repository.createLote(
        nombre: event.nombre,
        descripcion: event.descripcion,
        notas: event.notas,
      );

      final updatedLotes = [...currentState.lotes, newLote];
      _emitIfActive(
        emit,
        LotesActionSuccess(
          action: 'create',
          lotes: updatedLotes,
          message: 'Lote "${event.nombre}" creado exitosamente',
        ),
      );

      _emitIfActive(emit, LotesLoaded(lotes: updatedLotes));
    } catch (e) {
      _emitErrorAndRestore(emit, 'Error al crear lote: $e', currentState.lotes);
    }
  }

  /// Actualiza un lote existente
  Future<void> _onUpdateLote(UpdateLote event, Emitter<LotesState> emit) async {
    final currentState = state;
    if (currentState is! LotesLoaded) return;

    _emitIfActive(
      emit,
      LotesActionInProgress(
        action: 'Actualizando lote...',
        lotes: currentState.lotes,
      ),
    );

    try {
      await repository.updateLote(event.lote);

      final updatedLotes = currentState.lotes
          .map((l) => l.uuid == event.lote.uuid ? event.lote : l)
          .toList();

      _emitIfActive(
        emit,
        LotesActionSuccess(
          action: 'update',
          lotes: updatedLotes,
          message: 'Lote actualizado exitosamente',
        ),
      );

      _emitIfActive(emit, LotesLoaded(lotes: updatedLotes));
    } catch (e) {
      _emitErrorAndRestore(
        emit,
        'Error al actualizar lote: $e',
        currentState.lotes,
      );
    }
  }

  /// Elimina un lote
  Future<void> _onDeleteLote(DeleteLote event, Emitter<LotesState> emit) async {
    final currentState = state;
    if (currentState is! LotesLoaded) return;

    _emitIfActive(
      emit,
      LotesActionInProgress(
        action: 'Eliminando lote...',
        lotes: currentState.lotes,
      ),
    );

    try {
      await repository.deleteLote(event.uuid);

      final updatedLotes = currentState.lotes
          .where((l) => l.uuid != event.uuid)
          .toList();

      _emitIfActive(
        emit,
        LotesActionSuccess(
          action: 'delete',
          lotes: updatedLotes,
          message: 'Lote eliminado exitosamente',
        ),
      );

      _emitIfActive(emit, LotesLoaded(lotes: updatedLotes));
    } catch (e) {
      _emitErrorAndRestore(
        emit,
        'Error al eliminar lote: $e',
        currentState.lotes,
      );
    }
  }

  /// Agrega un animal a un lote
  Future<void> _onAddAnimalToLote(
    AddAnimalToLote event,
    Emitter<LotesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! LotesLoaded) return;

    try {
      final lote = currentState.lotes.firstWhere(
        (l) => l.uuid == event.loteUuid,
      );

      // Evitar duplicados
      final animalUuids = {...lote.animalUuids, event.animalUuid}.toList();

      final updatedLote = lote.copyWith(animalUuids: animalUuids);
      await repository.updateLote(updatedLote);

      final updatedLotes = currentState.lotes
          .map((l) => l.uuid == event.loteUuid ? updatedLote : l)
          .toList();

      _emitIfActive(emit, LotesLoaded(lotes: updatedLotes));
    } catch (e) {
      _emitErrorAndRestore(
        emit,
        'Error al agregar animal al lote: $e',
        currentState.lotes,
      );
    }
  }

  /// Agrega múltiples animales a un lote
  Future<void> _onAddAnimalsToLote(
    AddAnimalsToLote event,
    Emitter<LotesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! LotesLoaded) return;

    _emitIfActive(
      emit,
      LotesActionInProgress(
        action: 'Agregando animales al lote...',
        lotes: currentState.lotes,
      ),
    );

    try {
      final lote = currentState.lotes.firstWhere(
        (l) => l.uuid == event.loteUuid,
      );

      // Evitar duplicados
      final animalUuids = {...lote.animalUuids, ...event.animalUuids}.toList();

      final updatedLote = lote.copyWith(animalUuids: animalUuids);
      await repository.updateLote(updatedLote);

      final updatedLotes = currentState.lotes
          .map((l) => l.uuid == event.loteUuid ? updatedLote : l)
          .toList();

      _emitIfActive(
        emit,
        LotesActionSuccess(
          action: 'addAnimals',
          lotes: updatedLotes,
          message: '${event.animalUuids.length} animal(es) agregado(s) al lote',
        ),
      );

      _emitIfActive(emit, LotesLoaded(lotes: updatedLotes));
    } catch (e) {
      _emitErrorAndRestore(
        emit,
        'Error al agregar animales al lote: $e',
        currentState.lotes,
      );
    }
  }

  /// Remueve un animal de un lote
  Future<void> _onRemoveAnimalFromLote(
    RemoveAnimalFromLote event,
    Emitter<LotesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! LotesLoaded) return;

    try {
      final lote = currentState.lotes.firstWhere(
        (l) => l.uuid == event.loteUuid,
      );

      final animalUuids = lote.animalUuids
          .where((uuid) => uuid != event.animalUuid)
          .toList();

      final updatedLote = lote.copyWith(animalUuids: animalUuids);
      await repository.updateLote(updatedLote);

      final updatedLotes = currentState.lotes
          .map((l) => l.uuid == event.loteUuid ? updatedLote : l)
          .toList();

      _emitIfActive(emit, LotesLoaded(lotes: updatedLotes));
    } catch (e) {
      _emitErrorAndRestore(
        emit,
        'Error al remover animal del lote: $e',
        currentState.lotes,
      );
    }
  }

  /// Remueve múltiples animales de un lote
  Future<void> _onRemoveAnimalsFromLote(
    RemoveAnimalsFromLote event,
    Emitter<LotesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! LotesLoaded) return;

    _emitIfActive(
      emit,
      LotesActionInProgress(
        action: 'Removiendo animales del lote...',
        lotes: currentState.lotes,
      ),
    );

    try {
      final lote = currentState.lotes.firstWhere(
        (l) => l.uuid == event.loteUuid,
      );

      final animalUuidsSet = event.animalUuids.toSet();
      final animalUuids = lote.animalUuids
          .where((uuid) => !animalUuidsSet.contains(uuid))
          .toList();

      final updatedLote = lote.copyWith(animalUuids: animalUuids);
      await repository.updateLote(updatedLote);

      final updatedLotes = currentState.lotes
          .map((l) => l.uuid == event.loteUuid ? updatedLote : l)
          .toList();

      _emitIfActive(
        emit,
        LotesActionSuccess(
          action: 'removeAnimals',
          lotes: updatedLotes,
          message:
              '${event.animalUuids.length} animal(es) removido(s) del lote',
        ),
      );

      _emitIfActive(emit, LotesLoaded(lotes: updatedLotes));
    } catch (e) {
      _emitErrorAndRestore(
        emit,
        'Error al remover animales del lote: $e',
        currentState.lotes,
      );
    }
  }

  /// Cierra un lote (lo marca como inactivo)
  Future<void> _onCloseLote(CloseLote event, Emitter<LotesState> emit) async {
    final currentState = state;
    if (currentState is! LotesLoaded) return;

    try {
      final lote = currentState.lotes.firstWhere((l) => l.uuid == event.uuid);

      final closedLote = lote.copyWith(
        activo: false,
        fechaCierre: DateTime.now(),
      );

      await repository.updateLote(closedLote);

      final updatedLotes = currentState.lotes
          .map((l) => l.uuid == event.uuid ? closedLote : l)
          .toList();

      _emitIfActive(emit, LotesLoaded(lotes: updatedLotes));
    } catch (e) {
      _emitErrorAndRestore(
        emit,
        'Error al cerrar lote: $e',
        currentState.lotes,
      );
    }
  }

  /// Reabre un lote (lo marca como activo nuevamente)
  Future<void> _onReopenLote(ReopenLote event, Emitter<LotesState> emit) async {
    final currentState = state;
    if (currentState is! LotesLoaded) return;

    try {
      final lote = currentState.lotes.firstWhere((l) => l.uuid == event.uuid);

      final reopenedLote = lote.copyWith(activo: true);

      await repository.updateLote(reopenedLote);

      final updatedLotes = currentState.lotes
          .map((l) => l.uuid == event.uuid ? reopenedLote : l)
          .toList();

      _emitIfActive(emit, LotesLoaded(lotes: updatedLotes));
    } catch (e) {
      _emitErrorAndRestore(
        emit,
        'Error al reabrir lote: $e',
        currentState.lotes,
      );
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
