import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/animal_entity.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/index.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/bloc/animales_tab_bloc.dart';
import 'package:libretapp/features/directorio/bloc/animales_tab_event.dart';
import 'package:libretapp/features/directorio/bloc/directorio_bloc.dart';
import 'package:libretapp/features/directorio/bloc/directorio_event.dart';
import 'package:libretapp/features/directorio/bloc/directorio_state.dart';
import 'package:libretapp/features/directorio/bloc/lotes_tab_bloc.dart';
import 'package:libretapp/features/directorio/bloc/lotes_tab_event.dart';
import 'package:libretapp/features/directorio/bloc/ubicaciones_tab_bloc.dart';
import 'package:libretapp/features/directorio/bloc/ubicaciones_tab_event.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';

void main() {
  group('DirectorioBloc search behavior', () {
    late AnimalesTabBloc animalesTabBloc;
    late LotesTabBloc lotesTabBloc;
    late UbicacionesTabBloc ubicacionesTabBloc;
    late DirectorioBloc directorioBloc;

    setUp(() async {
      animalesTabBloc = AnimalesTabBloc(_FakeAnimalRepository());
      lotesTabBloc = LotesTabBloc(_FakeLotesRepository());
      ubicacionesTabBloc = UbicacionesTabBloc(_FakeLocationRepository());

      directorioBloc = DirectorioBloc(
        animalesTabBloc: animalesTabBloc,
        lotesTabBloc: lotesTabBloc,
        ubicacionesTabBloc: ubicacionesTabBloc,
      );

      directorioBloc.add(const LoadDirectorioData());
      await _flushEvents();
    });

    tearDown(() async {
      await directorioBloc.close();
      await animalesTabBloc.close();
      await lotesTabBloc.close();
      await ubicacionesTabBloc.close();
    });

    test(
      'LoadDirectorioData leaves state loaded and triggers all tab loads',
      () async {
        final recordingAnimalesTabBloc = _RecordingAnimalesTabBloc(
          _FakeAnimalRepository(),
        );
        final recordingLotesTabBloc = _RecordingLotesTabBloc(
          _FakeLotesRepository(),
        );
        final recordingUbicacionesTabBloc = _RecordingUbicacionesTabBloc(
          _FakeLocationRepository(),
        );

        final bloc = DirectorioBloc(
          animalesTabBloc: recordingAnimalesTabBloc,
          lotesTabBloc: recordingLotesTabBloc,
          ubicacionesTabBloc: recordingUbicacionesTabBloc,
        );

        bloc.add(const LoadDirectorioData());
        await _flushEvents();

        expect(bloc.state, isA<DirectorioLoaded>());
        expect(
          recordingAnimalesTabBloc.recordedEvents.whereType<LoadAnimalesTab>(),
          hasLength(1),
        );
        expect(
          recordingLotesTabBloc.recordedEvents.whereType<LoadLotesTab>(),
          hasLength(1),
        );
        expect(
          recordingUbicacionesTabBloc.recordedEvents
              .whereType<LoadUbicacionesTab>(),
          hasLength(1),
        );

        await bloc.close();
        await recordingAnimalesTabBloc.close();
        await recordingLotesTabBloc.close();
        await recordingUbicacionesTabBloc.close();
      },
    );

    test('ignores ChangeDirectorioTab when bloc is not loaded', () async {
      final bloc = DirectorioBloc(
        animalesTabBloc: AnimalesTabBloc(_FakeAnimalRepository()),
        lotesTabBloc: LotesTabBloc(_FakeLotesRepository()),
        ubicacionesTabBloc: UbicacionesTabBloc(_FakeLocationRepository()),
      );

      expect(bloc.state, const DirectorioInitial());

      bloc.add(const ChangeDirectorioTab(1));
      await _flushEvents();

      expect(bloc.state, const DirectorioInitial());

      await bloc.close();
    });

    test('trims query and stores normalized searchQuery', () async {
      final location = _buildLocation(uuid: 'loc-1', name: 'Potrero Norte');
      ubicacionesTabBloc.add(UbicacionesTabStreamUpdated([location]));
      await _flushEvents();

      directorioBloc.add(const PerformCombinedSearch('  norte  '));
      await _flushEvents();

      final state = directorioBloc.state;
      expect(state, isA<DirectorioLoaded>());

      final loaded = state as DirectorioLoaded;
      expect(loaded.searchQuery, 'norte');
      expect(loaded.searchResults.length, 1);
      expect(loaded.searchResults.first.type, CombinedSearchType.ubicacion);
      expect(loaded.searchResults.first.id, 'loc-1');
    });

    test('search does not break and uses only loaded tabs', () async {
      final animal = _buildAnimal(
        uuid: 'animal-partial-1',
        earTagNumber: 'Coincide Animal',
      );
      final location = _buildLocation(
        uuid: 'ubic-partial-1',
        name: 'Coincide Ubicacion',
      );

      animalesTabBloc.add(AnimalesTabStreamUpdated([animal]));
      ubicacionesTabBloc.add(UbicacionesTabStreamUpdated([location]));
      await _flushEvents();

      directorioBloc.add(const PerformCombinedSearch('coincide'));
      await _flushEvents();

      final state = directorioBloc.state;
      expect(state, isA<DirectorioLoaded>());

      final loaded = state as DirectorioLoaded;
      expect(loaded.searchResults, hasLength(2));
      expect(
        loaded.searchResults.map((result) => result.type),
        containsAll([CombinedSearchType.animal, CombinedSearchType.ubicacion]),
      );
      expect(
        loaded.searchResults.where(
          (result) => result.type == CombinedSearchType.lote,
        ),
        isEmpty,
      );
    });

    test('matches by id even when name does not match', () async {
      final lote = _buildLote(
        uuid: 'lote-777',
        nombre: 'Sin coincidencia nominal',
      );
      lotesTabBloc.add(LotesTabStreamUpdated([lote]));
      await _flushEvents();

      directorioBloc.add(const PerformCombinedSearch('777'));
      await _flushEvents();

      final state = directorioBloc.state;
      expect(state, isA<DirectorioLoaded>());

      final loaded = state as DirectorioLoaded;
      expect(loaded.searchResults.length, 1);
      expect(loaded.searchResults.first.type, CombinedSearchType.lote);
      expect(loaded.searchResults.first.id, 'lote-777');
    });

    test('deduplicates repeated entries with same type and id', () async {
      final duplicatedA = _buildLote(
        uuid: 'lote-dup',
        nombre: 'Lote Duplicado A',
      );
      final duplicatedB = _buildLote(
        uuid: 'lote-dup',
        nombre: 'Lote Duplicado B',
      );

      lotesTabBloc.add(LotesTabStreamUpdated([duplicatedA, duplicatedB]));
      await _flushEvents();

      directorioBloc.add(const PerformCombinedSearch('dup'));
      await _flushEvents();

      final state = directorioBloc.state;
      expect(state, isA<DirectorioLoaded>());

      final loaded = state as DirectorioLoaded;
      final duplicated = loaded.searchResults
          .where(
            (result) =>
                result.type == CombinedSearchType.lote &&
                result.id == 'lote-dup',
          )
          .toList();

      expect(duplicated.length, 1);
    });

    test('keeps stable input order for ties inside same category', () async {
      final loteUno = _buildLote(uuid: 'lote-ord-1', nombre: 'Lote Match Uno');
      final loteDos = _buildLote(uuid: 'lote-ord-2', nombre: 'Lote Match Dos');

      lotesTabBloc.add(LotesTabStreamUpdated([loteUno, loteDos]));
      await _flushEvents();

      directorioBloc.add(const ChangeDirectorioTab(1));
      await _flushEvents();

      directorioBloc.add(const PerformCombinedSearch('match'));
      await _flushEvents();

      final loaded = directorioBloc.state as DirectorioLoaded;
      final lotes = loaded.searchResults
          .where((result) => result.type == CombinedSearchType.lote)
          .toList();

      expect(lotes, hasLength(2));
      expect(lotes.first.id, 'lote-ord-1');
      expect(lotes.last.id, 'lote-ord-2');
    });

    test('uses customName for animal result when available', () async {
      final animal = _buildAnimal(
        uuid: 'animal-custom-1',
        earTagNumber: 'CARAVANA-001',
        customName: '  Lola  ',
      );

      animalesTabBloc.add(AnimalesTabStreamUpdated([animal]));
      await _flushEvents();

      directorioBloc.add(const PerformCombinedSearch('lola'));
      await _flushEvents();

      final loaded = directorioBloc.state as DirectorioLoaded;
      expect(loaded.searchResults, hasLength(1));
      expect(loaded.searchResults.first.type, CombinedSearchType.animal);
      expect(loaded.searchResults.first.name, 'Lola');
    });

    test('search is case-insensitive with mixed spaces and accents', () async {
      final location = _buildLocation(
        uuid: 'ubic-accents-1',
        name: 'Pótrero Norte',
      );

      ubicacionesTabBloc.add(UbicacionesTabStreamUpdated([location]));
      await _flushEvents();

      directorioBloc.add(const PerformCombinedSearch('  póTrErO  '));
      await _flushEvents();

      final loaded = directorioBloc.state as DirectorioLoaded;
      expect(loaded.searchResults, hasLength(1));
      expect(loaded.searchResults.first.type, CombinedSearchType.ubicacion);
      expect(loaded.searchResults.first.id, 'ubic-accents-1');
      expect(loaded.searchQuery, 'pótrero');
    });

    test(
      'does not deduplicate duplicated ids across different categories',
      () async {
        final animal = _buildAnimal(
          uuid: 'duplicado-1',
          earTagNumber: 'Sin Coincidencia',
        );
        final lote = _buildLote(
          uuid: 'duplicado-1',
          nombre: 'Lote Duplicado Cross Tipo',
        );

        animalesTabBloc.add(AnimalesTabStreamUpdated([animal]));
        lotesTabBloc.add(LotesTabStreamUpdated([lote]));
        await _flushEvents();

        directorioBloc.add(const PerformCombinedSearch('duplicado-1'));
        await _flushEvents();

        final loaded = directorioBloc.state as DirectorioLoaded;
        expect(loaded.searchResults, hasLength(2));
        expect(
          loaded.searchResults.map((result) => result.type),
          containsAll([CombinedSearchType.animal, CombinedSearchType.lote]),
        );
      },
    );

    test(
      'basic performance regression: search handles medium lists quickly',
      () async {
        final animales = List<AnimalEntity>.generate(
          300,
          (index) => _buildAnimal(
            uuid: 'animal-perf-$index',
            earTagNumber: 'Item Animal $index',
          ),
        );
        final lotes = List<LoteEntity>.generate(
          300,
          (index) =>
              _buildLote(uuid: 'lote-perf-$index', nombre: 'Item Lote $index'),
        );
        final ubicaciones = List<LocationEntity>.generate(
          300,
          (index) => _buildLocation(
            uuid: 'ubic-perf-$index',
            name: 'Item Ubicacion $index',
          ),
        );

        animalesTabBloc.add(AnimalesTabStreamUpdated(animales));
        lotesTabBloc.add(LotesTabStreamUpdated(lotes));
        ubicacionesTabBloc.add(UbicacionesTabStreamUpdated(ubicaciones));
        await _flushEvents();

        final stopwatch = Stopwatch()..start();
        directorioBloc.add(const PerformCombinedSearch('item'));
        await _flushEvents();
        stopwatch.stop();

        final loaded = directorioBloc.state as DirectorioLoaded;
        expect(loaded.searchResults, hasLength(900));
        expect(stopwatch.elapsedMilliseconds, lessThan(2500));
      },
    );

    test('prioritizes lotes when lotes tab is active', () async {
      final lote = _buildLote(uuid: 'lote-prio', nombre: 'Coincidente Lote');
      final location = _buildLocation(
        uuid: 'ubic-prio',
        name: 'Coincidente Ubicacion',
      );

      lotesTabBloc.add(LotesTabStreamUpdated([lote]));
      ubicacionesTabBloc.add(UbicacionesTabStreamUpdated([location]));
      await _flushEvents();

      directorioBloc.add(const ChangeDirectorioTab(1));
      await _flushEvents();

      directorioBloc.add(const PerformCombinedSearch('coincidente'));
      await _flushEvents();

      final state = directorioBloc.state;
      expect(state, isA<DirectorioLoaded>());

      final loaded = state as DirectorioLoaded;
      expect(loaded.searchResults.length, 2);
      expect(loaded.searchResults.first.type, CombinedSearchType.lote);
      expect(loaded.searchResults[1].type, CombinedSearchType.ubicacion);
    });

    test('prioritizes ubicaciones when ubicaciones tab is active', () async {
      final lote = _buildLote(uuid: 'lote-prio-2', nombre: 'Coincidente Lote');
      final location = _buildLocation(
        uuid: 'ubic-prio-2',
        name: 'Coincidente Ubicacion',
      );

      lotesTabBloc.add(LotesTabStreamUpdated([lote]));
      ubicacionesTabBloc.add(UbicacionesTabStreamUpdated([location]));
      await _flushEvents();

      directorioBloc.add(const ChangeDirectorioTab(2));
      await _flushEvents();

      directorioBloc.add(const PerformCombinedSearch('coincidente'));
      await _flushEvents();

      final state = directorioBloc.state;
      expect(state, isA<DirectorioLoaded>());

      final loaded = state as DirectorioLoaded;
      expect(loaded.searchResults.length, 2);
      expect(loaded.searchResults.first.type, CombinedSearchType.ubicacion);
      expect(loaded.searchResults[1].type, CombinedSearchType.lote);
    });

    test('clear search resets searching flag, query and results', () async {
      final lote = _buildLote(uuid: 'lote-clear-1', nombre: 'Lote Limpiable');
      lotesTabBloc.add(LotesTabStreamUpdated([lote]));
      await _flushEvents();

      directorioBloc.add(const StartSearch());
      await _flushEvents();

      directorioBloc.add(const PerformCombinedSearch('limpiable'));
      await _flushEvents();

      final beforeClear = directorioBloc.state;
      expect(beforeClear, isA<DirectorioLoaded>());
      final loadedBeforeClear = beforeClear as DirectorioLoaded;
      expect(loadedBeforeClear.isSearching, isTrue);
      expect(loadedBeforeClear.searchQuery, 'limpiable');
      expect(loadedBeforeClear.searchResults, isNotEmpty);

      directorioBloc.add(const ClearSearch());
      await _flushEvents();

      final afterClear = directorioBloc.state;
      expect(afterClear, isA<DirectorioLoaded>());
      final loadedAfterClear = afterClear as DirectorioLoaded;
      expect(loadedAfterClear.isSearching, isFalse);
      expect(loadedAfterClear.searchQuery, isEmpty);
      expect(loadedAfterClear.searchResults, isEmpty);
    });

    test('change tab updates index and clears search state', () async {
      final lote = _buildLote(uuid: 'lote-tab-1', nombre: 'Lote Cambio Tab');
      lotesTabBloc.add(LotesTabStreamUpdated([lote]));
      await _flushEvents();

      directorioBloc.add(const StartSearch());
      await _flushEvents();

      directorioBloc.add(const PerformCombinedSearch('cambio'));
      await _flushEvents();

      directorioBloc.add(const ChangeDirectorioTab(2));
      await _flushEvents();

      final state = directorioBloc.state;
      expect(state, isA<DirectorioLoaded>());

      final loaded = state as DirectorioLoaded;
      expect(loaded.activeTabIndex, 2);
      expect(loaded.isSearching, isFalse);
      expect(loaded.searchQuery, isEmpty);
      expect(loaded.searchResults, isEmpty);
    });

    test(
      'empty query clears previous results and resets searchQuery',
      () async {
        final lote = _buildLote(uuid: 'lote-empty-1', nombre: 'Lote Vacio');
        lotesTabBloc.add(LotesTabStreamUpdated([lote]));
        await _flushEvents();

        directorioBloc.add(const StartSearch());
        await _flushEvents();

        directorioBloc.add(const PerformCombinedSearch('vacio'));
        await _flushEvents();

        final stateWithResults = directorioBloc.state as DirectorioLoaded;
        expect(stateWithResults.searchResults, isNotEmpty);
        expect(stateWithResults.searchQuery, 'vacio');

        directorioBloc.add(const PerformCombinedSearch('   '));
        await _flushEvents();

        final stateAfterEmpty = directorioBloc.state;
        expect(stateAfterEmpty, isA<DirectorioLoaded>());

        final loadedAfterEmpty = stateAfterEmpty as DirectorioLoaded;
        expect(loadedAfterEmpty.searchResults, isEmpty);
        expect(loadedAfterEmpty.searchQuery, isEmpty);
      },
    );

    test(
      'when lotes tab has no matches, fallback order is animal then ubicacion',
      () async {
        final animal = _buildAnimal(
          uuid: 'animal-fallback-1',
          earTagNumber: 'Match Animal',
        );
        final lote = _buildLote(uuid: 'lote-fallback-1', nombre: 'No Coincide');
        final location = _buildLocation(
          uuid: 'ubic-fallback-1',
          name: 'Match Ubicacion',
        );

        animalesTabBloc.add(AnimalesTabStreamUpdated([animal]));
        lotesTabBloc.add(LotesTabStreamUpdated([lote]));
        ubicacionesTabBloc.add(UbicacionesTabStreamUpdated([location]));
        await _flushEvents();

        directorioBloc.add(const ChangeDirectorioTab(1));
        await _flushEvents();

        directorioBloc.add(const PerformCombinedSearch('match'));
        await _flushEvents();

        final state = directorioBloc.state;
        expect(state, isA<DirectorioLoaded>());

        final loaded = state as DirectorioLoaded;
        expect(loaded.searchResults.length, 2);
        expect(loaded.searchResults.first.type, CombinedSearchType.animal);
        expect(loaded.searchResults[1].type, CombinedSearchType.ubicacion);
      },
    );

    test(
      'when ubicaciones tab has no matches, fallback order is animal then lote',
      () async {
        final animal = _buildAnimal(
          uuid: 'animal-fallback-2',
          earTagNumber: 'Match Animal Dos',
        );
        final lote = _buildLote(
          uuid: 'lote-fallback-2',
          nombre: 'Match Lote Dos',
        );
        final location = _buildLocation(
          uuid: 'ubic-fallback-2',
          name: 'No Coincide',
        );

        animalesTabBloc.add(AnimalesTabStreamUpdated([animal]));
        lotesTabBloc.add(LotesTabStreamUpdated([lote]));
        ubicacionesTabBloc.add(UbicacionesTabStreamUpdated([location]));
        await _flushEvents();

        directorioBloc.add(const ChangeDirectorioTab(2));
        await _flushEvents();

        directorioBloc.add(const PerformCombinedSearch('match'));
        await _flushEvents();

        final state = directorioBloc.state;
        expect(state, isA<DirectorioLoaded>());

        final loaded = state as DirectorioLoaded;
        expect(loaded.searchResults.length, 2);
        expect(loaded.searchResults.first.type, CombinedSearchType.animal);
        expect(loaded.searchResults[1].type, CombinedSearchType.lote);
      },
    );
  });
}

