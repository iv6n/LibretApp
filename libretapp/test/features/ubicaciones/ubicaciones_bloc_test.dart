import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_bloc.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_event.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_state.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_records.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';

class _BlocFakeLocationRepository implements LocationRepository {
  _BlocFakeLocationRepository(List<LocationEntity> seed)
    : _data = List<LocationEntity>.from(seed),
      _controller = StreamController<List<LocationEntity>>.broadcast();

  final List<LocationEntity> _data;
  final StreamController<List<LocationEntity>> _controller;
  bool failOnUpsert = false;

  @override
  Stream<List<LocationEntity>> watchAll() {
    Future<void>.microtask(() {
      if (!_controller.isClosed) {
        _controller.add(List<LocationEntity>.from(_data));
      }
    });
    return _controller.stream;
  }

  @override
  Future<void> upsert(LocationEntity location) async {
    if (failOnUpsert) {
      throw StateError('Fallo de guardado');
    }

    final index = _data.indexWhere((item) => item.uuid == location.uuid);
    if (index >= 0) {
      _data[index] = location;
    } else {
      _data.add(location);
    }
    _controller.add(List<LocationEntity>.from(_data));
  }

  @override
  Future<List<LocationEntity>> getAll() async =>
      List<LocationEntity>.from(_data);

  @override
  Future<LocationEntity?> getByUuid(String uuid) async {
    try {
      return _data.firstWhere((item) => item.uuid == uuid);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteByUuid(String uuid) async {
    _data.removeWhere((item) => item.uuid == uuid);
    _controller.add(List<LocationEntity>.from(_data));
  }

  @override
  Future<void> addVisit(String uuid, VisitRecord record) async {}

  @override
  Future<void> addWater(String uuid, WaterRecord record) async {}

  @override
  Future<void> addSalt(String uuid, SaltRecord record) async {}

  @override
  Future<void> addShade(String uuid, ShadeRecord record) async {}

  @override
  Future<void> addPasture(String uuid, PastureRecord record) async {}

  @override
  Future<void> addSeeding(String uuid, SeedingRecord record) async {}

  @override
  Future<void> addIrrigation(String uuid, IrrigationRecord record) async {}

  @override
  Future<void> addRain(String uuid, RainRecord record) async {}

  @override
  Future<void> addCost(String uuid, CostRecord record) async {}

  Future<void> dispose() async {
    await _controller.close();
  }
}

LocationEntity _location({required String uuid, required String name}) {
  return LocationEntity(
    uuid: uuid,
    name: name,
    type: LocationType.potrero,
    surfaceArea: 10,
    capacity: 25,
    waterSource: 'Pozo',
    terrainType: 'Plano',
    status: 'activo',
  );
}

void main() {
  group('UbicacionesBloc upsert flow', () {
    test('guarda en repositorio y actualiza lista por stream', () async {
      final repository = _BlocFakeLocationRepository([
        _location(uuid: 'u1', name: 'Base'),
      ]);
      final bloc = UbicacionesBloc(repository);
      final emitted = <UbicacionesState>[];
      final subscription = bloc.stream.listen(emitted.add);

      bloc.add(const LoadUbicaciones());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      bloc.add(UpsertUbicacion(_location(uuid: 'u2', name: 'Nueva')));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final lastLoaded = emitted.whereType<UbicacionesLoaded>().last;
      expect(
        lastLoaded.allUbicaciones.any((item) => item.uuid == 'u2'),
        isTrue,
      );
      expect(
        lastLoaded.visibleUbicaciones.any((item) => item.uuid == 'u2'),
        isTrue,
      );

      await subscription.cancel();
      await bloc.close();
      await repository.dispose();
    });

    test('si falla el guardado emite UbicacionesError', () async {
      final repository = _BlocFakeLocationRepository([
        _location(uuid: 'u1', name: 'Base'),
      ]);
      repository.failOnUpsert = true;

      final bloc = UbicacionesBloc(repository);
      final emitted = <UbicacionesState>[];
      final subscription = bloc.stream.listen(emitted.add);

      bloc.add(const LoadUbicaciones());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      bloc.add(UpsertUbicacion(_location(uuid: 'u2', name: 'Nueva')));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(emitted.any((state) => state is UbicacionesError), isTrue);

      await subscription.cancel();
      await bloc.close();
      await repository.dispose();
    });
  });
}
