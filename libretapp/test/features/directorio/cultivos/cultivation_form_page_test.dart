import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_repository.dart';
import 'package:libretapp/features/directorio/cultivos/view/cultivation_form_page.dart';
import 'package:libretapp/features/directorio/cultivos/view/cultivos_list_view.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_status.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final brightness in [Brightness.light, Brightness.dark]) {
    testWidgets(
      'formulario cabe en pantalla pequeña y respeta SafeArea en ${brightness.name}',
      (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        tester.view.padding = const FakeViewPadding(top: 28, bottom: 20);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPadding);

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: brightness, useMaterial3: true),
            home: CultivationFormPage(
              repository: _FakeCultivationRepository(),
              locationRepository: _FakeLocationRepository(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Nueva planta o cultivo'), findsOneWidget);
        expect(find.text('¿Qué vas a seguir?'), findsOneWidget);
        expect(find.text('Guardar cultivo'), findsOneWidget);
        expect(tester.takeException(), isNull);
        expect(
          tester.getTopLeft(find.text('Nueva planta o cultivo')).dy,
          greaterThanOrEqualTo(28),
        );

        tester.view.viewInsets = const FakeViewPadding(bottom: 240);
        addTearDown(tester.view.resetViewInsets);
        final nameField = find.widgetWithText(
          TextFormField,
          'Nombre o especie *',
        );
        await tester.ensureVisible(nameField);
        await tester.tap(nameField);
        await tester.pump();
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -500),
        );
        await tester.pumpAndSettle();

        expect(find.text('Guardar cultivo'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('muestra advertencia de superficie sin bloquear el registro', (
    tester,
  ) async {
    const location = LocationEntity(
      uuid: 'small-field',
      name: 'Parcela pequeña',
      type: LocationType.field,
      surfaceArea: 1,
      capacity: 0,
      waterSource: '',
      terrainType: '',
      status: LocationStatus.available,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CultivationFormPage(
          presetLocationUuid: location.uuid,
          repository: _FakeCultivationRepository(),
          locationRepository: _FakeLocationRepository([location]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Siembra por superficie'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Superficie *'),
      '20000',
    );
    await tester.pump();

    expect(
      find.text(
        'La superficie supera lo disponible. Puedes guardar si es un cultivo intercalado.',
      ),
      findsOneWidget,
    );
    expect(find.text('Guardar cultivo'), findsOneWidget);
  });

  testWidgets(
    'conserva los cultivos cargados si el watcher inicia con una lista vacía',
    (tester) async {
      final initial = CultivationEntity(
        uuid: 'initial-crop',
        name: 'Maíz blanco',
        variety: 'Criollo',
        plantingDate: DateTime(2026, 9, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CultivosListView(
            shellInteractionsEnabled: false,
            repository: _BootstrapRaceCultivationRepository(initial),
            locationRepository: _FakeLocationRepository(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Todos 1'), findsOneWidget);
      expect(find.text('Maíz blanco'), findsOneWidget);
      expect(find.text('Registra tu primer cultivo'), findsNothing);
    },
  );

  testWidgets('mantiene una sola carga y actualiza sin reemplazar la lista', (
    tester,
  ) async {
    final initial = CultivationEntity(
      uuid: 'stable-crop',
      name: 'Maíz estable',
      plantingDate: DateTime(2026, 9, 1),
    );
    final repository = _CountingCultivationRepository(initial);
    addTearDown(repository.close);

    await tester.pumpWidget(
      MaterialApp(
        home: _RebuildCultivosHarness(
          repository: repository,
          locationRepository: _FakeLocationRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.getAllCalls, 1);
    expect(repository.watchAllCalls, 1);
    expect(find.text('Maíz estable'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.tap(find.byKey(const ValueKey('cultivos-filter-active')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('rebuild-cultivos')));
    await tester.pump();

    expect(repository.getAllCalls, 1);
    expect(repository.watchAllCalls, 1);
    expect(
      tester.widget<FilterChip>(find.byType(FilterChip).at(1)).selected,
      isTrue,
    );

    repository.emit(initial.copyWith(name: 'Maíz actualizado'));
    await tester.pump();

    expect(find.text('Maíz actualizado'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}

class _RebuildCultivosHarness extends StatefulWidget {
  const _RebuildCultivosHarness({
    required this.repository,
    required this.locationRepository,
  });

  final CultivationRepository repository;
  final LocationRepository locationRepository;

  @override
  State<_RebuildCultivosHarness> createState() =>
      _RebuildCultivosHarnessState();
}

class _RebuildCultivosHarnessState extends State<_RebuildCultivosHarness> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          key: const ValueKey('rebuild-cultivos'),
          onPressed: () => setState(() {}),
          child: const Text('Reconstruir'),
        ),
        Expanded(
          child: CultivosListView(
            shellInteractionsEnabled: false,
            repository: widget.repository,
            locationRepository: widget.locationRepository,
          ),
        ),
      ],
    );
  }
}

class _BootstrapRaceCultivationRepository extends _FakeCultivationRepository {
  _BootstrapRaceCultivationRepository(this.initial);

  final CultivationEntity initial;

  @override
  Future<List<CultivationEntity>> getAll({
    bool includeArchived = false,
  }) async => [initial];

  @override
  Stream<List<CultivationEntity>> watchAll({bool includeArchived = false}) =>
      Stream.value(const []);
}

class _CountingCultivationRepository extends _FakeCultivationRepository {
  _CountingCultivationRepository(this.initial);

  final CultivationEntity initial;
  final StreamController<List<CultivationEntity>> _updates =
      StreamController<List<CultivationEntity>>.broadcast();
  int getAllCalls = 0;
  int watchAllCalls = 0;
  bool _initialEmitted = false;

  @override
  Future<List<CultivationEntity>> getAll({bool includeArchived = false}) async {
    getAllCalls++;
    return [initial];
  }

  @override
  Stream<List<CultivationEntity>> watchAll({bool includeArchived = false}) {
    watchAllCalls++;
    if (!_initialEmitted) {
      _initialEmitted = true;
      Future<void>.microtask(() => _updates.add([initial]));
    }
    return _updates.stream;
  }

  void emit(CultivationEntity cultivation) {
    _updates.add([cultivation]);
  }

  Future<void> close() => _updates.close();
}

class _FakeCultivationRepository implements CultivationRepository {
  @override
  Future<List<CultivationEntity>> getAll({
    bool includeArchived = false,
  }) async => const [];

  @override
  Future<CultivationEntity?> getByUuid(String uuid) async => null;

  @override
  Stream<List<CultivationEntity>> watchAll({bool includeArchived = false}) =>
      Stream.value(const []);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeLocationRepository implements LocationRepository {
  _FakeLocationRepository([this._data = const []]);

  final List<LocationEntity> _data;

  @override
  Stream<List<LocationEntity>> watchAll() => Stream.value(_data);

  @override
  Future<List<LocationEntity>> getAll() async => _data;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
