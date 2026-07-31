import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_bloc.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_event.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_state.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_records.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_status.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/inventory_item.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_category.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';

class _BlocFakeLocationRepository implements LocationRepository {
  _BlocFakeLocationRepository(
    List<LocationEntity> seed, {
    this.emitInitialWatchEvent = true,
  }) : _data = List<LocationEntity>.from(seed),
       _controller = StreamController<List<LocationEntity>>.broadcast();

  final List<LocationEntity> _data;
  final StreamController<List<LocationEntity>> _controller;
  final bool emitInitialWatchEvent;
  bool failOnUpsert = false;

  @override
  Stream<List<LocationEntity>> watchAll() {
    if (emitInitialWatchEvent) {
      Future<void>.microtask(() {
        if (!_controller.isClosed) {
          _controller.add(List<LocationEntity>.from(_data));
        }
      });
    }
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
  Future<void> addCost(String uuid, LocationCostRecord record) async {}

  @override
  Future<void> addCrop(String locationUuid, CropRecord crop) async {}

  @override
  Future<void> updateCrop(String locationUuid, CropRecord crop) async {}

  @override
  Future<void> deleteCrop(String locationUuid, String cropUuid) async {}

  @override
  Future<void> addHarvest(
    String locationUuid,
    String cropUuid,
    HarvestRecord record,
  ) async {}

  @override
  Future<void> addCropWatering(
    String locationUuid,
    String cropUuid,
    CropWateringRecord record,
  ) async {}

  @override
  Future<void> addCropHealth(
    String locationUuid,
    String cropUuid,
    CropHealthRecord record,
  ) async {}

  @override
  Future<void> addCropTask(
    String locationUuid,
    String cropUuid,
    CropTask task,
  ) async {}

  @override
  Future<void> completeCropTask(
    String locationUuid,
    String cropUuid,
    String taskUuid,
  ) async {}

  @override
  Future<void> addInventoryItem(
    String locationUuid,
    InventoryItem item,
  ) async {}

  @override
  Future<void> updateInventoryItem(
    String locationUuid,
    InventoryItem item,
  ) async {}

  @override
  Future<void> removeInventoryItem(
    String locationUuid,
    String itemUuid,
  ) async {}

  Future<void> dispose() async {
    await _controller.close();
  }
}

LocationEntity _location({
  required String uuid,
  required String name,
  String? parentUuid,
  LocationType type = LocationType.pasture,
}) {
  return LocationEntity(
    uuid: uuid,
    name: name,
    parentUuid: parentUuid,
    type: type,
    surfaceArea: 10,
    capacity: 25,
    waterSource: 'Pozo',
    terrainType: 'Plano',
    status: LocationStatus.available,
  );
}

void main() {
  group('UbicacionesBloc upsert flow', () {
    test(
      'refleja en el stream un guardado hecho directo al repositorio '
      '(el formulario real guarda vía LocationRepository.upsert, no vía bloc)',
      () async {
        final repository = _BlocFakeLocationRepository([
          _location(uuid: 'u1', name: 'Base'),
        ]);
        final bloc = UbicacionesBloc(repository);
        final emitted = <UbicacionesState>[];
        final subscription = bloc.stream.listen(emitted.add);

        bloc.add(const LoadUbicaciones());
        await Future<void>.delayed(const Duration(milliseconds: 20));

        await repository.upsert(_location(uuid: 'u2', name: 'Nueva'));
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
      },
    );

    test('carga por bootstrap cuando watchAll no emite al inicio', () async {
      final repository = _BlocFakeLocationRepository([
        _location(uuid: 'u1', name: 'Base'),
      ], emitInitialWatchEvent: false);
      final bloc = UbicacionesBloc(repository);

      bloc.add(const LoadUbicaciones());
      await Future<void>.delayed(const Duration(milliseconds: 80));

      expect(bloc.state, isA<UbicacionesLoaded>());
      final loaded = bloc.state as UbicacionesLoaded;
      expect(loaded.allUbicaciones, hasLength(1));
      expect(loaded.allUbicaciones.first.uuid, 'u1');

      await bloc.close();
      await repository.dispose();
    });

    test('aplica filtro por categoria sobre resultados visibles', () async {
      final repository = _BlocFakeLocationRepository([
        _location(uuid: 'u1', name: 'Potrero', type: LocationType.pasture),
        _location(uuid: 'u2', name: 'Campo', type: LocationType.field),
      ]);
      final bloc = UbicacionesBloc(repository);

      bloc.add(const LoadUbicaciones());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      bloc.add(
        const ToggleCategoryFilter(
          category: LocationCategory.livestock,
          selected: true,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final loaded = bloc.state as UbicacionesLoaded;
      expect(loaded.selectedCategoryFilters, contains(LocationCategory.livestock));
      expect(loaded.visibleUbicaciones, hasLength(1));
      expect(loaded.visibleUbicaciones.first.uuid, 'u1');

      await bloc.close();
      await repository.dispose();
    });

    test('filtro de rancho incluye rancho y descendientes', () async {
      final repository = _BlocFakeLocationRepository([
        _location(uuid: 'rootA', name: 'Rancho A', type: LocationType.ranch),
        _location(
          uuid: 'childA',
          name: 'Potrero A',
          parentUuid: 'rootA',
          type: LocationType.pasture,
        ),
        _location(uuid: 'rootB', name: 'Rancho B', type: LocationType.ranch),
      ]);
      final bloc = UbicacionesBloc(repository);

      bloc.add(const LoadUbicaciones());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      bloc.add(const SelectParentFilter('rootA'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final loaded = bloc.state as UbicacionesLoaded;
      final visibleUuids = loaded.visibleUbicaciones.map((e) => e.uuid).toSet();
      expect(visibleUuids, contains('rootA'));
      expect(visibleUuids, contains('childA'));
      expect(visibleUuids, isNot(contains('rootB')));

      await bloc.close();
      await repository.dispose();
    });

  });
}
