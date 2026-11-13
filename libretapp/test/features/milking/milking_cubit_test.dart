import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/health_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/milking/milking.dart';
import 'package:libretapp/l10n/app_localizations.dart';

void main() {
  tearDown(() async {
    await locator.reset();
  });

  group('MilkingCubit', () {
    test('filters eligible cows and loads an active lote', () async {
      final cow = _animal(uuid: 'cow-1');
      final bull = _animal(uuid: 'bull-1', sex: Sex.male);
      final soldCow = _animal(uuid: 'cow-sold', status: AnimalStatus.sold);
      final lote = _lote([cow.uuid, bull.uuid, soldCow.uuid]);
      final repository = _FakeMilkingRepository();
      final cubit = MilkingCubit(
        repository: repository,
        animalRepository: _FakeAnimalRepository([cow, bull, soldCow]),
        lotesRepository: _FakeLotesRepository([lote]),
      );

      await cubit.load();
      await cubit.selectLote(lote.uuid);

      expect(cubit.state.animals, [cow]);
      expect(cubit.state.animalsForLote(lote.uuid), [cow]);
      expect(cubit.state.session?.sourceLoteUuid, lote.uuid);
      await cubit.close();
    });

    test('updates one entry per cow and calculates the total', () async {
      final cow = _animal(uuid: 'cow-1');
      final repository = _FakeMilkingRepository();
      final cubit = MilkingCubit(
        repository: repository,
        animalRepository: _FakeAnimalRepository([cow]),
        lotesRepository: _FakeLotesRepository(const []),
      );
      await cubit.load();

      await cubit.upsertAnimalVolume(
        animalUuid: cow.uuid,
        volumeMilliliters: 12500,
      );
      await cubit.upsertAnimalVolume(
        animalUuid: cow.uuid,
        volumeMilliliters: 13000,
      );

      expect(cubit.state.entries, hasLength(1));
      expect(cubit.state.totalMilliliters, 13000);
      expect(cubit.state.totalLiters, 13);
      await cubit.close();
    });

    test(
      'offers a previous draft and resumes its readings with original date',
      () async {
        final occurredAt = DateTime.now().subtract(const Duration(days: 1));
        final oldSession = _session('yesterday', occurredAt);
        final oldEntry = _entry('yesterday-entry', oldSession, 'cow-1');
        final repository = _FakeMilkingRepository(
          sessions: [oldSession],
          entries: [oldEntry],
        );
        final cubit = MilkingCubit(
          repository: repository,
          animalRepository: _FakeAnimalRepository([_animal(uuid: 'cow-1')]),
          lotesRepository: _FakeLotesRepository(const []),
        );

        await cubit.load();

        expect(cubit.state.status, MilkingLoadStatus.choosingDraft);
        expect(cubit.state.session, isNull);
        expect(cubit.state.draftSessions.single.occurredAt, occurredAt);

        await cubit.resumeDraft(oldSession.uuid);

        expect(cubit.state.session?.uuid, oldSession.uuid);
        expect(cubit.state.session?.occurredAt, occurredAt);
        expect(cubit.state.entries, [oldEntry]);
        await cubit.close();
      },
    );

    test(
      'new session keeps prior drafts available and does not overwrite them',
      () async {
        final oldSession = _session(
          'old-session',
          DateTime.now().subtract(const Duration(days: 1)),
        );
        final oldEntry = _entry('old-entry', oldSession, 'cow-1');
        final repository = _FakeMilkingRepository(
          sessions: [oldSession],
          entries: [oldEntry],
        );
        final cubit = MilkingCubit(
          repository: repository,
          animalRepository: _FakeAnimalRepository([_animal(uuid: 'cow-1')]),
          lotesRepository: _FakeLotesRepository(const []),
        );

        await cubit.load();
        await cubit.startNewSession();

        expect(cubit.state.session?.uuid, isNot(oldSession.uuid));
        expect(cubit.state.draftSessions, contains(oldSession));
        expect(await repository.getEntries(oldSession.uuid), [oldEntry]);

        await cubit.close();
      },
    );

    test('a new cubit can recover a prior draft after reopening', () async {
      final oldSession = _session(
        'reopen-session',
        DateTime.now().subtract(const Duration(days: 1)),
      );
      final oldEntry = _entry('reopen-entry', oldSession, 'cow-1');
      final repository = _FakeMilkingRepository(
        sessions: [oldSession],
        entries: [oldEntry],
      );

      final first = MilkingCubit(
        repository: repository,
        animalRepository: _FakeAnimalRepository([_animal(uuid: 'cow-1')]),
        lotesRepository: _FakeLotesRepository(const []),
      );
      await first.load();
      await first.resumeDraft(oldSession.uuid);
      await first.close();

      final reopened = MilkingCubit(
        repository: repository,
        animalRepository: _FakeAnimalRepository([_animal(uuid: 'cow-1')]),
        lotesRepository: _FakeLotesRepository(const []),
      );
      await reopened.load();
      await reopened.resumeDraft(oldSession.uuid);

      expect(reopened.state.entries, [oldEntry]);
      await reopened.close();
    });

    test(
      'emits a failure state instead of throwing for a non-positive volume',
      () async {
        final cow = _animal(uuid: 'cow-1');
        final cubit = MilkingCubit(
          repository: _FakeMilkingRepository(),
          animalRepository: _FakeAnimalRepository([cow]),
          lotesRepository: _FakeLotesRepository(const []),
        );
        await cubit.load();

        await cubit.upsertAnimalVolume(
          animalUuid: cow.uuid,
          volumeMilliliters: 0,
        );

        expect(cubit.state.status, MilkingLoadStatus.failure);
        expect(cubit.state.errorMessage, contains('mayores que cero'));
        expect(cubit.state.entries, isEmpty);
        await cubit.close();
      },
    );

    test('excludes cows under an active health withdrawal', () async {
      final cow = _animal(uuid: 'cow-1');
      final withdrawnCow = _animal(uuid: 'cow-withdrawn');
      final repository = _FakeMilkingRepository();
      final cubit = MilkingCubit(
        repository: repository,
        animalRepository: _FakeAnimalRepository([cow, withdrawnCow]),
        lotesRepository: _FakeLotesRepository(const []),
        healthRecordRepository: _FakeHealthRecordRepository({
          'cow-withdrawn': DateTime.now().add(const Duration(days: 3)),
        }),
      );

      await cubit.load();

      expect(cubit.state.animals, [cow]);
      expect(
        cubit.state.withdrawnAnimals.map((a) => a.uuid),
        ['cow-withdrawn'],
        reason:
            'selling milk from a cow under withdrawal is a food-safety '
            'breach, so she must not be eligible even though she is '
            'otherwise an active female dairy cow',
      );
      await cubit.close();
    });

    test('does not finalize an empty session', () async {
      final cubit = MilkingCubit(
        repository: _FakeMilkingRepository(),
        animalRepository: _FakeAnimalRepository(const []),
        lotesRepository: _FakeLotesRepository(const []),
      );
      await cubit.load();

      await cubit.finalize();

      expect(cubit.state.status, MilkingLoadStatus.failure);
      expect(cubit.state.errorMessage, contains('al menos una vaca'));
      await cubit.close();
    });
  });

  test('MilkingEntry exposes liters without losing milliliters', () {
    final now = DateTime(2026, 7, 21);
    final entry = MilkingEntry(
      uuid: 'entry-1',
      sessionUuid: 'session-1',
      animalUuid: 'cow-1',
      volumeMilliliters: 12750,
      createdAt: now,
      updatedAt: now,
    );

    expect(entry.liters, 12.75);
  });

  testWidgets('page supports individual and lote capture modes', (
    tester,
  ) async {
    final cow = _animal(uuid: 'cow-widget');
    final lote = _lote([cow.uuid]);
    locator
      ..registerSingleton<AnimalRepository>(_FakeAnimalRepository([cow]))
      ..registerSingleton<LotesRepository>(_FakeLotesRepository([lote]))
      ..registerSingleton<MilkingRepository>(_FakeMilkingRepository())
      ..registerSingleton<HealthRecordRepository>(
        _FakeHealthRecordRepository(const {}),
      );

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('es'),
        home: RegistroOrdenaPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Una por una'), findsOneWidget);
    expect(find.text('Seleccionar vaca'), findsOneWidget);

    await tester.tap(find.text('Por lote'));
    await tester.pumpAndSettle();
    expect(find.text('Grupo o lote de vacas'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vacas en producción (1)').last);
    await tester.pumpAndSettle();

    expect(find.text('cow-widget'), findsOneWidget);
    expect(find.text('Litros'), findsOneWidget);
  });

  testWidgets('keeps an older draft accessible after starting a new session', (
    tester,
  ) async {
    final cow = _animal(uuid: 'cow-old-draft');
    final oldSession = _session(
      'old-widget-session',
      DateTime.now().subtract(const Duration(days: 1)),
    );
    final oldEntry = _entry('old-widget-entry', oldSession, cow.uuid);
    locator
      ..registerSingleton<AnimalRepository>(_FakeAnimalRepository([cow]))
      ..registerSingleton<LotesRepository>(_FakeLotesRepository(const []))
      ..registerSingleton<MilkingRepository>(
        _FakeMilkingRepository(sessions: [oldSession], entries: [oldEntry]),
      )
      ..registerSingleton<HealthRecordRepository>(
        _FakeHealthRecordRepository(const {}),
      );

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('es'),
        home: RegistroOrdenaPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hay ordeñas anteriores sin finalizar'), findsOneWidget);
    await tester.tap(find.text('Nueva sesión'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Ordeñas guardadas (1)'), findsOneWidget);

    await tester.tap(find.byTooltip('Ordeñas guardadas (1)'));
    await tester.pumpAndSettle();
    expect(
      find.text(DateFormat('dd/MM/yyyy · HH:mm').format(oldSession.occurredAt)),
      findsOneWidget,
    );
    await tester.tap(find.text('Reanudar'));
    await tester.pumpAndSettle();

    expect(find.text('cow-old-draft'), findsOneWidget);
    expect(find.text('12.5 L'), findsWidgets);
  });
}

AnimalEntity _animal({
  required String uuid,
  Sex sex = Sex.female,
  AnimalStatus status = AnimalStatus.active,
}) {
  final now = DateTime(2026, 7, 21);
  return AnimalEntity(
    uuid: uuid,
    earTagNumber: uuid,
    species: Species.cattle,
    category: sex == Sex.female ? Category.cow : Category.bull,
    lifeStage: sex == Sex.female ? LifeStage.cow : LifeStage.bull,
    sex: sex,
    breed: 'Holstein',
    birthDate: DateTime(2021),
    ageMonths: 66,
    healthStatus: HealthStatus.good,
    vaccinated: true,
    dewormed: true,
    hasVitamins: true,
    hasChronicIssues: false,
    reproductiveStatus: ReproductiveStatus.unknown,
    productionPurpose: ProductionPurpose.dairy,
    productionStage: ProductionStage.lactating,
    productionSystem: ProductionSystem.intensive,
    underObservation: false,
    requiresAttention: false,
    riskLevel: RiskLevel.low,
    gallery: const [],
    status: status,
    synced: false,
    creationDate: now,
    lastUpdateDate: now,
  );
}

LoteEntity _lote(List<String> animals) {
  final now = DateTime(2026, 7, 21);
  return LoteEntity(
    uuid: 'lote-1',
    name: 'Vacas en producción',
    animalUuids: animals,
    createdAt: now,
    lastUpdateDate: now,
  );
}

class _FakeAnimalRepository implements AnimalRepository {
  _FakeAnimalRepository(this.animals);

  final List<AnimalEntity> animals;

  @override
  Future<List<AnimalEntity>> getAll() async => animals;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeLotesRepository implements LotesRepository {
  _FakeLotesRepository(this.lotes);

  final List<LoteEntity> lotes;

  @override
  Future<List<LoteEntity>> getActiveLotes() async => lotes;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHealthRecordRepository implements HealthRecordRepository {
  _FakeHealthRecordRepository(this._activeWithdrawals);

  final Map<String, DateTime> _activeWithdrawals;

  @override
  Future<Map<String, DateTime>> getActiveWithdrawals(
    Set<String> animalUuids, {
    DateTime? asOf,
  }) async {
    return {
      for (final uuid in animalUuids)
        if (_activeWithdrawals.containsKey(uuid))
          uuid: _activeWithdrawals[uuid]!,
    };
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeMilkingRepository implements MilkingRepository {
  _FakeMilkingRepository({
    List<MilkingSession> sessions = const [],
    List<MilkingEntry> entries = const [],
  }) : sessions = List.of(sessions),
       entries = List.of(entries);

  final List<MilkingSession> sessions;
  final List<MilkingEntry> entries;

  MilkingSession? get draft {
    final now = DateTime.now();
    for (final session in sessions.reversed) {
      if (session.status == MilkingStatus.draft &&
          session.occurredAt.year == now.year &&
          session.occurredAt.month == now.month &&
          session.occurredAt.day == now.day) {
        return session;
      }
    }
    return null;
  }

  @override
  Future<MilkingSession?> getOpenDraft() async => draft;

  @override
  Future<MilkingSession?> getSession(String uuid) async {
    for (final session in sessions) {
      if (session.uuid == uuid) return session;
    }
    return null;
  }

  @override
  Future<List<MilkingSession>> getAllSessions() async => List.of(sessions);

  @override
  Future<List<MilkingEntry>> getAllEntries() async => List.of(entries);

  @override
  Future<List<MilkingEntry>> getEntries(String sessionUuid) async => entries
      .where((entry) => entry.sessionUuid == sessionUuid)
      .toList(growable: false);

  @override
  Future<void> upsertSession(MilkingSession session) async {
    sessions.removeWhere((item) => item.uuid == session.uuid);
    sessions.add(session);
  }

  @override
  Future<MilkingEntry> upsertEntry(MilkingEntry entry) async {
    entries.removeWhere(
      (item) =>
          item.uuid == entry.uuid ||
          (item.sessionUuid == entry.sessionUuid &&
              item.animalUuid == entry.animalUuid),
    );
    entries.add(entry);
    return entry;
  }

  @override
  Future<void> deleteEntry(String uuid) async {
    entries.removeWhere((entry) => entry.uuid == uuid);
  }

  @override
  Future<void> finalizeSession(String sessionUuid) async {
    final index = sessions.indexWhere((session) => session.uuid == sessionUuid);
    if (index >= 0) {
      sessions[index] = sessions[index].copyWith(
        status: MilkingStatus.completed,
      );
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

MilkingSession _session(String uuid, DateTime occurredAt) => MilkingSession(
  uuid: uuid,
  occurredAt: occurredAt,
  shift: MilkingShift.morning,
  status: MilkingStatus.draft,
  createdAt: occurredAt,
  updatedAt: occurredAt,
);

MilkingEntry _entry(String uuid, MilkingSession session, String animalUuid) =>
    MilkingEntry(
      uuid: uuid,
      sessionUuid: session.uuid,
      animalUuid: animalUuid,
      volumeMilliliters: 12500,
      createdAt: session.occurredAt,
      updatedAt: session.occurredAt,
    );
