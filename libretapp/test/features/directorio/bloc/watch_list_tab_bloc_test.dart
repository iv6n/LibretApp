import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/bloc/animales_tab_bloc.dart';
import 'package:libretapp/features/directorio/bloc/animales_tab_event.dart';
import 'package:libretapp/features/directorio/bloc/animales_tab_state.dart';
import 'package:libretapp/features/directorio/bloc/lotes_tab_bloc.dart';
import 'package:libretapp/features/directorio/bloc/lotes_tab_event.dart';
import 'package:libretapp/features/directorio/bloc/lotes_tab_state.dart';
import 'package:libretapp/features/directorio/bloc/ubicaciones_tab_bloc.dart';
import 'package:libretapp/features/directorio/bloc/ubicaciones_tab_event.dart';
import 'package:libretapp/features/directorio/bloc/ubicaciones_tab_state.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';

import '../animales/advisor/rules/rule_test_fixtures.dart';

/// Covers the 3 directorio tab blocs (Animales/Lotes/Ubicaciones), which
/// share their load/search/error lifecycle via `WatchListTabBloc`. The
/// synchronous-throw and stream-error paths live entirely in that shared
/// base, so they're only exercised once (on AnimalesTabBloc) rather than
/// tripled across all 3 blocs.
class _FakeAnimalRepository implements AnimalRepository {
  _FakeAnimalRepository(List<AnimalEntity> seed)
    : _data = List<AnimalEntity>.from(seed),
      _controller = StreamController<List<AnimalEntity>>.broadcast();

  final List<AnimalEntity> _data;
  final StreamController<List<AnimalEntity>> _controller;
  bool throwOnWatch = false;

  @override
  Stream<List<AnimalEntity>> watchAll() {
    if (throwOnWatch) throw StateError('boom');
    Future<void>.microtask(() {
      if (!_controller.isClosed) {
        _controller.add(List<AnimalEntity>.from(_data));
      }
    });
    return _controller.stream;
  }

  void emitError(Object error) => _controller.addError(error);

