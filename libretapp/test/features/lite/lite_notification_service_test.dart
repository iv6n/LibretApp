import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/platform/release_features.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/data/agenda_repository.dart';
import 'package:libretapp/features/lite/lite_notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('libretapp/lite_reminders');
  late AgendaRepositoryImpl agenda;
  final sent = <List<dynamic>>[];

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    agenda = AgendaRepositoryImpl(
      SharedPrefsService(await SharedPreferences.getInstance()),
    );
    locator.registerSingleton<AgendaRepository>(agenda);
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'replace') {
            sent.add((call.arguments as Map)['entries'] as List<dynamic>);
          }
          return null;
        });
  });

  tearDown(() async {
    ReleaseFeatures.demoMode = false;
    sent.clear();
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    await locator.reset();
  });

  test(
    'demo no solicita permisos ni programa avisos, incluso al editar ejemplos',
    () async {
      await agenda.saveEntry(
        AgendaEntry(
          id: 'demo-reminder',
          titulo: 'Ejemplo futuro',
          descripcion: '',
          fecha: DateTime.now().add(const Duration(days: 1)),
          tipo: 'Cuidado general',
          animalIds: const [],
          loteIds: const [],
          ubicacion: '',
          estado: AgendaEstado.pendiente,
          completedAnimalIds: const [],
          notas: '',
          sourceType: 'lite',
        ),
      );
      ReleaseFeatures.demoMode = true;
      await LiteNotificationService.syncFromRepository(requestPermission: true);
      await LiteNotificationService.requestExactAccess();
      expect(await LiteNotificationService.exactAvailable(), isTrue);
      expect(sent, [isEmpty]);
    },
  );

  test('cambiar espacio invalida una lectura de avisos en curso', () async {
    final delayed = Completer<List<AgendaEntry>>();
    await locator.unregister<AgendaRepository>();
    locator.registerSingleton<AgendaRepository>(_DelayedAgenda(delayed.future));
    final pending = LiteNotificationService.syncFromRepository(
      requestPermission: true,
    );
    await LiteNotificationService.cancelForWorkspaceChange();
    ReleaseFeatures.demoMode = true;
    delayed.complete([
      AgendaEntry(
        id: 'old',
        titulo: 'Viejo',
        descripcion: '',
        fecha: DateTime.now().add(const Duration(days: 1)),
        tipo: 'Cuidado general',
        animalIds: const [],
        loteIds: const [],
        ubicacion: '',
        estado: AgendaEstado.pendiente,
        completedAnimalIds: const [],
        notas: '',
        sourceType: 'lite',
      ),
    ]);
    await pending;
    expect(sent, [isEmpty]);
  });

  test(
    'avisos Lite persisten al cambiar modo y se retiran al confirmar dosis',
    () async {
      final entry = AgendaEntry(
        id: 'dose-1',
        titulo: 'Toma 1',
        descripcion: 'Indicaciones',
        fecha: DateTime.now().add(const Duration(days: 1)),
        tipo: 'Medicamento',
        animalIds: const ['pet'],
        loteIds: const [],
        ubicacion: '',
        estado: AgendaEstado.pendiente,
        completedAnimalIds: const [],
        notas: '',
        sourceType: 'lite',
        actionKind: 'petDose',
      );
      await agenda.saveEntry(entry);
      await LiteNotificationService.syncFromRepository();
      expect(sent.last, hasLength(1));
      expect((sent.last.single as Map)['id'], 'dose-1');
      await agenda.updateEntry(entry.copyWith(estado: AgendaEstado.completado));
      await LiteNotificationService.syncFromRepository();
      expect(sent.last, isEmpty);
    },
  );
}

class _DelayedAgenda implements AgendaRepository {
  _DelayedAgenda(this.entries);
  final Future<List<AgendaEntry>> entries;
  @override
  Future<List<AgendaEntry>> fetchEntries() => entries;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
