import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/database/write_transaction.dart';
import 'package:libretapp/core/services/herd_import_service.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/view/herd_import_page.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/registro/lotes/batch_record_page.dart';
import 'package:libretapp/features/registro/lotes/batch_record_service.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/repositories/location_repository.dart';

import '../directorio/animales/advisor/rules/rule_test_fixtures.dart';

class _MemoryAnimals implements AnimalRepository {
  final animals = <String, AnimalEntity>{};
  int writes = 0;
  @override
  Future<List<AnimalEntity>> getAllIncludingInactive() async =>
      animals.values.toList();
  @override
  Future<AnimalEntity> save(AnimalEntity animal) async {
    writes++;
    animals[animal.uuid] = animal;
    return animal;
  }

  @override
  Future<AnimalEntity> update(AnimalEntity animal) => save(animal);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ImmediateTransactions implements WriteTransactionRunner {
  @override
  Future<T> run<T>(Future<T> Function() action) => action();
}

class _UiImporter extends HerdImportService {
  _UiImporter(_MemoryAnimals animals)
    : super(animals: animals, transactions: _ImmediateTransactions());
  bool failNext = false;
  @override
  Future<HerdImportSummary> commit(
    HerdImportPreview preview,
    Map<int, HerdImportAction> actions,
  ) {
    if (failNext) {
      failNext = false;
      return Future.error(StateError('No hay espacio para la importación.'));
    }
    return super.commit(preview, actions);
  }
}

class _MemoryLots implements LotesRepository {
  final lot = LoteEntity(
    uuid: 'lot-1',
    name: 'Lote de cría',
    createdAt: DateTime(2026),
    lastUpdateDate: DateTime(2026),
  );
  @override
  Future<List<LoteEntity>> getAll() async => [lot];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MemoryLocations implements LocationRepository {
  @override
  Future<List<LocationEntity>> getAll() async => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MemoryBatch implements BatchRecordService {
  final sessions = <String, BatchRecordSession>{};
  bool failSave = false;
  int completions = 0;
  @override
  Future<List<BatchRecordSession>> list() async => sessions.values.toList();
  @override
  Future<BatchRecordSession> start({
    required String lotUuid,
    required BatchRecordKind kind,
  }) async {
    final session = BatchRecordSession(
      uuid: 'ui-session',
      farmId: 'farm-1',
      lotUuid: lotUuid,
      lotName: 'Lote de cría',
      kind: kind,
      date: DateTime(2026, 10, 24),
      createdAt: DateTime(2026, 10, 24),
      participants: const [
        BatchParticipant(uuid: 'a', tag: '0001'),
        BatchParticipant(uuid: 'b', tag: '0002'),
      ],
    );
    sessions[session.uuid] = session;
    return session;
  }

  @override
  Future<BatchRecordSession> open(String uuid) async => sessions[uuid]!;
  @override
  Future<BatchRecordSession> saveDraft(
    BatchRecordSession draft, {
    required int expectedVersion,
  }) async {
    if (failSave) throw StateError('Error de almacenamiento de prueba.');
    final saved = draft.copyWith(version: expectedVersion + 1);
    sessions[draft.uuid] = saved;
    return saved;
  }

  @override
  Future<BatchRecordSession> complete(
    String uuid, {
    required int expectedVersion,
  }) async {
    completions++;
    final session = sessions[uuid]!;
    final completed = session.copyWith(
      completedAt: DateTime.now(),
      savedCount: session.included.length,
      version: expectedVersion + 1,
    );
    sessions[uuid] = completed;
    return completed;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      180,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 40,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pump();
}

void main() {
  Future<void> pumpImport(
    WidgetTester tester,
    _UiImporter importer, {
    String source = 'Arete,Nombre\n0001,Luna\n',
    double scale = 1,
  }) async {
    final document = importer.readDocument(
      utf8.encode(source),
      fileName: 'hato.csv',
    );
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: HerdImportPage(service: importer, initialDocument: document),
      ),
    );
    await _reveal(tester, find.text('Generar vista previa'));
    await tester.tap(find.text('Generar vista previa'));
    await tester.pumpAndSettle();
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await _reveal(tester, finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'review is read-only, matches are skipped and cancelling confirmation leaves the herd untouched',
    (tester) async {
      final animals = _MemoryAnimals();
      animals.animals['a'] = buildAnimal(
        uuid: 'a',
      ).copyWith(earTagNumber: '0001', customName: 'Anterior');
      final importer = _UiImporter(animals);
      await pumpImport(
        tester,
        importer,
        source: 'Arete,Nombre\n0001,Luna\n0002,Nueva\n',
      );
      expect(animals.writes, 0);
      expect(find.text('Importar 1 filas seleccionadas'), findsOneWidget);
      await tester.tap(find.text('Importar 1 filas seleccionadas'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Revisar'));
      await tester.pumpAndSettle();
      expect(animals.writes, 0);
      await tapVisible(tester, find.byKey(const ValueKey('import-action-2')));
      await tester.tap(find.text('Actualizar').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Importar 2 filas seleccionadas'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, 'Confirmar importación'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Importación completada'), findsOneWidget);
      expect(animals.animals, hasLength(2));
      expect(animals.animals['a']!.customName, 'Luna');
    },
  );

  testWidgets(
    'an import error retains the preview and reviewed selection for retry',
    (tester) async {
      final animals = _MemoryAnimals();
      final importer = _UiImporter(animals)..failNext = true;
      await pumpImport(tester, importer);
      for (var attempt = 0; attempt < 2; attempt++) {
        await tester.tap(find.text('Importar 1 filas seleccionadas'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(FilledButton, 'Confirmar importación'),
        );
        await tester.pumpAndSettle();
        if (attempt == 0) {
          expect(
            find.text('No hay espacio para la importación.'),
            findsWidgets,
          );
          expect(animals.animals, isEmpty);
          expect(find.byKey(const ValueKey('preview-row-2')), findsOneWidget);
        }
      }
      expect(animals.animals, hasLength(1));
    },
  );

  testWidgets('duplicate preview stays usable at 320 dp with double text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await pumpImport(
      tester,
      _UiImporter(_MemoryAnimals()),
      source: 'Arete,Nombre\n0001,Luna\n0001,Repetida\n0002,Nueva\n',
      scale: 2,
    );
    await _reveal(tester, find.byKey(const ValueKey('preview-row-3')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('Identificación repetida'), findsWidgets);
  });

  Future<void> pumpBatch(
    WidgetTester tester,
    _MemoryBatch service, {
    double scale = 1,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: BatchRecordPage(
          service: service,
          lots: _MemoryLots(),
          locations: _MemoryLocations(),
          initialLotUuid: 'lot-1',
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'a lot capture autosaves, reopens and confirms only measured animals',
    (tester) async {
      final service = _MemoryBatch();
      await pumpBatch(tester, service);
      await tapVisible(tester, find.text('Iniciar sesión'));
      await _reveal(tester, find.byKey(const ValueKey('ui-session-weight-a')));
      await tester.enterText(
        find.byKey(const ValueKey('ui-session-weight-a')),
        '320,5',
      );
      await tester.pumpAndSettle();
      expect(service.sessions['ui-session']!.weights['a'], '320,5');
      await tester.pumpWidget(const SizedBox.shrink());
      await pumpBatch(tester, service);
      await tapVisible(tester, find.text('Pesaje · Lote de cría'));
      expect(
        tester
            .widget<TextFormField>(
              find.byKey(const ValueKey('ui-session-weight-a')),
            )
            .initialValue,
        '320,5',
      );
      await tester.tap(find.text('Revisar 1 registros'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar registros'));
      await tester.pumpAndSettle();
      expect(find.text('Sesión completada'), findsOneWidget);
      expect(service.completions, 1);
      expect(service.sessions['ui-session']!.savedCount, 1);
      expect(find.text('Revisar 1 registros'), findsNothing);
    },
  );

  testWidgets(
    'failed autosave is visible and the raw capture can be saved again',
    (tester) async {
      final service = _MemoryBatch()..failSave = true;
      await pumpBatch(tester, service);
      await tapVisible(tester, find.text('Iniciar sesión'));
      await _reveal(tester, find.byKey(const ValueKey('ui-session-weight-a')));
      await tester.enterText(
        find.byKey(const ValueKey('ui-session-weight-a')),
        '310',
      );
      await tester.pumpAndSettle();
      expect(find.text('Hay cambios sin guardar'), findsOneWidget);
      expect(service.sessions['ui-session']!.weights, isEmpty);
      service.failSave = false;
      await tapVisible(tester, find.text('Reintentar guardado'));
      expect(service.sessions['ui-session']!.weights['a'], '310');
      expect(find.text('Hay cambios sin guardar'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'lot capture fits a small screen with large text and an open keyboard',
    (tester) async {
      tester.view.physicalSize = const Size(320, 760);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final service = _MemoryBatch();
      await pumpBatch(tester, service, scale: 2);
      await tapVisible(tester, find.text('Iniciar sesión'));
      await _reveal(tester, find.byKey(const ValueKey('ui-session-weight-a')));
      await tester.tap(find.byKey(const ValueKey('ui-session-weight-a')));
      tester.view.viewInsets = const FakeViewPadding(bottom: 260);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
