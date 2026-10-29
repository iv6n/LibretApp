import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/demo/lite_demo_scenario_service.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/core/workspace/workspace_registry.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_repository.dart';
import 'package:libretapp/features/lite/lite_visibility.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temp;
  late LiteDemoScenarioService service;
  final reference = DateTime(2026, 10, 27);
  const workspace = LocalWorkspace(
    id: 'domestic-demo',
    kind: WorkspaceKind.demo,
  );

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('libretapp_lite_demo_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => temp.path,
        );
    SharedPreferences.setMockInitialValues({});
    await setupLocator(workspace: workspace);
    service = locator<LiteDemoScenarioService>();
  });

  tearDown(() async {
    await disposeLocator();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  test(
    'prepara dos mascotas, dos plantas y tres actividades domésticas enlazadas',
    () async {
      await service.install(referenceDate: reference);
      final animals = await locator<AnimalRepository>().getAll();
      final plants = await locator<CultivationRepository>().getAll();
      final entries = await locator<AgendaRepository>().fetchEntries();
      expect(
        animals.map((a) => a.customName),
        unorderedEquals(['Luna', 'Milo']),
      );
      expect(
        animals.map((a) => a.species),
        unorderedEquals([Species.canine, Species.feline]),
      );
      expect(plants, hasLength(2));
      expect(entries, hasLength(3));
      expect(
        entries.map(
          (e) => DateTime(
            e.fecha.year,
            e.fecha.month,
            e.fecha.day,
          ).difference(reference).inDays,
        ),
        [0, 1, 2],
      );
      expect(LiteVisibility.hiddenCount(animals, plants, entries), 0);
      expect(
        entries.every(
          (e) => e.sourceType == 'lite' && e.id.startsWith('demo-'),
        ),
        isTrue,
      );
      final petIds = animals.map((a) => a.uuid).toSet();
      final plantIds = plants.map((p) => p.uuid).toSet();
      for (final entry in entries) {
        expect(entry.animalIds.every(petIds.contains), isTrue);
        if (entry.cropUuid != null) expect(plantIds, contains(entry.cropUuid));
      }
      expect(
        locator<SharedPrefsService>().getBool(PrefsKeys.onboardingCompletedV1),
        isNull,
      );
    },
  );

  test(
    'repetir instalación conserva ediciones y estados completados',
    () async {
      await service.install(referenceDate: reference);
      final animals = locator<AnimalRepository>();
      final first = (await animals.getAll()).first;
      await animals.update(first.copyWith(customName: 'Mi ejemplo editado'));
      final agenda = locator<AgendaRepository>();
      final entry = (await agenda.fetchEntries()).first;
      await agenda.updateEntry(entry.copyWith(estado: AgendaEstado.completado));
      await service.install(
        referenceDate: reference.add(const Duration(days: 4)),
      );
      expect(
        (await animals.getByUuid(first.uuid))!.customName,
        'Mi ejemplo editado',
      );
      expect((await agenda.getEntry(entry.id)).estado, AgendaEstado.completado);
      expect(await agenda.fetchEntries(), hasLength(3));
    },
  );

  test(
    'un fallo parcial no marca instalación y reintentar no duplica registros',
    () async {
      final agenda = _FailOnceAgenda(locator<AgendaRepository>());
      final retryable = LiteDemoScenarioService(
        workspace: workspace,
        animals: locator<AnimalRepository>(),
        cultivations: locator<CultivationRepository>(),
        agenda: agenda,
        preferences: locator<SharedPrefsService>(),
      );
      await expectLater(
        retryable.install(referenceDate: reference),
        throwsStateError,
      );
      expect(
        locator<SharedPrefsService>().getBool(
          LiteDemoScenarioService.installedKey,
        ),
        isNull,
      );
      await retryable.install(referenceDate: reference);
      expect(await locator<AnimalRepository>().getAll(), hasLength(2));
      expect(await locator<CultivationRepository>().getAll(), hasLength(2));
      expect(await locator<AgendaRepository>().fetchEntries(), hasLength(3));
      expect(
        locator<SharedPrefsService>().getBool(
          LiteDemoScenarioService.installedKey,
        ),
        isTrue,
      );
    },
  );

  test('rechaza instalar ejemplos en un espacio real', () async {
    final real = LiteDemoScenarioService(
      workspace: const LocalWorkspace(id: 'real', kind: WorkspaceKind.guest),
      animals: locator<AnimalRepository>(),
      cultivations: locator<CultivationRepository>(),
      agenda: locator<AgendaRepository>(),
      preferences: locator<SharedPrefsService>(),
    );
    await expectLater(real.install(), throwsStateError);
    expect(await locator<AnimalRepository>().getAll(), isEmpty);
  });
}

class _FailOnceAgenda implements AgendaRepository {
  _FailOnceAgenda(this.delegate);
  final AgendaRepository delegate;
  bool fail = true;
  @override
  Future<void> saveEntries(List<AgendaEntry> entries) async {
    if (fail) {
      fail = false;
      throw StateError('disk full');
    }
    await delegate.saveEntries(entries);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