Future<void> _flushEvents() async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
}

LoteEntity _buildLote({required String uuid, required String nombre}) {
  final now = DateTime(2024, 1, 1);
  return LoteEntity(
    uuid: uuid,
    nombre: nombre,
    fechaCreacion: now,
    lastUpdateDate: now,
  );
}

AnimalEntity _buildAnimal({
  required String uuid,
  required String earTagNumber,
  String? customName,
}) {
  final now = DateTime(2024, 1, 1);
  return AnimalEntity(
    uuid: uuid,
    earTagNumber: earTagNumber,
    customName: customName,
    species: Species.cattle,
    category: Category.cow,
    lifeStage: LifeStage.cow,
    sex: Sex.female,
    breed: 'Generic',
    birthDate: DateTime(2022, 1, 1),
    ageMonths: 24,
    healthStatus: HealthStatus.good,
    vaccinated: false,
    dewormed: false,
    hasVitamins: false,
    hasChronicIssues: false,
    reproductiveStatus: ReproductiveStatus.active,
    productionPurpose: ProductionPurpose.dairy,
    productionStage: ProductionStage.growth,
    productionSystem: ProductionSystem.intensive,
    underObservation: false,
    requiresAttention: false,
    riskLevel: RiskLevel.low,
    gallery: const [],
    synced: true,
    creationDate: now,
    lastUpdateDate: now,
  );
}

