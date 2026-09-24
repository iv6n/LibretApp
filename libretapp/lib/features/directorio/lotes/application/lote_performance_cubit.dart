/// Loads the derived performance view for a lot.
library;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/tenancy/farm_context_service.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/alimentacion/feed_models.dart';
import 'package:libretapp/features/directorio/lotes/alimentacion/feed_service.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/domain/services/weight_performance_calculator.dart';

enum LotePerformanceStatus { initial, loading, loaded, failure }

class LotePerformanceState extends Equatable {
  const LotePerformanceState({
    this.status = LotePerformanceStatus.initial,
    this.lote,
    this.animals = const [],
    this.summary,
    this.sessions = const [],
    this.economics,
    this.errorMessage,
  });

  final LotePerformanceStatus status;
  final LoteEntity? lote;
  final List<AnimalEntity> animals;
  final LotPerformanceSummary? summary;
  final List<WeighingSessionSummary> sessions;
  final LotEconomicMetrics? economics;
  final String? errorMessage;

  bool get isLoading => status == LotePerformanceStatus.loading;

  LotePerformanceState copyWith({
    LotePerformanceStatus? status,
    LoteEntity? lote,
    List<AnimalEntity>? animals,
    LotPerformanceSummary? summary,
    List<WeighingSessionSummary>? sessions,
    LotEconomicMetrics? economics,
    String? errorMessage,
  }) => LotePerformanceState(
    status: status ?? this.status,
    lote: lote ?? this.lote,
    animals: animals ?? this.animals,
    summary: summary ?? this.summary,
    sessions: sessions ?? this.sessions,
    economics: economics ?? this.economics,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [
    status,
    lote,
    animals,
    summary,
    sessions,
    economics,
    errorMessage,
  ];
}

class LotePerformanceCubit extends Cubit<LotePerformanceState> {
  LotePerformanceCubit({
    required AnimalRepository animalRepository,
    required WeightRecordRepository weightRepository,
    WeightPerformanceCalculator calculator =
        const WeightPerformanceCalculator(),
    FeedService? feedService,
    FarmContextRepository? farmContextRepository,
  }) : _animalRepository = animalRepository,
       _weightRepository = weightRepository,
       _calculator = calculator,
       _feedService = feedService,
       _farmContextRepository = farmContextRepository,
       super(const LotePerformanceState());

  final AnimalRepository _animalRepository;
  final WeightRecordRepository _weightRepository;
  final WeightPerformanceCalculator _calculator;
  final FeedService? _feedService;
  final FarmContextRepository? _farmContextRepository;

  Future<void> load(LoteEntity lote) async {
    emit(state.copyWith(status: LotePerformanceStatus.loading, lote: lote));
    try {
      final members = await _animalRepository.getByBatchUuid(lote.uuid);
      final animals =
          members
              .where((animal) => animal.status.isInActiveHerd)
              .toList(growable: false)
            ..sort((a, b) => a.earTagNumber.compareTo(b.earTagNumber));
      final histories = await _weightRepository.getWeightRecordsForAnimals(
        animals.map((animal) => animal.uuid).toSet(),
      );
      final lotRecords = await _weightRepository.getWeightRecordsForLot(
        lote.uuid,
      );
      final summary = _calculator.calculateLotPerformance(
        lotUuid: lote.uuid,
        activeAnimalUuids: animals.map((animal) => animal.uuid),
        histories: histories,
      );
      final sessions = _calculator.calculateWeighingSessions(
        lotUuid: lote.uuid,
        records: lotRecords,
        histories: histories,
      );
      final feedPlan = await _latestFeedPlan(lote.uuid);
      final economics = _calculator.calculateEconomicMetrics(
        feedPricePerKg: lote.feedPricePerKg,
        dailyFeedKgPerHead: lote.dailyFeedKgPerHead,
        liveWeightPricePerKg: lote.liveWeightPricePerKg,
        feedPlan: feedPlan,
        adgKgPerDay: summary.averageAdgKgPerDay,
        headCount: summary.activeAnimalCount,
      );

      emit(
        state.copyWith(
          status: LotePerformanceStatus.loaded,
          lote: lote,
          animals: animals,
          summary: summary,
          sessions: sessions,
          economics: economics,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: LotePerformanceStatus.failure,
          lote: lote,
          errorMessage: 'No se pudo cargar el rendimiento: $error',
        ),
      );
    }
  }

  Future<FeedPlan?> _latestFeedPlan(String lotUuid) async {
    final feedService = _feedService;
    final farmContextRepository = _farmContextRepository;
    if (feedService == null || farmContextRepository == null) return null;
    final context = await farmContextRepository.current();
    if (context == null) return null;
    final now = DateTime.now();
    final plans = (await feedService.plans(context.farm.uuid, lotUuid))
        .where((plan) => !plan.validFrom.isAfter(now))
        .toList();
    if (plans.isEmpty) return null;
    plans.sort((a, b) {
      final validFrom = b.validFrom.compareTo(a.validFrom);
      return validFrom != 0 ? validFrom : b.version.compareTo(a.version);
    });
    return plans.first;
  }
}
