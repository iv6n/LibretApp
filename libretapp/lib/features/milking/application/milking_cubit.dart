library;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libretapp/core/utils/id_generator.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/milking/domain/milking_models.dart';
import 'package:libretapp/features/milking/domain/milking_repository.dart';

enum MilkingLoadStatus {
  initial,
  loading,
  choosingDraft,
  ready,
  saving,
  completed,
  failure,
}

enum MilkingCaptureMode { individual, group }

class MilkingState extends Equatable {
  const MilkingState({
    this.status = MilkingLoadStatus.initial,
    this.captureMode = MilkingCaptureMode.individual,
    this.session,
    this.animals = const [],
    this.lotes = const [],
    this.entries = const [],
    this.draftSessions = const [],
    this.presetAnimalUuid,
    this.errorMessage,
    this.withdrawnAnimals = const [],
  });

  final MilkingLoadStatus status;
  final MilkingCaptureMode captureMode;
  final MilkingSession? session;
  final List<AnimalEntity> animals;
  final List<LoteEntity> lotes;
  final List<MilkingEntry> entries;
  final List<MilkingSession> draftSessions;
  final String? presetAnimalUuid;
  final String? errorMessage;

  /// Cows that would otherwise be eligible for milking but are excluded
  /// because they are under an active health withdrawal — selling their
  /// milk during that window is a food-safety breach, so they never make it
  /// into [animals].
  final List<AnimalEntity> withdrawnAnimals;

  int get totalMilliliters =>
      entries.fold(0, (total, entry) => total + entry.volumeMilliliters);

  double get totalLiters => totalMilliliters / 1000;

  MilkingEntry? entryForAnimal(String animalUuid) {
    for (final entry in entries) {
      if (entry.animalUuid == animalUuid) return entry;
    }
    return null;
  }

  List<AnimalEntity> animalsForLote(String? loteUuid) {
    if (loteUuid == null) return const [];
    LoteEntity? lote;
    for (final candidate in lotes) {
      if (candidate.uuid == loteUuid) {
        lote = candidate;
        break;
      }
    }
    if (lote == null) return const [];
    final allowed = lote.animalUuids.toSet();
    final result = animals
        .where((animal) => allowed.contains(animal.uuid))
        .toList();
    result.sort((a, b) {
      final aLactating = a.productionStage == ProductionStage.lactating;
      final bLactating = b.productionStage == ProductionStage.lactating;
      if (aLactating != bLactating) return aLactating ? -1 : 1;
      return a.earTagNumber.compareTo(b.earTagNumber);
    });
    return result;
  }

  MilkingState copyWith({
    MilkingLoadStatus? status,
    MilkingCaptureMode? captureMode,
    MilkingSession? session,
    List<AnimalEntity>? animals,
    List<LoteEntity>? lotes,
    List<MilkingEntry>? entries,
    List<MilkingSession>? draftSessions,
    Object? presetAnimalUuid = _unset,
    Object? errorMessage = _unset,
    List<AnimalEntity>? withdrawnAnimals,
  }) {
    return MilkingState(
      status: status ?? this.status,
      captureMode: captureMode ?? this.captureMode,
      session: session ?? this.session,
      animals: animals ?? this.animals,
      lotes: lotes ?? this.lotes,
      entries: entries ?? this.entries,
      draftSessions: draftSessions ?? this.draftSessions,
      presetAnimalUuid: presetAnimalUuid == _unset
          ? this.presetAnimalUuid
          : presetAnimalUuid as String?,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      withdrawnAnimals: withdrawnAnimals ?? this.withdrawnAnimals,
    );
  }

  @override
  List<Object?> get props => [
    status,
    captureMode,
    session,
    animals,
    lotes,
    entries,
    draftSessions,
    presetAnimalUuid,
    errorMessage,
    withdrawnAnimals,
  ];
}

class MilkingCubit extends Cubit<MilkingState> {
  MilkingCubit({
    required MilkingRepository repository,
    required AnimalRepository animalRepository,
    required LotesRepository lotesRepository,
    HealthRecordRepository? healthRecordRepository,
  }) : _repository = repository,
       _animalRepository = animalRepository,
       _lotesRepository = lotesRepository,
       _healthRecordRepository = healthRecordRepository,
       super(const MilkingState());

