import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/animales/bloc/animales_event.dart';
import 'package:libretapp/features/animales/bloc/animales_state.dart';
import 'package:libretapp/features/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/animales/infrastructure/animal_repository.dart';

class AnimalesBloc extends Bloc<AnimalesEvent, AnimalesState> {
  final AnimalRepository repository;

  StreamSubscription<List<AnimalEntity>>? _subscription;
  List<AnimalEntity> _latest = const [];
  String _query = '';

  AnimalesBloc(this.repository) : super(const AnimalesInitial()) {
    on<LoadAnimales>(_onLoadAnimales);
    on<AnimalesStreamUpdated>(_onStreamUpdated);
    on<AnimalesStreamFailed>(_onStreamFailed);
    on<AddAnimal>(_onAddAnimal);
    on<UpdateAnimal>(_onUpdateAnimal);
    on<DeleteAnimal>(_onDeleteAnimal);
    on<SearchAnimales>(_onSearchAnimales);
    on<AssignAnimalLocationBatch>(_onAssignAnimalLocationBatch);
    on<RenameBatch>(_onRenameBatch);
  }

  Future<void> _onLoadAnimales(
    LoadAnimales event,
    Emitter<AnimalesState> emit,
  ) async {
    emit(const AnimalesLoading());
    try {
      await repository.refreshFromRemote(force: event.forceRefresh);
    } catch (e) {
      emit(AnimalesError('No se pudo sincronizar: $e'));
    }
    await _subscription?.cancel();
    _subscription = repository.watchAll().listen(
      (animales) => add(AnimalesStreamUpdated(animales)),
      onError: (error, _) => add(AnimalesStreamFailed(error.toString())),
    );
  }

  void _onStreamUpdated(
    AnimalesStreamUpdated event,
    Emitter<AnimalesState> emit,
  ) {
    _latest = event.animales;
    emit(AnimalesLoaded(_applyFilter(_latest, _query)));
  }

  void _onStreamFailed(
    AnimalesStreamFailed event,
    Emitter<AnimalesState> emit,
  ) {
    emit(AnimalesError(event.message));
  }

  Future<void> _onAddAnimal(
    AddAnimal event,
    Emitter<AnimalesState> emit,
  ) async {
    try {
      emit(const AnimalesLoading());
      await repository.save(event.animal);
    } catch (e) {
      emit(AnimalesError(e.toString()));
    }
  }

  Future<void> _onUpdateAnimal(
    UpdateAnimal event,
    Emitter<AnimalesState> emit,
  ) async {
    try {
      emit(const AnimalesLoading());
      await repository.update(event.animal);
    } catch (e) {
      emit(AnimalesError(e.toString()));
    }
  }

  Future<void> _onDeleteAnimal(
    DeleteAnimal event,
    Emitter<AnimalesState> emit,
  ) async {
    try {
      emit(const AnimalesLoading());
      await repository.delete(event.id);
    } catch (e) {
      emit(AnimalesError(e.toString()));
    }
  }

  Future<void> _onSearchAnimales(
    SearchAnimales event,
    Emitter<AnimalesState> emit,
  ) async {
    _query = event.query.toLowerCase();
    emit(AnimalesLoaded(_applyFilter(_latest, _query)));
  }

  Future<void> _onAssignAnimalLocationBatch(
    AssignAnimalLocationBatch event,
    Emitter<AnimalesState> emit,
  ) async {
    try {
      emit(const AnimalesLoading());
      final current = await repository.getByUuid(event.uuid);
      if (current == null) {
        emit(const AnimalesError('Animal no encontrado'));
        return;
      }

      final now = DateTime.now();
      final updated = current.copyWith(
        currentPaddockId: event.locationId,
        initialLocationId:
            current.initialLocationId ??
            event.locationId ??
            current.initialLocationId,
        lastMovementDate: event.locationId != null
            ? now
            : current.lastMovementDate,
        batchId: event.batchId ?? current.batchId,
        lastUpdateDate: now,
        synced: false,
      );

      await repository.update(updated);
    } catch (e) {
      emit(AnimalesError(e.toString()));
    }
  }

  Future<void> _onRenameBatch(
    RenameBatch event,
    Emitter<AnimalesState> emit,
  ) async {
    try {
      emit(const AnimalesLoading());
      final animales = await repository.getAll();
      final toUpdate = animales.where((a) => a.batchId == event.oldBatchId);
      final now = DateTime.now();
      for (final animal in toUpdate) {
        final updated = animal.copyWith(
          batchId: event.newBatchId,
          lastUpdateDate: now,
          synced: false,
        );
        await repository.update(updated);
      }
    } catch (e) {
      emit(AnimalesError(e.toString()));
    }
  }

  List<AnimalEntity> _applyFilter(List<AnimalEntity> source, String query) {
    if (query.isEmpty) return source;
    return source.where((a) {
      final display = (a.visualId ?? a.earTagNumber).toLowerCase();
      final breed = a.breed.toLowerCase();
      return display.contains(query) || breed.contains(query);
    }).toList();
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