LocationEntity _buildLocation({required String uuid, required String name}) {
  return LocationEntity(
    uuid: uuid,
    name: name,
    type: LocationType.potrero,
    surfaceArea: 1,
    capacity: 10,
    waterSource: 'Ninguna',
    terrainType: 'Plano',
    status: 'activa',
  );
}

class _FakeAnimalRepository implements AnimalRepository {
  @override
  Stream<List<AnimalEntity>> watchAll() => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeLotesRepository implements LotesRepository {
  @override
  Stream<List<LoteEntity>> watchAll() => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeLocationRepository implements LocationRepository {
  @override
  Stream<List<LocationEntity>> watchAll() => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _RecordingAnimalesTabBloc extends AnimalesTabBloc {
  _RecordingAnimalesTabBloc(super.repository);

  final List<AnimalesTabEvent> recordedEvents = <AnimalesTabEvent>[];

  @override
  void onEvent(AnimalesTabEvent event) {
    recordedEvents.add(event);
    super.onEvent(event);
  }
}

class _RecordingLotesTabBloc extends LotesTabBloc {
  _RecordingLotesTabBloc(super.repository);

  final List<LotesTabEvent> recordedEvents = <LotesTabEvent>[];

  @override
  void onEvent(LotesTabEvent event) {
    recordedEvents.add(event);
    super.onEvent(event);
  }
}

class _RecordingUbicacionesTabBloc extends UbicacionesTabBloc {
  _RecordingUbicacionesTabBloc(super.repository);

  final List<UbicacionesTabEvent> recordedEvents = <UbicacionesTabEvent>[];

  @override
  void onEvent(UbicacionesTabEvent event) {
    recordedEvents.add(event);
    super.onEvent(event);
  }
}
