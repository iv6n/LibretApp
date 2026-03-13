import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/directorio/lotes/bloc/lotes_bloc.dart';
import 'package:libretapp/features/directorio/lotes/domain/entities/lote_entity.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/lotes_repository.dart';
import 'package:libretapp/features/directorio/lotes/lotes_list_view.dart';
import 'package:libretapp/l10n/app_localizations.dart';

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
  }) async {
    final lote = LoteEntity(
      uuid: 'created-$nombre',
      nombre: nombre,
      descripcion: descripcion,
      notas: notas,
      fechaCreacion: DateTime(2024, 1, 1),
      lastUpdateDate: DateTime(2024, 1, 1),
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
      _lotes.where((lote) => lote.activo).toList();

  @override
  Future<List<LoteEntity>> getInactiveLotes() async =>
      _lotes.where((lote) => !lote.activo).toList();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LotesListView', () {
    testWidgets('delete asks confirmation and dispatches delete', (
      tester,
    ) async {
      final repository = _FakeLotesRepository([
        LoteEntity(
          uuid: 'lote-1',
          nombre: 'Lote Norte',
          descripcion: 'Test lote',
          fechaCreacion: DateTime(2024, 1, 1),
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

      final popupFinder = find.byWidgetPredicate(
        (widget) => widget is PopupMenuButton,
      );
      expect(popupFinder, findsWidgets);

      final popupState = tester.state<PopupMenuButtonState>(popupFinder.first);
      popupState.showButtonMenu();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eliminar').first);
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
  });
}
