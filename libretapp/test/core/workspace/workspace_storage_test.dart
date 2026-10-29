import 'dart:io';
import 'package:libretapp/features/perfil/data/perfil_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/persistence/feature_record_store.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/core/media/media_store.dart';
import 'package:libretapp/core/backup/backup_store.dart';
import 'package:libretapp/core/demo/demo_scenario_service.dart';
import 'package:libretapp/core/demo/lite_demo_scenario_service.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/core/workspace/workspace_registry.dart';
import 'package:libretapp/core/workspace/workspace_files.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temp;
  const a = LocalWorkspace(
    id: 'account-a',
    kind: WorkspaceKind.account,
    userId: 'user-a',
  );
  const b = LocalWorkspace(
    id: 'account-b',
    kind: WorkspaceKind.account,
    userId: 'user-b',
  );
  const demo = LocalWorkspace(id: 'demo-workspace', kind: WorkspaceKind.demo);
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('libretapp_workspaces_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => temp.path,
        );
    SharedPreferences.setMockInitialValues({});
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
    'databases, drafts, media and backup contents stay isolated across switching',
    () async {
      await setupLocator(workspace: a);
      expect(await workspaceHasUserData(), isFalse);
      final now = DateTime.now().toUtc();
      await locator<FeatureRecordStore>().put(
        FeatureRecord(
          uuid: 'sample-record',
          farmId: 'farm-a',
          kind: 'inventory.transaction',
          payload: const {'quantity': 12},
          createdAt: now,
          updatedAt: now,
        ),
      );
      await locator<SharedPrefsService>().setString(
        'animal.wizard.draft',
        'draft-a',
      );
      final photo = File('${temp.path}/input.jpg');
      await photo.writeAsBytes([1, 2, 3]);
      final saved = await locator<MediaStore>().persist(
        XFile(photo.path),
        MediaBucket.animals,
      );
      final firstSpaceMedia = locator<MediaStore>();
      expect(saved, contains('account-a'));
      expect(await workspaceHasUserData(), isTrue);
      await disposeLocator();
      await setupLocator(workspace: b);
      final delayedPhoto = await firstSpaceMedia.persist(
        XFile(photo.path),
        MediaBucket.animals,
      );
      expect(
        delayedPhoto,
        contains('account-a'),
        reason:
            'A delayed operation must retain the workspace that created its service.',
      );
      expect(await workspaceHasUserData(), isFalse);
      expect(
        locator<SharedPrefsService>().getString('animal.wizard.draft'),
        isNull,
      );
      expect(
        await locator<FeatureRecordStore>().get('farm-a', 'sample-record'),
        isNull,
      );
      final backupB = await locator<BackupStore>().capture();
      expect(
        backupB.collections['featureRecords']!.any(
          (r) => r['uuid'] == 'sample-record',
        ),
        isFalse,
      );
      await disposeLocator();
      await setupLocator(workspace: a);
      expect(
        (await locator<FeatureRecordStore>().get(
          'farm-a',
          'sample-record',
        ))!.payload['quantity'],
        12,
      );
      expect(
        locator<SharedPrefsService>().getString('animal.wizard.draft'),
        'draft-a',
      );
      expect(await File(saved).readAsBytes(), [1, 2, 3]);
    },
  );
  test(
    'editable seeded demo and its cleanup never touch the real dataset',
    () async {
      await setupLocator(workspace: a);
      final profile = await locator<PerfilRepository>().fetchPerfil();
      await locator<PerfilRepository>().savePerfil(
        profile.copyWith(nombre: 'Mi rancho'),
      );
      await disposeLocator();
      await setupLocator(workspace: demo);
      await locator<DemoScenarioService>().install();
      final demoBackup = await locator<BackupStore>().capture();
      expect(demoBackup.collections['animals'], isNotEmpty);
      expect(demoBackup.profile['nombre'], isNot('Mi rancho'));
      await locator<SharedPrefsService>().setString(
        'animal.wizard.draft',
        'demo-edit',
      );
      await disposeLocator();
      await discardDemoFiles(demo);
      await setupLocator(workspace: a);
      final realBackup = await locator<BackupStore>().capture();
      expect(realBackup.collections['animals'], isEmpty);
      expect(realBackup.profile['nombre'], 'Mi rancho');
      expect(
        locator<SharedPrefsService>().getString('animal.wizard.draft'),
        isNull,
      );
      expect(
        await Directory('${temp.path}/workspaces/demo-workspace').exists(),
        isFalse,
      );
    },
  );

  test(
    'demo doméstica editable y su limpieza conservan el espacio real',
    () async {
      await setupLocator(workspace: a);
      final profile = await locator<PerfilRepository>().fetchPerfil();
      await locator<PerfilRepository>().savePerfil(
        profile.copyWith(nombre: 'Mis registros'),
      );
      await locator<SharedPrefsService>().setString(
        'animal.wizard.draft',
        'borrador real',
      );
      await disposeLocator();
      await setupLocator(workspace: demo);
      await locator<LiteDemoScenarioService>().install();
      final animals = locator<AnimalRepository>();
      final pet = (await animals.getAll()).first;
      await animals.update(pet.copyWith(customName: 'Ejemplo editado'));
      expect(
        (await locator<BackupStore>().capture()).collections['animals'],
        hasLength(2),
      );
      final demoPrefs = locator<SharedPrefsService>();
      await disposeLocator();
      await discardDemoFiles(demo);
      await demoPrefs.clearWorkspace();
      await setupLocator(workspace: a);
      expect(
        (await locator<PerfilRepository>().fetchPerfil()).nombre,
        'Mis registros',
      );
      expect(await locator<AnimalRepository>().getAll(), isEmpty);
      expect(
        locator<SharedPrefsService>().getString('animal.wizard.draft'),
        'borrador real',
      );
      expect(
        await Directory('${temp.path}/workspaces/demo-workspace').exists(),
        isFalse,
      );
    },
  );
}
