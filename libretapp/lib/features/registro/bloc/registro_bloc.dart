/// registro › bloc › RegistroBloc
///
/// BLoC that manages the submission lifecycle for all animal-record
/// registration form pages (peso, sanitario, producción, reproducción,
/// comercial, movimiento, costo).
///
/// Each form page provides its own [RegistroBloc] instance via
/// [BlocProvider], dispatches a typed submit event, and listens for
/// [RegistroStatus.success] / [RegistroStatus.failure] to show feedback.
///
/// Layer: application (state management)
/// Dependency: [AnimalRepository]
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/registro/bloc/registro_event.dart';
import 'package:libretapp/features/registro/bloc/registro_state.dart';

/// BLoC that persists animal records on behalf of the registro form pages.
///
/// Only the save lifecycle is managed here. Validation and UI form state
/// remain in each page's [State] class.
class RegistroBloc extends Bloc<RegistroEvent, RegistroState> {
  /// Creates a [RegistroBloc] with the required [AnimalRepository].
  RegistroBloc({required AnimalRepository animalRepository})
    : _repo = animalRepository,
      super(const RegistroState()) {
    on<RegistroPesoSubmitted>(_onPeso);
    on<RegistroSanitarioSubmitted>(_onSanitario);
    on<RegistroProduccionSubmitted>(_onProduccion);
    on<RegistroReproduccionSubmitted>(_onReproduccion);
    on<RegistroComercialSubmitted>(_onComercial);
    on<RegistroMovimientoSubmitted>(_onMovimiento);
    on<RegistroCostoSubmitted>(_onCosto);
    on<RegistroReset>(_onReset);
  }

  final AnimalRepository _repo;

  Future<void> _onPeso(
    RegistroPesoSubmitted event,
    Emitter<RegistroState> emit,
  ) async {
    emit(state.copyWith(status: RegistroStatus.loading));
    try {
      await _repo.addWeightRecord(event.animalUuid, event.record);
      emit(state.copyWith(status: RegistroStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: RegistroStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSanitario(
    RegistroSanitarioSubmitted event,
    Emitter<RegistroState> emit,
  ) async {
    emit(state.copyWith(status: RegistroStatus.loading));
    try {
      await _repo.addHealthRecord(event.animalUuid, event.record);
      emit(state.copyWith(status: RegistroStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: RegistroStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onProduccion(
    RegistroProduccionSubmitted event,
    Emitter<RegistroState> emit,
  ) async {
    emit(state.copyWith(status: RegistroStatus.loading));
    try {
      await _repo.addProductionRecord(event.animalUuid, event.record);
      emit(state.copyWith(status: RegistroStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: RegistroStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onReproduccion(
    RegistroReproduccionSubmitted event,
    Emitter<RegistroState> emit,
  ) async {
    emit(state.copyWith(status: RegistroStatus.loading));
    try {
      await _repo.addReproductionRecord(event.animalUuid, event.record);
      emit(state.copyWith(status: RegistroStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: RegistroStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onComercial(
    RegistroComercialSubmitted event,
    Emitter<RegistroState> emit,
  ) async {
    emit(state.copyWith(status: RegistroStatus.loading));
    try {
      await _repo.addCommercialRecord(event.animalUuid, event.record);
      emit(state.copyWith(status: RegistroStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: RegistroStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onMovimiento(
    RegistroMovimientoSubmitted event,
    Emitter<RegistroState> emit,
  ) async {
    emit(state.copyWith(status: RegistroStatus.loading));
    try {
      await _repo.addMovementRecord(event.animalUuid, event.record);
      emit(state.copyWith(status: RegistroStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: RegistroStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onCosto(
    RegistroCostoSubmitted event,
    Emitter<RegistroState> emit,
  ) async {
    emit(state.copyWith(status: RegistroStatus.loading));
    try {
      await _repo.addCostRecord(event.animalUuid, event.record);
      emit(state.copyWith(status: RegistroStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: RegistroStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onReset(RegistroReset event, Emitter<RegistroState> emit) {
    emit(RegistroState.initial());
  }
}