  Future<void> dispose() => _controller.close();

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeLotesRepository implements LotesRepository {
  _FakeLotesRepository(List<LoteEntity> seed)
    : _data = List<LoteEntity>.from(seed),
      _controller = StreamController<List<LoteEntity>>.broadcast();

  final List<LoteEntity> _data;
  final StreamController<List<LoteEntity>> _controller;

  @override
  Stream<List<LoteEntity>> watchAll() {
    Future<void>.microtask(() {
      if (!_controller.isClosed) {
        _controller.add(List<LoteEntity>.from(_data));
      }
    });
    return _controller.stream;
  }

  Future<void> dispose() => _controller.close();

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeLocationRepository implements LocationRepository {
  _FakeLocationRepository(List<LocationEntity> seed)
    : _data = List<LocationEntity>.from(seed),
      _controller = StreamController<List<LocationEntity>>.broadcast();

  final List<LocationEntity> _data;
  final StreamController<List<LocationEntity>> _controller;

  @override
  Stream<List<LocationEntity>> watchAll() {
    Future<void>.microtask(() {
      if (!_controller.isClosed) {
        _controller.add(List<LocationEntity>.from(_data));
      }
    });
    return _controller.stream;
  }

  Future<void> dispose() => _controller.close();

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

AnimalEntity _animal({required String uuid, required String earTagNumber}) {
  return buildAnimal().copyWith(uuid: uuid, earTagNumber: earTagNumber);
}

LoteEntity _lote({required String uuid, required String name}) {
  return LoteEntity(
    uuid: uuid,
    name: name,
    createdAt: DateTime(2026, 1, 1),
    lastUpdateDate: DateTime(2026, 1, 1),
  );
}

LocationEntity _location({required String uuid, required String name}) {
  return LocationEntity(
    uuid: uuid,
    name: name,
    type: LocationType.pasture,
    surfaceArea: 10,
    capacity: 25,
    waterSource: 'Pozo',
    terrainType: 'Plano',
  );
}

void main() {
  group('AnimalesTabBloc', () {
    test('load emits Loading then Loaded with the watched animals', () async {
      final repo = _FakeAnimalRepository([
        _animal(uuid: 'a1', earTagNumber: '001'),
      ]);
      final bloc = AnimalesTabBloc(repo);
      final emitted = <AnimalesTabState>[];
      final sub = bloc.stream.listen(emitted.add);

      bloc.add(const LoadAnimalesTab());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(emitted.first, isA<AnimalesTabLoading>());
      expect(bloc.state, isA<AnimalesTabLoaded>());
      expect((bloc.state as AnimalesTabLoaded).animales, hasLength(1));

      await sub.cancel();
      await bloc.close();
      await repo.dispose();
    });

    test('search filters by ear tag and an empty query clears it', () async {
      final repo = _FakeAnimalRepository([
        _animal(uuid: 'a1', earTagNumber: '001'),
        _animal(uuid: 'a2', earTagNumber: '002'),
      ]);
      final bloc = AnimalesTabBloc(repo);

      bloc.add(const LoadAnimalesTab());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      bloc.add(const SearchAnimalesTab('001'));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      var loaded = bloc.state as AnimalesTabLoaded;
      expect(loaded.displayAnimales, hasLength(1));
      expect(loaded.displayAnimales.single.uuid, 'a1');

      bloc.add(const SearchAnimalesTab(''));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      loaded = bloc.state as AnimalesTabLoaded;
      expect(loaded.displayAnimales, hasLength(2));

      await bloc.close();
      await repo.dispose();
    });

    test('a synchronous throw from watchAll emits a prefixed error state', () async {
      final repo = _FakeAnimalRepository([])..throwOnWatch = true;
      final bloc = AnimalesTabBloc(repo);

      bloc.add(const LoadAnimalesTab());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state, isA<AnimalesTabError>());
      expect(
        (bloc.state as AnimalesTabError).message,
        contains('Error al cargar animales'),
      );

      await bloc.close();
    });

    test('a stream error emits an error state', () async {
      final repo = _FakeAnimalRepository([_animal(uuid: 'a1', earTagNumber: '001')]);
      final bloc = AnimalesTabBloc(repo);

      bloc.add(const LoadAnimalesTab());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(bloc.state, isA<AnimalesTabLoaded>());

      repo.emitError(StateError('conexión perdida'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state, isA<AnimalesTabError>());

      await bloc.close();
      await repo.dispose();
    });
  });

  group('LotesTabBloc', () {
    test('load emits Loading then Loaded with the watched lotes', () async {
      final repo = _FakeLotesRepository([_lote(uuid: 'l1', name: 'Lote 1')]);
      final bloc = LotesTabBloc(repo);
      final emitted = <LotesTabState>[];
      final sub = bloc.stream.listen(emitted.add);

      bloc.add(const LoadLotesTab());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(emitted.first, isA<LotesTabLoading>());
      expect(bloc.state, isA<LotesTabLoaded>());
      expect((bloc.state as LotesTabLoaded).lotes, hasLength(1));

      await sub.cancel();
      await bloc.close();
      await repo.dispose();
    });

    test('search filters by name and an empty query clears it', () async {
      final repo = _FakeLotesRepository([
        _lote(uuid: 'l1', name: 'Maternidad'),
        _lote(uuid: 'l2', name: 'Engorde'),
      ]);
      final bloc = LotesTabBloc(repo);

      bloc.add(const LoadLotesTab());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      bloc.add(const SearchLotesTab('mater'));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      var loaded = bloc.state as LotesTabLoaded;
      expect(loaded.displayLotes, hasLength(1));
      expect(loaded.displayLotes.single.uuid, 'l1');

      bloc.add(const SearchLotesTab(''));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      loaded = bloc.state as LotesTabLoaded;
      expect(loaded.displayLotes, hasLength(2));

      await bloc.close();
      await repo.dispose();
    });
  });

  group('UbicacionesTabBloc', () {
    test('load emits Loading then Loaded with the watched ubicaciones', () async {
      final repo = _FakeLocationRepository([_location(uuid: 'u1', name: 'Potrero 1')]);
      final bloc = UbicacionesTabBloc(repo);
      final emitted = <UbicacionesTabState>[];
      final sub = bloc.stream.listen(emitted.add);

      bloc.add(const LoadUbicacionesTab());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(emitted.first, isA<UbicacionesTabLoading>());
      expect(bloc.state, isA<UbicacionesTabLoaded>());
      expect((bloc.state as UbicacionesTabLoaded).ubicaciones, hasLength(1));

      await sub.cancel();
      await bloc.close();
      await repo.dispose();
    });

    test('search filters by name and an empty query clears it', () async {
      final repo = _FakeLocationRepository([
        _location(uuid: 'u1', name: 'Potrero Norte'),
        _location(uuid: 'u2', name: 'Corral Sur'),
      ]);
      final bloc = UbicacionesTabBloc(repo);

      bloc.add(const LoadUbicacionesTab());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      bloc.add(const SearchUbicacionesTab('norte'));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      var loaded = bloc.state as UbicacionesTabLoaded;
      expect(loaded.displayUbicaciones, hasLength(1));
      expect(loaded.displayUbicaciones.single.uuid, 'u1');

      bloc.add(const SearchUbicacionesTab(''));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      loaded = bloc.state as UbicacionesTabLoaded;
      expect(loaded.displayUbicaciones, hasLength(2));

      await bloc.close();
      await repo.dispose();
    });
  });
}
