import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/services/logger_service.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';

import 'animal_event.dart';
import 'animal_state.dart';

class AnimalBloc extends Bloc<AnimalEvent, AnimalState> {
  AnimalBloc({required this.animalRepository, required this.lotesRepository})
    : super(AnimalState.initial()) {
    on<LoadAnimals>(_onLoadAnimals);
    on<AddAnimal>(_onAddAnimal);
    on<UpdateAnimal>(_onUpdateAnimal);
    on<SelectAnimal>(_onSelectAnimal);
    on<MarkAnimalAsSynced>(_onMarkAnimalAsSynced);
    on<FetchUnsynchronizedAnimals>(_onFetchUnsynchronizedAnimals);
    on<ClearSelection>(_onClearSelection);
    on<AddWeightRecord>(_onAddWeightRecord);
    on<AddReproductionRecord>(_onAddReproductionRecord);
    on<AddProductionRecord>(_onAddProductionRecord);
    on<AddHealthRecord>(_onAddHealthRecord);
    on<AddCommercialRecord>(_onAddCommercialRecord);
    on<AddMovementRecord>(_onAddMovementRecord);
    on<AddCostRecord>(_onAddCostRecord);
    on<AssignAnimalToBatch>(_onAssignAnimalToBatch);
  }
  final AnimalRepository animalRepository;
  final LotesRepository lotesRepository;
  static const _logTag = 'AnimalBloc';

  Future<void> _onLoadAnimals(
    LoadAnimals event,
    Emitter<AnimalState> emit,
  ) async {
    LoggerService.d(
      'Cargar animales (solo no sincronizados: ${event.onlyUnsynchronized == true})',
      tag: _logTag,
    );
    try {
      emit(AnimalState.loading());
      final animals = event.onlyUnsynchronized == true
          ? await animalRepository.getUnsynchronized()
          : await animalRepository.getAll();
      emit(
        AnimalState.success(
          animals: animals,
          selectedAnimal: state.selectedAnimal,
        ),
      );
      LoggerService.i('Animales cargados: ${animals.length}', tag: _logTag);
    } catch (e, st) {
      LoggerService.e(
        'Error al cargar animales: $e',
        tag: _logTag,
        stackTrace: st,
      );
      emit(
        AnimalState.failure(
          message: 'Error al cargar animales: ${e.toString()}',
          animals: state.animals,
          selectedAnimal: state.selectedAnimal,
        ),
      );
    }
  }

  Future<void> _onAddAnimal(AddAnimal event, Emitter<AnimalState> emit) async {
    LoggerService.d('Agregar animal ${event.animal.uuid}', tag: _logTag);
    try {
      emit(AnimalState.loading());
      await animalRepository.save(event.animal);
      final updated = await animalRepository.getAll();
      emit(
        AnimalState.success(
          animals: updated,
          selectedAnimal: state.selectedAnimal,
        ),
      );
      LoggerService.i('Animal agregado ${event.animal.uuid}', tag: _logTag);
    } catch (e, st) {
      LoggerService.e(
        'Error al agregar animal: $e',
        tag: _logTag,
        stackTrace: st,
      );
      emit(
        AnimalState.failure(
          message: 'Error al agregar animal: ${e.toString()}',
          animals: state.animals,
          selectedAnimal: state.selectedAnimal,
        ),
      );
    }
  }

  Future<void> _onUpdateAnimal(
    UpdateAnimal event,
    Emitter<AnimalState> emit,
  ) async {
    LoggerService.d('Actualizar animal ${event.animal.uuid}', tag: _logTag);
    try {
      emit(AnimalState.loading());
      await animalRepository.update(event.animal);
      final updated = await animalRepository.getAll();
      final selected = state.selectedAnimal?.uuid == event.animal.uuid
          ? event.animal
          : state.selectedAnimal;
      emit(AnimalState.success(animals: updated, selectedAnimal: selected));
      LoggerService.i('Animal actualizado ${event.animal.uuid}', tag: _logTag);
    } catch (e, st) {
      LoggerService.e(
        'Error al actualizar animal: $e',
        tag: _logTag,
        stackTrace: st,
      );
      emit(
        AnimalState.failure(
          message: 'Error al actualizar animal: ${e.toString()}',
          animals: state.animals,
          selectedAnimal: state.selectedAnimal,
        ),
      );
    }
  }

