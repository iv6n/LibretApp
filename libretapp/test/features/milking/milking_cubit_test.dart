import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/production_system.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/milking/milking.dart';

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
      ..registerSingleton<MilkingRepository>(_FakeMilkingRepository());

    await tester.pumpWidget(const MaterialApp(home: RegistroOrdenaPage()));
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

class _FakeMilkingRepository implements MilkingRepository {
  MilkingSession? draft;
  final List<MilkingEntry> entries = [];

  @override
  Future<MilkingSession?> getOpenDraft() async => draft;

  @override
  Future<List<MilkingEntry>> getEntries(String sessionUuid) async => entries
      .where((entry) => entry.sessionUuid == sessionUuid)
      .toList(growable: false);

  @override
  Future<void> upsertSession(MilkingSession session) async {
    draft = session;
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
    if (draft?.uuid == sessionUuid) {
      draft = draft!.copyWith(status: MilkingStatus.completed);
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
