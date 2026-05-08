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
import 'package:libretapp/features/directorio/animales/domain/repositories/commercial_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/cost_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/production_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/registro/bloc/registro_event.dart';
import 'package:libretapp/features/registro/bloc/registro_state.dart';

/// BLoC that persists animal records on behalf of the registro form pages.
///
/// Only the save lifecycle is managed here. Validation and UI form state
/// remain in each page's [State] class.
class RegistroBloc extends Bloc<RegistroEvent, RegistroState> {
  /// Creates a [RegistroBloc] with the required record repositories.
  RegistroBloc({
    required WeightRecordRepository weightRepo,
    required HealthRecordRepository healthRepo,
    required ProductionRecordRepository productionRepo,
    required ReproductionRecordRepository reproductionRepo,
    required CommercialRecordRepository commercialRepo,
    required MovementRecordRepository movementRepo,
    required CostRecordRepository costRepo,
  }) : _weightRepo = weightRepo,
       _healthRepo = healthRepo,
       _productionRepo = productionRepo,
       _reproductionRepo = reproductionRepo,
       _commercialRepo = commercialRepo,
       _movementRepo = movementRepo,
       _costRepo = costRepo,
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

  final WeightRecordRepository _weightRepo;
  final HealthRecordRepository _healthRepo;
  final ProductionRecordRepository _productionRepo;
  final ReproductionRecordRepository _reproductionRepo;
  final CommercialRecordRepository _commercialRepo;
  final MovementRecordRepository _movementRepo;
  final CostRecordRepository _costRepo;

  Future<void> _onPeso(
    RegistroPesoSubmitted event,
    Emitter<RegistroState> emit,
  ) async {
    emit(state.copyWith(status: RegistroStatus.loading));
    try {
      await _weightRepo.addWeightRecord(event.animalUuid, event.record);
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
      await _healthRepo.addHealthRecord(event.animalUuid, event.record);
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
      await _productionRepo.addProductionRecord(event.animalUuid, event.record);
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
      await _reproductionRepo.addReproductionRecord(
        event.animalUuid,
        event.record,
      );
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
      await _commercialRepo.addCommercialRecord(event.animalUuid, event.record);
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
      await _movementRepo.addMovementRecord(event.animalUuid, event.record);
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
      await _costRepo.addCostRecord(event.animalUuid, event.record);
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
