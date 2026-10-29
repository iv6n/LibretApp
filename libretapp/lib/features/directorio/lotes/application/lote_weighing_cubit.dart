/// State and persistence flow for rapid partial lot weighing.
library;

import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/weight_record.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/animal_status.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/domain/services/weight_performance_calculator.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';

enum LoteWeighingStatus { initial, loading, ready, saving, saved, failure }

class LoteWeighingState extends Equatable {
  const LoteWeighingState({
    this.status = LoteWeighingStatus.initial,
    this.lote,
    this.animals = const [],
    this.histories = const {},
    this.weights = const {},
    this.errors = const {},
    this.selectedIndex = 0,
    this.measuredAt,
    this.savedCount = 0,
    this.errorMessage,
  });

  final LoteWeighingStatus status;
  final LoteEntity? lote;
  final List<AnimalEntity> animals;
  final Map<String, List<WeightRecord>> histories;
  final Map<String, double> weights;
  final Map<String, String> errors;
  final int selectedIndex;
  final DateTime? measuredAt;
  final int savedCount;
  final String? errorMessage;

  bool get isLoading => status == LoteWeighingStatus.loading;
  bool get isSaving => status == LoteWeighingStatus.saving;

  LoteWeighingState copyWith({
    LoteWeighingStatus? status,
    LoteEntity? lote,
    List<AnimalEntity>? animals,
    Map<String, List<WeightRecord>>? histories,
    Map<String, double>? weights,
    Map<String, String>? errors,
    int? selectedIndex,
    DateTime? measuredAt,
    int? savedCount,
    String? errorMessage,
  }) => LoteWeighingState(
    status: status ?? this.status,
    lote: lote ?? this.lote,
    animals: animals ?? this.animals,
    histories: histories ?? this.histories,
    weights: weights ?? this.weights,
    errors: errors ?? this.errors,
    selectedIndex: selectedIndex ?? this.selectedIndex,
    measuredAt: measuredAt ?? this.measuredAt,
    savedCount: savedCount ?? this.savedCount,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [
    status,
    lote,
    animals,
    histories,
    weights,
    errors,
    selectedIndex,
    measuredAt,
    savedCount,
    errorMessage,
  ];
}

class LoteWeighingCubit extends Cubit<LoteWeighingState> {
  LoteWeighingCubit({
    required AnimalRepository animalRepository,
    required LotesRepository lotesRepository,
    required WeightRecordRepository weightRepository,
    WeightPerformanceCalculator calculator =
        const WeightPerformanceCalculator(),
  }) : _animalRepository = animalRepository,
       _lotesRepository = lotesRepository,
       _weightRepository = weightRepository,
       _calculator = calculator,
       super(const LoteWeighingState());

  final AnimalRepository _animalRepository;
  final LotesRepository _lotesRepository;
  final WeightRecordRepository _weightRepository;
  final WeightPerformanceCalculator _calculator;
  bool _savingInFlight = false;
  final Map<String, String> _recordUuids = {};


  Future<void> load(String loteUuid) async {
    if (_savingInFlight) return;
    _recordUuids.clear();
    emit(state.copyWith(status: LoteWeighingStatus.loading));
    try {
      final lote = await _findLote(loteUuid);
      if (lote == null) throw StateError('Lote no encontrado');
      final members = await _animalRepository.getByBatchUuid(loteUuid);
      final animals =
          members
              .where((animal) => animal.status == AnimalStatus.active)
              .toList(growable: false)
            ..sort((a, b) => a.earTagNumber.compareTo(b.earTagNumber));
      final histories = await _weightRepository.getWeightRecordsForAnimals(
        animals.map((animal) => animal.uuid).toSet(),
      );
      emit(
        state.copyWith(
          status: LoteWeighingStatus.ready,
          lote: lote,
          animals: animals,
          histories: histories,
          measuredAt: _dateOnly(DateTime.now()),
          weights: const {},
          errors: const {},
          selectedIndex: 0,
          savedCount: 0,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: LoteWeighingStatus.failure,
          errorMessage: 'No se pudo cargar el lote: $error',
        ),
      );
    }
  }

  void setMeasuredAt(DateTime value) {
    if (_savingInFlight || state.status == LoteWeighingStatus.saved) return;
    emit(
      state.copyWith(
        measuredAt: _dateOnly(value),
        status: LoteWeighingStatus.ready,
      ),
    );
  }

  void setWeight(String animalUuid, String rawValue) {
    if (_savingInFlight || state.status == LoteWeighingStatus.saved) return;
    final value = double.tryParse(rawValue.trim().replaceAll(',', '.'));
    final weights = {...state.weights};
    final errors = {...state.errors}..remove(animalUuid);
    if (rawValue.trim().isEmpty) {
      weights.remove(animalUuid);
    } else if (value == null || !value.isFinite || value <= 0) {
      weights.remove(animalUuid);
      errors[animalUuid] = 'Peso inválido';
    } else {
      weights[animalUuid] = value;
    }
    emit(
      state.copyWith(
        weights: weights,
        errors: errors,
        status: LoteWeighingStatus.ready,
      ),
    );
  }

  void selectIndex(int index) {
    if (state.animals.isEmpty) return;
    final bounded = index.clamp(0, state.animals.length - 1);
    emit(state.copyWith(selectedIndex: bounded));
  }

  AnimalWeightPerformance? preview(String animalUuid) {
    final current = state.weights[animalUuid];
    if (current == null || state.measuredAt == null) return null;
    return _calculator.calculateAnimalPerformance(
      animalUuid: animalUuid,
      currentWeightKg: current,
      measuredAt: state.measuredAt!,
      history: state.histories[animalUuid] ?? const [],
    );
  }

  double? previousWeight(String animalUuid) {
    final records = state.histories[animalUuid];
    if (records == null || records.isEmpty) return null;
    return records.first.weight;
  }

  Future<void> save() async {
    if (_savingInFlight || state.status == LoteWeighingStatus.saved) return;
    if (state.errors.isNotEmpty) {
      emit(state.copyWith(errorMessage: 'Corrige los pesos marcados.'));
      return;
    }
    final lote = state.lote;
    final measuredAt = state.measuredAt;
    if (lote == null || measuredAt == null) return;
    if (state.weights.isEmpty) {
      emit(state.copyWith(errorMessage: 'Captura al menos un peso.'));
      return;
    }

    final capturedAt = DateTime.now();
    final entries = [for (final animal in state.animals)
      if (state.weights.containsKey(animal.uuid)) WeightBatchEntry(
        animalUuid: animal.uuid,
        record: WeightRecord(animalUuid: animal.uuid, lotUuid: lote.uuid,
          date: measuredAt, weight: state.weights[animal.uuid]!,
          method: WeightMethod.scale, createdAt: capturedAt,
          recordUuid: _recordUuids.putIfAbsent(animal.uuid, () => const Uuid().v4())),
      ),
    ];
    _savingInFlight = true;
    emit(state.copyWith(status: LoteWeighingStatus.saving, errorMessage: null));
    try {
      final saved = await _weightRepository.addWeightRecordsAtomically(entries);
      if (!isClosed) emit(state.copyWith(status: LoteWeighingStatus.saved,
          savedCount: saved.length, errorMessage: null));
    } catch (_) {
      if (!isClosed) emit(state.copyWith(status: LoteWeighingStatus.failure,
          savedCount: 0, errorMessage: 'No se guardó ningún peso. Revisa la captura e inténtalo de nuevo.'));
    } finally {
      _savingInFlight = false;
    }
  }

  Future<LoteEntity?> _findLote(String loteUuid) async {
    return _lotesRepository.getByUuid(loteUuid);
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
