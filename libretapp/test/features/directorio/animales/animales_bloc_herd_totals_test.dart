/// The directory list loads 20 animals at a time, so anything counted over
/// the loaded pages reads low and then climbs as the user scrolls. These pin
/// the herd figures the labels use to the database count instead.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/agenda/data/agenda_reminder_sync_service.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/directorio/animales/bloc/animales_bloc.dart';
import 'package:libretapp/features/directorio/animales/bloc/animales_event.dart';
import 'package:libretapp/features/directorio/animales/bloc/animales_state.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/index.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/care_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/movement_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/reproduction_record_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/services/animal_edit_service.dart';
import 'package:libretapp/features/directorio/animales/domain/services/care_calendar_service.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';

AnimalEntity _animal({
  required String uuid,
  required LifeStage lifeStage,
  AnimalStatus status = AnimalStatus.active,
}) {
  final now = DateTime(2026, 1, 1);
  return AnimalEntity(
    uuid: uuid,
    earTagNumber: uuid,
    species: Species.cattle,
    category: Category.cow,
    lifeStage: lifeStage,
    sex: Sex.female,
    breed: 'Cebu',
    birthDate: DateTime(2022, 1, 1),
    ageMonths: 48,
    healthStatus: HealthStatus.good,
    vaccinated: true,
    dewormed: true,
    hasVitamins: false,
    hasChronicIssues: false,
    reproductiveStatus: ReproductiveStatus.unknown,
    productionPurpose: ProductionPurpose.undefined,
    productionStage: ProductionStage.unknown,
    productionSystem: ProductionSystem.unknown,
    underObservation: false,
    requiresAttention: false,
    riskLevel: RiskLevel.none,
    gallery: const [],
    status: status,
    synced: true,
    creationDate: now,
    lastUpdateDate: now,
  );
}

/// Paginates like the real Isar repository, and answers the count queries
/// over the whole herd rather than over the page handed out.
class _PagedAnimalRepository implements AnimalRepository {
  _PagedAnimalRepository(this.animals);

  final List<AnimalEntity> animals;

  List<AnimalEntity> get _active =>
      animals.where((a) => a.status.isInActiveHerd).toList();

  @override
  Future<List<AnimalEntity>> getPage({
    required int offset,
    required int limit,
  }) async => _active.skip(offset).take(limit).toList();

  @override
  Future<int> count() async => _active.length;

  @override
  Future<Map<LifeStage, int>> getActiveStageCounts() async {
    final counts = <LifeStage, int>{};
    for (final animal in _active) {
      counts.update(animal.lifeStage, (value) => value + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  @override
  Stream<void> watchChanges() => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _NoopLotesRepository implements LotesRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _NoopMovementRepository implements MovementRecordRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _NoopCareRepository implements CareRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _NoopAgendaRepository implements AgendaRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _NoopHealthRepository implements HealthRecordRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _NoopReproductionRepository implements ReproductionRecordRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

AnimalEditService _editService(AnimalRepository animalRepository) {
  final careRepository = _NoopCareRepository();
  return AnimalEditService(
    animalRepository: animalRepository,
    lotesRepository: _NoopLotesRepository(),
    movementRepository: _NoopMovementRepository(),
    careRepository: careRepository,
    agendaReminderSyncService: AgendaReminderSyncService(
      animalRepository: animalRepository,
      agendaRepository: _NoopAgendaRepository(),
      healthRepo: _NoopHealthRepository(),
      reproductionRepo: _NoopReproductionRepository(),
      careRepo: careRepository,
      careCalendarService: CareCalendarService(careRepository),
    ),
  );
}

Future<void> _flush() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(const Duration(milliseconds: 20));
}

void main() {
  group('AnimalesBloc herd totals', () {
    test(
      'reports the whole herd while only the first page is loaded',
      () async {
        // 50 animals, so the first page (20) is well short of the herd.
        final repository = _PagedAnimalRepository([
          for (var i = 0; i < 50; i++)
            _animal(uuid: 'a-$i', lifeStage: LifeStage.cow),
        ]);
        final bloc = AnimalesBloc(
          repository,
          animalEditService: _editService(repository),
        );
        addTearDown(bloc.close);

        bloc.add(const LoadAnimales());
        await _flush();

        final state = bloc.state as AnimalesLoaded;
        expect(
          state.allAnimals,
          hasLength(AnimalesLoaded.pageSize),
          reason: 'only the first page is loaded',
        );
        expect(
          state.herdTotal,
          50,
          reason: 'the label must state the herd, not the loaded page',
        );
        expect(state.hasMore, isTrue);
      },
    );

    test('counts stages across the herd, not just the loaded page', () async {
      // Ordered so the first page of 20 is entirely cows: a page-based tally
      // would report zero heifers and zero bulls.
      final repository = _PagedAnimalRepository([
        for (var i = 0; i < 25; i++)
          _animal(uuid: 'cow-$i', lifeStage: LifeStage.cow),
        for (var i = 0; i < 8; i++)
          _animal(uuid: 'heifer-$i', lifeStage: LifeStage.heifer),
        for (var i = 0; i < 3; i++)
          _animal(uuid: 'bull-$i', lifeStage: LifeStage.bull),
      ]);
      final bloc = AnimalesBloc(
        repository,
        animalEditService: _editService(repository),
      );
      addTearDown(bloc.close);

      bloc.add(const LoadAnimales());
      await _flush();

      final state = bloc.state as AnimalesLoaded;
      expect(state.allAnimals, hasLength(AnimalesLoaded.pageSize));
      expect(state.herdStageCounts[LifeStage.cow], 25);
      expect(state.herdStageCounts[LifeStage.heifer], 8);
      expect(state.herdStageCounts[LifeStage.bull], 3);
      expect(state.herdTotal, 36);
    });

    test('excludes animals that left the herd from the total', () async {
      final repository = _PagedAnimalRepository([
        for (var i = 0; i < 5; i++)
          _animal(uuid: 'active-$i', lifeStage: LifeStage.cow),
        _animal(
          uuid: 'sold',
          lifeStage: LifeStage.cow,
          status: AnimalStatus.sold,
        ),
        _animal(
          uuid: 'dead',
          lifeStage: LifeStage.cow,
          status: AnimalStatus.dead,
        ),
        _animal(
          uuid: 'archived',
          lifeStage: LifeStage.cow,
          status: AnimalStatus.archived,
        ),
      ]);
      final bloc = AnimalesBloc(
        repository,
        animalEditService: _editService(repository),
      );
      addTearDown(bloc.close);

      bloc.add(const LoadAnimales());
      await _flush();

      final state = bloc.state as AnimalesLoaded;
      expect(state.herdTotal, 5);
      expect(state.herdStageCounts[LifeStage.cow], 5);
    });

    test('loading more pages does not move the herd total', () async {
      final repository = _PagedAnimalRepository([
        for (var i = 0; i < 45; i++)
          _animal(uuid: 'a-$i', lifeStage: LifeStage.cow),
      ]);
      final bloc = AnimalesBloc(
        repository,
        animalEditService: _editService(repository),
      );
      addTearDown(bloc.close);

      bloc.add(const LoadAnimales());
      await _flush();
      expect((bloc.state as AnimalesLoaded).herdTotal, 45);

      bloc.add(const AnimalesLoadMore());
      await _flush();

      final state = bloc.state as AnimalesLoaded;
      expect(state.allAnimals, hasLength(40), reason: 'two pages loaded');
      expect(
        state.herdTotal,
        45,
        reason: 'the figure was already the real one and must not drift',
      );
    });
  });
}