  Future<void> _onSelectAnimal(
    SelectAnimal event,
    Emitter<AnimalState> emit,
  ) async {
    try {
      LoggerService.d('Seleccionar animal ${event.animalUuid}', tag: _logTag);
      final selected = state.animals.firstWhere(
        (animal) => animal.uuid == event.animalUuid,
        orElse: () =>
            throw Exception('Animal no encontrado: ${event.animalUuid}'),
      );
      emit(state.selectAnimal(selected));
      LoggerService.i('Animal seleccionado ${selected.uuid}', tag: _logTag);
    } catch (e, st) {
      LoggerService.e(
        'Error al seleccionar animal: $e',
        tag: _logTag,
        stackTrace: st,
      );
      emit(
        AnimalState.failure(
          message: 'Error al seleccionar animal: ${e.toString()}',
          animals: state.animals,
          selectedAnimal: state.selectedAnimal,
        ),
      );
    }
  }

  Future<void> _onMarkAnimalAsSynced(
    MarkAnimalAsSynced event,
    Emitter<AnimalState> emit,
  ) async {
    LoggerService.d(
      'Marcar animal ${event.animalUuid} como sincronizado con remoto ${event.remoteId}',
      tag: _logTag,
    );
    try {
      emit(AnimalState.loading());
      await animalRepository.markAsSynced(event.animalUuid, event.remoteId);
      final updated = await animalRepository.getAll();
      emit(
        AnimalState.success(
          animals: updated,
          selectedAnimal: state.selectedAnimal,
        ),
      );
      LoggerService.i('Animal sincronizado ${event.animalUuid}', tag: _logTag);
    } catch (e, st) {
      LoggerService.e(
        'Error al sincronizar animal: $e',
        tag: _logTag,
        stackTrace: st,
      );
      emit(
        AnimalState.failure(
          message: 'Error al sincronizar animal: ${e.toString()}',
          animals: state.animals,
          selectedAnimal: state.selectedAnimal,
        ),
      );
    }
  }

  Future<void> _onFetchUnsynchronizedAnimals(
    FetchUnsynchronizedAnimals event,
    Emitter<AnimalState> emit,
  ) async {
    LoggerService.d('Cargar animales pendientes de sincronizar', tag: _logTag);
    try {
      emit(AnimalState.loading());
      final unsynced = await animalRepository.getUnsynchronized();
      emit(
        AnimalState.success(
          animals: unsynced,
          selectedAnimal: state.selectedAnimal,
        ),
      );
      LoggerService.i(
        'Animales sin sincronizar: ${unsynced.length}',
        tag: _logTag,
      );
    } catch (e, st) {
      LoggerService.e(
        'Error al cargar animales sin sincronizar: $e',
        tag: _logTag,
        stackTrace: st,
      );
      emit(
        AnimalState.failure(
          message: 'Error al cargar animales sin sincronizar: ${e.toString()}',
          animals: state.animals,
          selectedAnimal: state.selectedAnimal,
        ),
      );
    }
  }

  Future<void> _onClearSelection(
    ClearSelection event,
    Emitter<AnimalState> emit,
  ) async {
    LoggerService.d('Limpiar selección de animal', tag: _logTag);
    emit(state.selectAnimal(null));
  }

  Future<void> _onAddWeightRecord(
    AddWeightRecord event,
    Emitter<AnimalState> emit,
  ) async {
    await _handleRecordOperation(
      emit,
      logAction: 'Agregar registro de peso para ${event.animalUuid}',
      operation: () =>
          animalRepository.addWeightRecord(event.animalUuid, event.record),
    );
  }

  Future<void> _onAddReproductionRecord(
    AddReproductionRecord event,
    Emitter<AnimalState> emit,
  ) async {
    await _handleRecordOperation(
      emit,
      logAction: 'Agregar evento reproductivo para ${event.animalUuid}',
      operation: () => animalRepository.addReproductionRecord(
        event.animalUuid,
        event.record,
      ),
    );
  }

  Future<void> _onAddProductionRecord(
    AddProductionRecord event,
    Emitter<AnimalState> emit,
  ) async {
    await _handleRecordOperation(
      emit,
      logAction: 'Agregar registro productivo para ${event.animalUuid}',
      operation: () =>
          animalRepository.addProductionRecord(event.animalUuid, event.record),
    );
  }

