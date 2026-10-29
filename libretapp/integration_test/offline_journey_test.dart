import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:libretapp/app/app.dart';
import 'package:libretapp/app/workspace_app_host.dart';
import 'package:libretapp/core/di/injection.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/maintenance/data_maintenance.dart';
import 'package:libretapp/core/platform/release_features.dart';
import 'package:libretapp/core/router/app_routes.dart';
import 'package:libretapp/core/services/backup_service.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/core/services/prefs_keys.dart';
import 'package:libretapp/core/security/ports/phone_auth_port.dart';
import 'package:libretapp/core/workspace/workspace_files.dart';
import 'package:libretapp/core/workspace/workspace_manager.dart';
import 'package:libretapp/core/workspace/workspace_registry.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/repositories/weight_record_repository.dart';
import 'package:libretapp/features/finanzas/domain/entities/income_record.dart';
import 'package:libretapp/features/finanzas/domain/repositories/finanzas_repository.dart';
import 'package:libretapp/features/perfil/data/perfil_repository.dart';
import '../test/features/directorio/animales/advisor/rules/rule_test_fixtures.dart';

/// Real Android plugins and Isar. Only this dedicated test workspace is cleared;
/// neither the user's guest workspace nor account workspaces are opened.
void main() => runNativeJourneyTests();

void runNativeJourneyTests({bool connected = false}) {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const reopenOnly = bool.fromEnvironment('LIBRETAPP_QA_REOPEN_ONLY');
  testWidgets(
    reopenOnly
        ? 'offline Android: reopen persisted records, profile and photo after process death'
        : 'offline Android: create, UI capture/edit, delete, archive and native recovery',
    (tester) async {
      expect(ReleaseFeatures.offlinePilot, !connected);
      if (connected) {
        expect(ReleaseFeatures.connected, true);
        expect(ReleaseFeatures.syncEnabled, false);
        expect(ReleaseFeatures.gpsCaptureEnabled, false);
        expect(ReleaseFeatures.hardwareIntegrationsEnabled, false);
      }
      final workspace = LocalWorkspace(
        id: connected ? 'integration-connected' : 'integration-offline',
        kind: WorkspaceKind.guest,
      );
      Future<void> exposeQaWorkspace() async {
        // Explicit opt-in used only on disposable QA emulators when installing
        // the release APK over this test build to verify the real main entry.
        if (!const bool.fromEnvironment('LIBRETAPP_QA_EXPOSE_TEST_WORKSPACE'))
          return;
        final qaPrefs = SharedPrefsService(
          await SharedPreferences.getInstance(),
        );
        await WorkspaceRegistry(qaPrefs).replace([workspace], workspace.id);
        await qaPrefs.setBool(PrefsKeys.onboardingCompletedV1, true);
      }

      final global = SharedPrefsService(
        await SharedPreferences.getInstance(),
        prefix: 'integration-test:',
      );
      final registry = WorkspaceRegistry(global);
      await registry.replace([workspace], workspace.id);
      final manager = WorkspaceManager(
        registry: registry,
        auth: const UnavailablePhoneAuth(),
      );
      await setupLocator(workspace: workspace);
      if (!reopenOnly) {
        await locator<IsarDatabase>().clearAllCollections();
        await disposeLocator();
        await setupLocator(workspace: workspace);
      }
      locator.registerSingleton<WorkspaceManager>(manager);
      addTearDown(disposeLocator);
      final animals = locator<AnimalRepository>();
      final weights = locator<WeightRecordRepository>();
      final finances = locator<FinanzasRepository>();
      final profiles = locator<PerfilRepository>();
      if (reopenOnly) {
        final recovered = (await animals.getByUuid('android-a'))!;
        expect(recovered.earTagNumber, 'ANDROID-001');
        expect(
          (await weights.getWeightRecords(recovered.uuid)).single.weight,
          165,
        );
        expect((await finances.getAllIncomes()).single.amount, 275);
        expect((await profiles.fetchPerfil()).finca, 'QA Android');
        expect(await File(recovered.profilePhoto!).exists(), true);
        await exposeQaWorkspace();
        return;
      }
      await profiles.savePerfil(
        (await profiles.fetchPerfil()).copyWith(finca: 'QA Android'),
      );
      final root = await workspaceDirectory(workspace);
      final photo = File('${root.path}/test-photo.png');
      final photoBytes = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aD1sAAAAASUVORK5CYII=',
      );
      await photo.writeAsBytes(photoBytes, flush: true);
      await animals.save(
        buildAnimal(uuid: 'android-a').copyWith(
          earTagNumber: 'ANDROID-001',
          profilePhoto: photo.path,
          gallery: [photo.path],
        ),
      );
      expect(
        (await animals.getByUuid('android-a'))!.earTagNumber,
        'ANDROID-001',
      );

      await tester.pumpWidget(
        WorkspaceAppHost(manager: manager, initialLocation: AppRoutes.inicio),
      );
      await tester.pumpAndSettle();
      final router = tester.widget<MyApp>(find.byType(MyApp)).router;
      unawaited(
        router.push<void>(AppRoutes.animalRegistroPesoPath('android-a')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Tomar lectura de báscula'), findsNothing);
      await tester.enterText(find.byType(TextFormField).first, '160');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Guardar').last);
      await tester.tap(find.text('Guardar').last);
      await tester.pumpAndSettle();
      final first = (await weights.getWeightRecords('android-a')).single;
      expect(first.weight, 160);
      unawaited(
        router.push<void>(
          '${AppRoutes.animalRegistroPesoPath('android-a')}?recordId=${first.id}',
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, '165');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Guardar').last);
      await tester.tap(find.text('Guardar').last);
      await tester.pumpAndSettle();
      final corrected = (await weights.getWeightRecords('android-a')).single;
      expect(corrected.id, first.id);
      expect(corrected.recordUuid, first.recordUuid);
      expect(corrected.weight, 165);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      final income = await finances.addIncome(
        IncomeRecord(date: DateTime.now(), type: IncomeType.other, amount: 250),
      );
      await finances.updateIncome(income.copyWith(amount: 275));
      final backup = locator<BackupService>();
      final archive = await backup.createArchiveBytes();
      await weights.deleteWeightRecord(first.id!);
      expect(await weights.getWeightRecords('android-a'), isEmpty);
      await finances.deleteIncome(income.id!);
      expect(await finances.getAllIncomes(), isEmpty);
      await backup.importArchiveBytes(
        archive,
        mode: BackupImportMode.replaceAll,
      );
      expect((await weights.getWeightRecords('android-a')).single.weight, 165);
      expect((await finances.getAllIncomes()).single.amount, 275);
      final restoredPhoto = (await animals.getByUuid(
        'android-a',
      ))!.profilePhoto!;
      expect(await File(restoredPhoto).readAsBytes(), photoBytes);
      expect((await profiles.fetchPerfil()).finca, 'QA Android');
      final maintenance = locator<DataMaintenance>();
      final native = await maintenance.createSnapshot();
      await finances.deleteIncome(income.id!);
      final database = locator<IsarDatabase>();
      await maintenance.restoreSnapshot(
        native,
        reopen: (action) async {
          await database.close();
          await action();
          await database.initialize();
        },
      );
      expect((await finances.getAllIncomes()).single.amount, 275);
      expect(
        (await weights.getWeightRecords('android-a')).single.recordUuid,
        first.recordUuid,
      );
      await exposeQaWorkspace();
    },
  );
}
