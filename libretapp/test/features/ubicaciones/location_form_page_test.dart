import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_bloc.dart';
import 'package:libretapp/features/ubicaciones/bloc/ubicaciones_event.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_records.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_status.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/inventory_item.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/features/ubicaciones/view/location_form_page.dart';

class _FormFakeLocationRepository implements LocationRepository {
  _FormFakeLocationRepository(List<LocationEntity> seed)
    : _data = List<LocationEntity>.from(seed),
      _controller = StreamController<List<LocationEntity>>.broadcast();

  final List<LocationEntity> _data;
  final StreamController<List<LocationEntity>> _controller;
  LocationEntity? lastUpsert;
  Completer<void>? upsertCompleter;
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
    final pending = upsertCompleter;
    if (pending != null) {
      await pending.future;
    }

    if (failOnUpsert) {
      throw StateError('fallo de guardado');
    }

    lastUpsert = location;

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

class _CountingNavigatorObserver extends NavigatorObserver {
  int popCount = 0;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    popCount++;
    super.didPop(route, previousRoute);
  }
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
    status: LocationStatus.available,
  );
}

Widget _buildTestHost(UbicacionesBloc bloc, NavigatorObserver observer) {
  return BlocProvider.value(
    value: bloc,
    child: MaterialApp(
      navigatorObservers: [observer],
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const LocationFormPage(),
                    ),
                  );
                },
                child: const Text('Abrir formulario'),
              ),
            ),
          );
        },
      ),
    ),
  );
}

Future<void> _fillValidForm(WidgetTester tester) async {
  await tester.enterText(find.byType(TextFormField).at(0), 'Nueva ubicación');
  await tester.enterText(find.byType(TextFormField).at(1), '15.5');
  await tester.enterText(find.byType(TextFormField).at(2), '30');
  await tester.enterText(find.byType(TextFormField).at(3), 'Tanque');
  await tester.enterText(find.byType(TextFormField).at(4), 'Semi plano');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocationFormPage submit flow', () {
    late _FormFakeLocationRepository repository;
    late UbicacionesBloc bloc;
    late _CountingNavigatorObserver observer;

    setUp(() {
      if (locator.isRegistered<LocationRepository>()) {
        locator.unregister<LocationRepository>();
      }

      repository = _FormFakeLocationRepository([
        _location(uuid: 'base', name: 'Base'),
      ]);
      locator.registerSingleton<LocationRepository>(repository);

      bloc = UbicacionesBloc(repository)..add(const LoadUbicaciones());
      observer = _CountingNavigatorObserver();
    });

    tearDown(() async {
      await bloc.close();
      await repository.dispose();
      if (locator.isRegistered<LocationRepository>()) {
        locator.unregister<LocationRepository>();
      }
    });

    testWidgets('cierra pantalla solo cuando el guardado finaliza con éxito', (
      tester,
    ) async {
      repository.upsertCompleter = Completer<void>();

      await tester.pumpWidget(_buildTestHost(bloc, observer));
      await tester.tap(find.text('Abrir formulario'));
      await tester.pumpAndSettle();

      await _fillValidForm(tester);
      await tester.ensureVisible(find.text('Crear ubicación'));
      await tester.tap(find.text('Crear ubicación'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(observer.popCount, 0);

      repository.upsertCompleter!.complete();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 100));

      expect(observer.popCount, 1);
      expect(find.text('Abrir formulario'), findsOneWidget);
    });

    testWidgets('si falla el guardado mantiene el formulario abierto', (
      tester,
    ) async {
      repository.failOnUpsert = true;

      await tester.pumpWidget(_buildTestHost(bloc, observer));
      await tester.tap(find.text('Abrir formulario'));
      await tester.pumpAndSettle();

      await _fillValidForm(tester);
      await tester.ensureVisible(find.text('Crear ubicación'));
      await tester.tap(find.text('Crear ubicación'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Crear ubicación'), findsOneWidget);
      expect(observer.popCount, 0);
    });

    testWidgets(
      'guarda propiedades adaptativas en fields dedicados y attributes',
      (tester) async {
        await tester.pumpWidget(_buildTestHost(bloc, observer));
        await tester.tap(find.text('Abrir formulario'));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(ChoiceChip).first);
        await tester.pump();

        await _fillValidForm(tester);

        await tester.enterText(
          find.byType(TextFormField).at(7),
          '{"type":"Point","coordinates":[-99.1,19.3]}',
        );
        await tester.enterText(find.byType(TextFormField).at(5), 'RCH-001');
        await tester.ensureVisible(find.byType(Switch).first);
        await tester.tap(find.byType(Switch).first);

        await tester.ensureVisible(find.text('Crear ubicación'));
        await tester.tap(find.text('Crear ubicación'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        final saved = repository.lastUpsert;
        expect(saved, isNotNull);
        expect(saved!.isShared, isTrue);
        expect(saved.geometry, '{"type":"Point","coordinates":[-99.1,19.3]}');

        final geometryAttr = saved.attributes.firstWhere(
          (item) => item.key == 'geometry',
        );
        final registryAttr = saved.attributes.firstWhere(
          (item) => item.key == 'registryCode',
        );
        final sharedAttr = saved.attributes.firstWhere(
          (item) => item.key == 'isShared',
        );

        expect(
          geometryAttr.textValue,
          '{"type":"Point","coordinates":[-99.1,19.3]}',
        );
        expect(registryAttr.textValue, 'RCH-001');
        expect(sharedAttr.boolValue, isTrue);
      },
    );
  });
}
