import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/directorio/lotes/view/lote_form_page.dart';

class _LotesRepository implements LotesRepository {
  LoteEntity? saved;
  int creates = 0;
  bool fail = false;

  @override
  Future<LoteEntity?> getByUuid(String uuid) async => saved;

  @override
  Future<LoteEntity> createLote({
    required String nombre,
    String? descripcion,
    String? notas,
    double? feedPricePerKg,
    double? dailyFeedKgPerHead,
    double? liveWeightPricePerKg,
  }) async {
    creates++;
    if (fail) throw StateError('No hay espacio para guardar.');
    final now = DateTime.utc(2026, 10, 25);
    return saved = LoteEntity(
      uuid: 'test-lot',
      name: nombre,
      description: descripcion,
      notes: notas,
      createdAt: now,
      lastUpdateDate: now,
      feedPricePerKg: feedPricePerKg,
      dailyFeedKgPerHead: dailyFeedKgPerHead,
      liveWeightPricePerKg: liveWeightPricePerKg,
    );
  }

  @override
  Future<void> updateLote(LoteEntity lote) async => saved = lote;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Future<void> openForm(
    WidgetTester tester,
    _LotesRepository repository, {
    String? lotUuid,
  }) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) =>
                      LoteFormPage(repository: repository, loteUuid: lotUuid),
                ),
              ),
              child: const Text('Abrir formulario'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir formulario'));
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    final button = find.byKey(const ValueKey('lote-save'));
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets('creates a lot from an overlay without a directory bloc', (
    tester,
  ) async {
    final repository = _LotesRepository();
    await openForm(tester, repository);
    await tester.enterText(
      find.byKey(const ValueKey('lote-name')),
      'Prueba sin conexión',
    );
    await save(tester);

    expect(tester.takeException(), isNull);
    expect(repository.creates, 1);
    expect(repository.saved!.name, 'Prueba sin conexión');
    expect(find.text('Abrir formulario'), findsOneWidget);
  });

  testWidgets('a storage error keeps the form editable and allows retry', (
    tester,
  ) async {
    final repository = _LotesRepository()..fail = true;
    await openForm(tester, repository);
    await tester.enterText(
      find.byKey(const ValueKey('lote-name')),
      'Prueba sin conexión',
    );
    await save(tester);

    expect(find.text('No hay espacio para guardar.'), findsOneWidget);
    expect(repository.saved, isNull);
    repository.fail = false;
    await save(tester);
    expect(repository.creates, 2);
    expect(repository.saved!.name, 'Prueba sin conexión');
    expect(tester.takeException(), isNull);
  });

  testWidgets('edits a lot through the supplied repository', (tester) async {
    final now = DateTime.utc(2026, 10, 25);
    final repository = _LotesRepository()
      ..saved = LoteEntity(
        uuid: 'existing',
        name: 'Antes',
        animalUuids: const ['animal-a'],
        createdAt: now,
        lastUpdateDate: now,
      );
    await openForm(tester, repository, lotUuid: 'existing');
    await tester.enterText(find.byKey(const ValueKey('lote-name')), 'Después');
    await save(tester);

    expect(repository.creates, 0);
    expect(repository.saved!.uuid, 'existing');
    expect(repository.saved!.name, 'Después');
    expect(repository.saved!.animalUuids, ['animal-a']);
    expect(tester.takeException(), isNull);
  });
}