  final MilkingRepository _repository;
  final AnimalRepository _animalRepository;
  final LotesRepository _lotesRepository;
  final HealthRecordRepository? _healthRecordRepository;

  Future<void> load({String? presetAnimalUuid}) async {
    emit(state.copyWith(status: MilkingLoadStatus.loading));
    try {
      final results = await Future.wait([
        _animalRepository.getAll(),
        _lotesRepository.getActiveLotes(),
        _repository.getOpenDraft(),
        _repository.getAllSessions(),
        _repository.getAllEntries(),
      ]);
      final allAnimals = results[0] as List<AnimalEntity>;
      final candidates = allAnimals.where(_isEligibleCow).toList();

      // Selling milk from a cow under an active health withdrawal is a
      // food-safety breach, so she is held out of the eligible list even
      // though she otherwise qualifies (cattle, female, active).
      final withdrawals =
          await _healthRecordRepository?.getActiveWithdrawals(
            candidates.map((a) => a.uuid).toSet(),
          ) ??
          const <String, DateTime>{};

      final eligible =
          candidates.where((a) => !withdrawals.containsKey(a.uuid)).toList()
            ..sort((a, b) => a.earTagNumber.compareTo(b.earTagNumber));
      final withdrawn =
          candidates.where((a) => withdrawals.containsKey(a.uuid)).toList()
            ..sort((a, b) => a.earTagNumber.compareTo(b.earTagNumber));

      final lotes = results[1] as List<LoteEntity>;
      var session = results[2] as MilkingSession?;
      final sessions = results[3] as List<MilkingSession>;
      final allEntries = results[4] as List<MilkingEntry>;
      final availableDrafts =
          sessions
              .where(
                (candidate) =>
                    candidate.status == MilkingStatus.draft &&
                    candidate.uuid != session?.uuid &&
                    allEntries.any(
                      (entry) => entry.sessionUuid == candidate.uuid,
                    ),
              )
              .toList()
            ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

      if (session == null && availableDrafts.isNotEmpty) {
        emit(
          state.copyWith(
            status: MilkingLoadStatus.choosingDraft,
            animals: eligible,
            lotes: lotes,
            draftSessions: availableDrafts,
            presetAnimalUuid: presetAnimalUuid,
            errorMessage: null,
            withdrawnAnimals: withdrawn,
          ),
        );
        return;
      }
      session ??= await _createDraftSession();
      final entries = await _repository.getEntries(session.uuid);
      emit(
        state.copyWith(
          status: MilkingLoadStatus.ready,
          session: session,
          animals: eligible,
          lotes: lotes,
          entries: entries,
          draftSessions: availableDrafts,
          presetAnimalUuid: presetAnimalUuid,
          captureMode: session.sourceLoteUuid == null
              ? MilkingCaptureMode.individual
              : MilkingCaptureMode.group,
          errorMessage: null,
          withdrawnAnimals: withdrawn,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: MilkingLoadStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<MilkingSession> _createDraftSession() async {
    final now = DateTime.now();
    final session = MilkingSession(
      uuid: generateId(),
      occurredAt: now,
      shift: MilkingShift.fromTime(now),
      status: MilkingStatus.draft,
      createdAt: now,
      updatedAt: now,
    );
    await _repository.upsertSession(session);
    return session;
  }

  Future<void> resumeDraft(String sessionUuid) async {
    if (state.status == MilkingLoadStatus.loading ||
        state.status == MilkingLoadStatus.saving) {
      return;
    }
    final previousSession = state.session;
    emit(state.copyWith(status: MilkingLoadStatus.loading, errorMessage: null));
    try {
      final candidate = await _repository.getSession(sessionUuid);
      if (candidate == null || candidate.status != MilkingStatus.draft) {
        emit(
          state.copyWith(
            status: MilkingLoadStatus.failure,
            errorMessage: 'La ordeña ya no está disponible para reanudar.',
          ),
        );
        return;
      }
      final drafts = [
        ...state.draftSessions.where((draft) => draft.uuid != candidate.uuid),
        if (previousSession != null &&
            previousSession.status == MilkingStatus.draft &&
            previousSession.uuid != candidate.uuid)
          previousSession,
      ];
      final entries = await _repository.getEntries(candidate.uuid);
      emit(
        state.copyWith(
          status: MilkingLoadStatus.ready,
          session: candidate,
          entries: entries,
          draftSessions: drafts,
          captureMode: candidate.sourceLoteUuid == null
              ? MilkingCaptureMode.individual
              : MilkingCaptureMode.group,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: MilkingLoadStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> startNewSession() async {
    if (state.status == MilkingLoadStatus.saving ||
        state.status == MilkingLoadStatus.loading) {
      return;
    }
    emit(state.copyWith(status: MilkingLoadStatus.loading, errorMessage: null));
    try {
      final previousSession = state.session;
      final drafts = [
        ...state.draftSessions,
        if (previousSession != null &&
            previousSession.status == MilkingStatus.draft)
          previousSession,
      ];
      final session = await _createDraftSession();
      emit(
        state.copyWith(
          status: MilkingLoadStatus.ready,
          session: session,
          entries: const [],
          draftSessions: drafts,
          captureMode: MilkingCaptureMode.individual,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: MilkingLoadStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  bool _isEligibleCow(AnimalEntity animal) {
    return animal.species == Species.cattle &&
        animal.sex == Sex.female &&
        animal.status == AnimalStatus.active;
  }

  void setCaptureMode(MilkingCaptureMode mode) {
    emit(
      state.copyWith(
        status: MilkingLoadStatus.ready,
        captureMode: mode,
        errorMessage: null,
      ),
    );
  }

  Future<void> selectLote(String? loteUuid) async {
    final session = state.session;
    if (session == null) return;
    final updated = session.copyWith(
      sourceLoteUuid: loteUuid,
      updatedAt: DateTime.now(),
    );
    await _repository.upsertSession(updated);
    emit(
      state.copyWith(
        status: MilkingLoadStatus.ready,
        session: updated,
        errorMessage: null,
      ),
    );
  }

  Future<void> updateSchedule({
    DateTime? occurredAt,
    MilkingShift? shift,
  }) async {
    final session = state.session;
    if (session == null) return;
    final updated = session.copyWith(
      occurredAt: occurredAt,
      shift: shift,
      updatedAt: DateTime.now(),
    );
    await _repository.upsertSession(updated);
    emit(
      state.copyWith(
        status: MilkingLoadStatus.ready,
        session: updated,
        errorMessage: null,
      ),
    );
  }

  Future<void> upsertAnimalVolume({
    required String animalUuid,
    required int volumeMilliliters,
  }) async {
    final session = state.session;
    if (session == null) return;
    if (volumeMilliliters <= 0) {
      emit(
        state.copyWith(
          status: MilkingLoadStatus.failure,
          errorMessage: 'Los litros deben ser mayores que cero',
        ),
      );
      return;
    }
    final existing = state.entryForAnimal(animalUuid);
    final now = DateTime.now();
    final entry = existing == null
        ? MilkingEntry(
            uuid: generateId(),
            sessionUuid: session.uuid,
            animalUuid: animalUuid,
            volumeMilliliters: volumeMilliliters,
            createdAt: now,
            updatedAt: now,
          )
        : existing.copyWith(
            volumeMilliliters: volumeMilliliters,
            updatedAt: now,
          );
    await _repository.upsertEntry(entry);
    final entries = [
      ...state.entries.where((item) => item.animalUuid != animalUuid),
      entry,
    ]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    emit(
      state.copyWith(
        status: MilkingLoadStatus.ready,
        entries: entries,
        errorMessage: null,
      ),
    );
  }

  Future<void> removeAnimal(String animalUuid) async {
    final entry = state.entryForAnimal(animalUuid);
    if (entry == null) return;
    await _repository.deleteEntry(entry.uuid);
    emit(
      state.copyWith(
        status: MilkingLoadStatus.ready,
        entries: state.entries
            .where((item) => item.animalUuid != animalUuid)
            .toList(growable: false),
        errorMessage: null,
      ),
    );
  }

  Future<void> finalize() async {
    final session = state.session;
    if (session == null || state.entries.isEmpty) {
      emit(
        state.copyWith(
          status: MilkingLoadStatus.failure,
          errorMessage: 'Registra al menos una vaca antes de finalizar',
        ),
      );
      return;
    }
    emit(state.copyWith(status: MilkingLoadStatus.saving));
    try {
      await _repository.finalizeSession(session.uuid);
      emit(state.copyWith(status: MilkingLoadStatus.completed));
    } catch (error) {
      emit(
        state.copyWith(
          status: MilkingLoadStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}

const Object _unset = Object();
