import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/features/directorio/animales/domain/animal_domain.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weaning_record_repository.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/view/animal_weaning_form_page.dart';
import 'package:libretapp/l10n/app_localizations.dart';
import 'advisor/rules/rule_test_fixtures.dart';

class _Animals implements AnimalRepository {
  final calf = buildAnimal(uuid: 'calf', category: Category.calf, ageMonths: 6);
  @override
  Future<AnimalEntity?> getByUuid(String uuid) async => calf;
  @override
  Future<List<AnimalEntity>> getAll() async => [calf];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Weaning implements WeaningRecordRepository {
  final stored = <WeaningRecord>[];
  bool fail = false;
  int writes = 0;
  Completer<void>? gate;
  @override
  Future<List<WeaningRecord>> getWeaningRecords(String uuid) async => stored;
  @override
  Future<WeaningRecord> save(WeaningRecord record) async {
    writes++;
    if (gate != null) await gate!.future;
    if (fail) throw StateError('Disco no disponible');
    stored
      ..clear()
      ..add(record);
    return record;
  }

  @override
  Future<WeaningRecord> updateRecord(String uuid, WeaningRecord record) =>
      save(record);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _Weaning repo;
  setUp(() {
    repo = _Weaning();
    locator.registerSingleton<AnimalRepository>(_Animals());
    locator.registerSingleton<WeaningRecordRepository>(repo);
  });
  tearDown(() => locator.reset());

  Future<void> open(
    WidgetTester tester, {
    bool global = false,
    bool edit = false,
  }) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () => context.push('/weaning'),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/weaning',
          builder: (_, _) => AnimalWeaningFormPage(
            animalUuid: global ? null : 'calf',
            recordId: edit ? '7' : null,
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    if (global) {
      await tester.tap(find.text('Seleccionar animal'));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('001').last);
      await tester.pumpAndSettle();
    }
  }

  for (final global in [true, false]) {
    testWidgets(
      'weaning from global=$global retains capture after failure and blocks repeated submit',
      (tester) async {
        repo.fail = true;
        await open(tester, global: global);
        await tester.enterText(find.byType(TextFormField).first, '185,5');
        await tester.ensureVisible(find.text('Guardar'));
        await tester.tap(find.text('Guardar'));
        await tester.pumpAndSettle();
        expect(find.text('185,5'), findsOneWidget);
        expect(find.textContaining('Disco no disponible'), findsOneWidget);
        expect(find.text('Registrar destete'), findsOneWidget);
        repo.fail = false;
        repo.gate = Completer<void>();
        await tester.tap(find.text('Guardar'));
        await tester.pump();
        await tester.tap(find.byType(FilledButton).last, warnIfMissed: false);
        await tester.pump();
        expect(repo.writes, 2);
        repo.gate!.complete();
        await tester.pumpAndSettle();
        expect(repo.stored.single.weightKg, 185.5);
        expect(find.text('Abrir'), findsOneWidget);
      },
    );
  }

  testWidgets(
    'editing restores date, method, responsible and stable weighing identity',
    (tester) async {
      repo.stored.add(
        WeaningRecord(
          id: '7',
          recordUuid: 'wean-7',
          animalUuid: 'calf',
          date: DateTime(2024, 7, 1),
          weightKg: 185,
          weightMethod: WeightMethod.estimated,
          weightRecordUuid: 'weight-7',
          performedBy: 'Ana',
          notes: 'Al potrero',
        ),
      );
      await open(tester, edit: true);
      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('Al potrero'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).first, '190');
      await tester.ensureVisible(find.text('Guardar'));
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(repo.stored.single.recordUuid, 'wean-7');
      expect(repo.stored.single.weightRecordUuid, 'weight-7');
      expect(repo.stored.single.weightMethod, WeightMethod.estimated);
      expect(repo.stored.single.date, DateTime(2024, 7, 1));
    },
  );
}