  Future<void> _onAddHealthRecord(
    AddHealthRecord event,
    Emitter<AnimalState> emit,
  ) async {
    await _handleRecordOperation(
      emit,
      logAction: 'Agregar registro sanitario para ${event.animalUuid}',
      operation: () =>
          animalRepository.addHealthRecord(event.animalUuid, event.record),
    );
  }

  Future<void> _onAddCommercialRecord(
    AddCommercialRecord event,
    Emitter<AnimalState> emit,
  ) async {
    await _handleRecordOperation(
      emit,
      logAction: 'Agregar registro comercial para ${event.animalUuid}',
      operation: () =>
          animalRepository.addCommercialRecord(event.animalUuid, event.record),
    );
  }

  Future<void> _onAddMovementRecord(
    AddMovementRecord event,
    Emitter<AnimalState> emit,
  ) async {
    await _handleRecordOperation(
      emit,
      logAction: 'Agregar movimiento para ${event.animalUuid}',
      operation: () =>
          animalRepository.addMovementRecord(event.animalUuid, event.record),
    );
  }

  Future<void> _onAddCostRecord(
    AddCostRecord event,
    Emitter<AnimalState> emit,
  ) async {
    await _handleRecordOperation(
      emit,
      logAction: 'Agregar costo para ${event.animalUuid}',
      operation: () =>
          animalRepository.addCostRecord(event.animalUuid, event.record),
    );
  }

  Future<void> _onAssignAnimalToBatch(
    AssignAnimalToBatch event,
    Emitter<AnimalState> emit,
  ) async {
    LoggerService.d(
      'Asignar animal ${event.animalUuid} a lote ${event.batchUuid}',
      tag: _logTag,
    );
    try {
      emit(AnimalState.loading());

      // Obtener el animal actual
      final animal = await animalRepository.getByUuid(event.animalUuid);
      if (animal == null) {
        throw Exception('Animal no encontrado: ${event.animalUuid}');
      }

      // Si el animal ya estaba en un lote, removerlo
      if (animal.batchUuid != null && animal.batchUuid != event.batchUuid) {
        await lotesRepository.removeAnimalFromLote(
          loteUuid: animal.batchUuid!,
          animalUuid: event.animalUuid,
        );
      }

      // Actualizar el animal con la nueva asignación
      final updatedAnimal = animal.copyWith(batchUuid: event.batchUuid);
      await animalRepository.update(updatedAnimal);

      // Si se está asignando a un nuevo lote, agregarlo
      if (event.batchUuid != null) {
        await lotesRepository.addAnimalToLote(
          loteUuid: event.batchUuid!,
          animalUuid: event.animalUuid,
        );
      }

      // Recargar todos los animales
      final updated = await animalRepository.getAll();
      final selected = state.selectedAnimal?.uuid == event.animalUuid
          ? updatedAnimal
          : state.selectedAnimal;

      emit(AnimalState.success(animals: updated, selectedAnimal: selected));
      LoggerService.i(
        'Animal asignado a lote ${event.batchUuid ?? "ninguno"}',
        tag: _logTag,
      );
    } catch (e, st) {
      LoggerService.e(
        'Error al asignar animal a lote: $e',
        tag: _logTag,
        stackTrace: st,
      );
      emit(
        AnimalState.failure(
          message: 'Error al asignar animal: ${e.toString()}',
          animals: state.animals,
          selectedAnimal: state.selectedAnimal,
        ),
      );
    }
  }

  Future<void> _handleRecordOperation(
    Emitter<AnimalState> emit, {
    required String logAction,
    required Future<void> Function() operation,
  }) async {
    LoggerService.d(logAction, tag: _logTag);
    try {
      emit(AnimalState.loading());
      await operation();
      final updated = await animalRepository.getAll();
      AnimalEntity? selected;
      if (state.selectedAnimal != null) {
        try {
          selected = updated.firstWhere(
            (animal) => animal.uuid == state.selectedAnimal!.uuid,
          );
        } catch (_) {
          selected = null;
        }
      }
      emit(AnimalState.success(animals: updated, selectedAnimal: selected));
    } catch (e, st) {
      LoggerService.e('Error en $logAction: $e', tag: _logTag, stackTrace: st);
      emit(
        AnimalState.failure(
          message: 'Error en $logAction: ${e.toString()}',
          animals: state.animals,
          selectedAnimal: state.selectedAnimal,
        ),
      );
    }
  }
}
