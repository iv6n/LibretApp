import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_repository.dart';
import 'package:libretapp/features/directorio/cultivos/view/cultivation_detail_page.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/crop_status.dart';
import 'package:libretapp/theme/app_theme.dart';
import 'package:libretapp/features/ubicaciones/widgets/crop_sheets.dart';

class _Crops implements CultivationRepository {
  final crop = CultivationEntity(
    uuid: 'crop',
    name: 'Huerto de hortalizas de temporada',
    plantingDate: DateTime(2026, 1, 1),
  );
  bool failRead = false;
  bool archived = false;
  int wateringCalls = 0;
  String? notes;
  @override
  Stream<List<CultivationEntity>> watchAll({bool includeArchived = false}) =>
      failRead
      ? Stream.error(StateError('disk'))
      : Stream.value([
          archived ? crop.copyWith(status: CropStatus.archived) : crop,
        ]);
  @override
  Future<void> addWatering(String uuid, CropWateringRecord record) async {
    wateringCalls++;
    if (wateringCalls == 1) throw StateError('disk');
    notes = record.notes;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Locations implements LocationRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  for (final entry in <String, Widget>{
    'cosecha': const HarvestFormSheet(cropName: 'Maíz blanco de temporada'),
    'riego': const CropWateringFormSheet(cropName: 'Maíz blanco'),
    'salud': const CropHealthFormSheet(cropName: 'Maíz blanco'),
    'tarea': const CropTaskFormSheet(cropName: 'Maíz blanco'),
  }.entries) {
    testWidgets('${entry.key} form fits 320dp, doubled text and keyboard', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: const TextScaler.linear(2),
                      viewInsets: const EdgeInsets.only(bottom: 280),
                    ),
                    child: SingleChildScrollView(child: entry.value),
                  ),
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -700),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('read failure offers retry and recovers the detail', (
    tester,
  ) async {
    final repo = _Crops()..failRead = true;
    await tester.pumpWidget(
      MaterialApp(
        home: CultivationDetailPage(
          cultivationUuid: 'crop',
          repository: repo,
          locationRepository: _Locations(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No se pudo cargar el cultivo'), findsOneWidget);
    repo.failRead = false;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text(repo.crop.name), findsOneWidget);
  });
  testWidgets('watering failure keeps notes until a successful retry', (
    tester,
  ) async {
    final repo = _Crops();
    await tester.pumpWidget(
      MaterialApp(
        home: CultivationDetailPage(
          cultivationUuid: 'crop',
          repository: repo,
          locationRepository: _Locations(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Riego'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, 'Riego por goteo');
    await tester.ensureVisible(find.text('Guardar riego'));
    await tester.tap(find.text('Guardar riego'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Tus datos siguen aquí'), findsOneWidget);
    expect(find.text('Riego por goteo'), findsOneWidget);
    await tester.tap(find.text('Guardar riego'));
    await tester.pumpAndSettle();
    expect(repo.notes, 'Riego por goteo');
    expect(repo.wateringCalls, 2);
    expect(find.text('Guardar riego'), findsNothing);
  });
  for (final dark in [false, true]) {
    testWidgets('320dp with doubled text and archived crop, dark=$dark', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = _Crops()..archived = true;
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: CultivationDetailPage(
            cultivationUuid: 'crop',
            repository: repo,
            locationRepository: _Locations(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Registrar actividad'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
