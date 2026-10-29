import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/widgets/app_directory_filter_chip.dart';
import 'package:libretapp/features/directorio/lotes/bloc/lotes_bloc.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/directorio/lotes/lotes_list_view.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'package:libretapp/theme/app_theme.dart';

class _SingleSubscriptionLocations implements LocationRepository {
  final changes = StreamController<List<LocationEntity>>();
  int watchCalls = 0;

  @override
  Stream<List<LocationEntity>> watchAll() {
    watchCalls++;
    return changes.stream;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeLotesRepository implements LotesRepository {
  _FakeLotesRepository(this._lotes);

  final List<LoteEntity> _lotes;
  final List<String> deletedUuids = [];

  @override
  Stream<List<LoteEntity>> watchAll() =>
      Stream.value(List<LoteEntity>.from(_lotes));

  @override
  Future<List<LoteEntity>> getAll() async => List<LoteEntity>.from(_lotes);

  @override
  Future<void> upsert(LoteEntity lote) async {
    final index = _lotes.indexWhere((value) => value.uuid == lote.uuid);
    if (index >= 0) {
      _lotes[index] = lote;
      return;
    }
    _lotes.add(lote);
  }

  @override
  Future<void> clearAll() async {
    _lotes.clear();
  }

  @override
  Future<LoteEntity?> getByUuid(String uuid) async {
    for (final lote in _lotes) {
      if (lote.uuid == uuid) return lote;
    }
    return null;
  }

  @override
  Future<LoteEntity> createLote({
    required String nombre,
    String? descripcion,
    String? notas,
    double? feedPricePerKg,
    double? dailyFeedKgPerHead,
    double? liveWeightPricePerKg,
  }) async {
    final lote = LoteEntity(
      uuid: 'created-$nombre',
      name: nombre,
      description: descripcion,
      notes: notas,
      createdAt: DateTime(2024, 1, 1),
      lastUpdateDate: DateTime(2024, 1, 1),
      feedPricePerKg: feedPricePerKg,
      dailyFeedKgPerHead: dailyFeedKgPerHead,
      liveWeightPricePerKg: liveWeightPricePerKg,
    );
    _lotes.add(lote);
    return lote;
  }

  @override
  Future<void> updateLote(LoteEntity lote) async {
    final index = _lotes.indexWhere((value) => value.uuid == lote.uuid);
    if (index >= 0) {
      _lotes[index] = lote;
    }
  }

  @override
  Future<void> deleteLote(String uuid) async {
    deletedUuids.add(uuid);
    _lotes.removeWhere((lote) => lote.uuid == uuid);
  }

  @override
  Future<void> purge(String uuid) async {
    deletedUuids.add(uuid);
    _lotes.removeWhere((lote) => lote.uuid == uuid);
  }

  @override
  Future<void> addAnimalToLote({
    required String loteUuid,
    required String animalUuid,
  }) async {}

  @override
  Future<void> addAnimalsToLote({
    required String loteUuid,
    required List<String> animalUuids,
  }) async {}

  @override
  Future<void> removeAnimalFromLote({
    required String loteUuid,
    required String animalUuid,
  }) async {}

  @override
  Future<void> removeAnimalsFromLote({
    required String loteUuid,
    required List<String> animalUuids,
  }) async {}

  @override
  Future<String?> getLoteThatContainsAnimal(String animalUuid) async => null;

  @override
  Future<List<LoteEntity>> getActiveLotes() async =>
      _lotes.where((lote) => lote.active).toList();

  @override
  Future<List<LoteEntity>> getInactiveLotes() async =>
      _lotes.where((lote) => !lote.active).toList();
}

Future<void> _pumpLotes(
  WidgetTester tester,
  List<LoteEntity> lotes, {
  double bottomInset = 0,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(padding: EdgeInsets.only(bottom: bottomInset)),
        child: child!,
      ),
      home: BlocProvider(
        create: (_) => LotesBloc(_FakeLotesRepository(lotes)),
        child: const LotesListView(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LotesListView', () {
    testWidgets('keeps location updates when activating the directory tab', (
      tester,
    ) async {
      final locations = _SingleSubscriptionLocations();
      addTearDown(locations.changes.close);
      var active = false;
      late StateSetter rebuild;
      const destination = LocationEntity(
        uuid: 'destination',
        name: 'Potrero destino',
        type: LocationType.pasture,
        surfaceArea: 1,
        capacity: 3,
        waterSource: '',
        terrainType: '',
      );
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider(
            create: (_) => LotesBloc(
              _FakeLotesRepository([
                LoteEntity(
                  uuid: 'moved-lot',
                  name: 'Lote trasladado',
                  currentLocationId: destination.uuid,
                  createdAt: DateTime(2026, 10, 25),
                  lastUpdateDate: DateTime(2026, 10, 25),
                ),
              ]),
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                rebuild = setState;
                return LotesListView(
                  shellInteractionsEnabled: active,
                  locationRepository: locations,
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      locations.changes.add([destination]);
      await tester.pumpAndSettle();
      expect(find.text('Potrero destino'), findsOneWidget);

      rebuild(() => active = true);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Potrero destino'), findsOneWidget);

      locations.changes.add([
        destination.copyWith(name: 'Potrero actualizado'),
      ]);
      await tester.pumpAndSettle();
      expect(find.text('Potrero actualizado'), findsOneWidget);
      rebuild(() => active = false);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Potrero actualizado'), findsOneWidget);
      expect(locations.watchCalls, 1);
    });

    testWidgets(
      'last active lot clears the dock when there are no closed lots',
      (tester) async {
        const height = 568.0;
        const dockInset = 105.0;
        tester.view.physicalSize = const Size(320, height);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await _pumpLotes(
          tester,
          List.generate(
            8,
            (index) => LoteEntity(
              uuid: 'active-$index',
              name: 'Lote $index',
              createdAt: DateTime(2026, 9, 13),
              lastUpdateDate: DateTime(2026, 9, 13),
            ),
          ),
          bottomInset: dockInset,
        );
        final scrollable = tester.state<ScrollableState>(
          find
              .descendant(
                of: find.byType(CustomScrollView),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        expect(scrollable.position.maxScrollExtent, greaterThan(0));
        await tester.fling(
          find.byType(CustomScrollView),
          const Offset(0, -2000),
          4000,
        );
        await tester.pumpAndSettle();
        expect(scrollable.position.extentAfter, 0);

        expect(
          tester.getRect(find.byType(Slidable).last).bottom,
          lessThanOrEqualTo(height - dockInset - 64),
        );
        expect(find.text('Lote 7').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('delete asks confirmation and dispatches delete', (
      tester,
    ) async {
      final repository = _FakeLotesRepository([
        LoteEntity(
          uuid: 'lote-1',
          name: 'Lote Norte',
          description: 'Test lote',
          createdAt: DateTime(2024, 1, 1),
          lastUpdateDate: DateTime(2024, 1, 1),
        ),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider(
            create: (_) => LotesBloc(repository),
            child: const LotesListView(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Lote Norte'), findsOneWidget);

      // Deslizar la tarjeta a la izquierda para revelar la acción de eliminar
      await tester.drag(find.byType(Slidable).first, const Offset(-300, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(SlidableAction, 'Eliminar'));
      await tester.pumpAndSettle();

      expect(find.text('Eliminar lote'), findsOneWidget);
      expect(
        find.text(
          '¿Deseas borrar "Lote Norte"? Esta acción no se puede deshacer.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
      await tester.pumpAndSettle();

      expect(repository.deletedUuids, contains('lote-1'));
    });

    testWidgets(
      'shows all lots by default and filters active and closed lots',
      (tester) async {
        await _pumpLotes(tester, [
          LoteEntity(
            uuid: 'active-1',
            name: 'Vientres productivos',
            animalUuids: const ['animal-1', 'animal-2'],
            createdAt: DateTime(2026, 9, 13),
            lastUpdateDate: DateTime(2026, 9, 13),
          ),
          LoteEntity(
            uuid: 'active-2',
            name: 'Vaquillas de reemplazo',
            createdAt: DateTime(2026, 9, 13),
            lastUpdateDate: DateTime(2026, 9, 13),
          ),
          LoteEntity(
            uuid: 'closed-1',
            name: 'Lote cerrado',
            active: false,
            closedAt: DateTime(2026, 9, 13),
            createdAt: DateTime(2026, 8, 1),
            lastUpdateDate: DateTime(2026, 9, 13),
          ),
        ]);

        expect(find.text('3 lotes'), findsOneWidget);
        expect(find.text('Activos · 2'), findsOneWidget);
        expect(find.text('Cerrados · 1'), findsOneWidget);

        await tester.tap(
          find.ancestor(
            of: find.text('Activos'),
            matching: find.byType(AppDirectoryFilterChip),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('2 lotes'), findsOneWidget);
        expect(find.text('Vientres productivos'), findsOneWidget);
        expect(find.text('Lote cerrado'), findsNothing);
        expect(find.text('Cerrados · 1'), findsNothing);

        await tester.tap(
          find.ancestor(
            of: find.text('Cerrados'),
            matching: find.byType(AppDirectoryFilterChip),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('1 lote'), findsOneWidget);
        expect(find.text('Lote cerrado'), findsOneWidget);
        expect(find.text('No hay lotes cerrados'), findsNothing);
      },
    );

    testWidgets('keeps long cards usable on a compact viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _pumpLotes(tester, [
        LoteEntity(
          uuid: 'compact-1',
          name: 'Lote con un nombre suficientemente largo para truncarse',
          description:
              'Descripción extensa del lote que debe conservarse en una sola línea',
          createdAt: DateTime(2026, 9, 13),
          lastUpdateDate: DateTime(2026, 9, 13),
        ),
      ]);

      expect(find.text('Sin animales asignados'), findsOneWidget);
      expect(find.text('Activo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
