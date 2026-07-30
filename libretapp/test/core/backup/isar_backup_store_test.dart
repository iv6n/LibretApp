import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/backup/backup_models.dart';
import 'package:libretapp/core/backup/isar_backup_store.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/features/finanzas/domain/entities/financial_period_summary.dart';
import 'package:libretapp/features/finanzas/domain/entities/income_record.dart';
import 'package:libretapp/features/finanzas/infrastructure/isar_finanzas_repository.dart';
import 'package:libretapp/features/perfil/data/perfil_model.dart';
import 'package:libretapp/features/perfil/data/perfil_repository.dart';

class _MemoryPerfilRepository implements PerfilRepository {
  Perfil perfil = const Perfil(
    id: 'profile-1',
    nombre: 'Ana',
    apellido: 'Piloto',
    email: '',
    telefono: '',
    finca: 'Finca piloto',
    direccion: '',
  );

  @override
  Future<Perfil> fetchPerfil() async => perfil;

  @override
  Future<void> savePerfil(Perfil perfil) async => this.perfil = perfil;

  @override
  Future<void> updatePerfil(Perfil perfil) => savePerfil(perfil);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDirectory;
  late IsarDatabase database;
  late IsarFinanzasRepository finances;
  late _MemoryPerfilRepository profiles;
  late IsarBackupStore store;

  setUpAll(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'libretapp_backup_store_',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          pathProviderChannel,
          (_) async => tempDirectory.path,
        );
  });

  setUp(() async {
    database = IsarDatabase();
    await database.initialize();
    await database.clearAllCollections();
    finances = IsarFinanzasRepository(database);
    profiles = _MemoryPerfilRepository();
    store = IsarBackupStore(database: database, perfilRepository: profiles);
  });

  tearDown(() async => database.close());

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    if (tempDirectory.existsSync()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test(
    'capture backfills stable recordUuid and replaceAll restores it',
    () async {
      await finances.addIncome(
        IncomeRecord(
          date: DateTime.utc(2026, 7, 29),
          type: IncomeType.milkSale,
          amount: 1500,
          currency: 'MXN',
        ),
      );

      final envelope = await store.capture();
      final rows = envelope.collections['incomeRecords']!;
      expect(rows, hasLength(1));
      final stableId = rows.single['recordUuid'];
      expect(stableId, isA<String>());
      expect(stableId, isNotEmpty);

      await database.clearAllCollections();
      profiles.perfil = profiles.perfil.copyWith(finca: 'Otra finca');
      await store.restore(envelope, mode: BackupImportMode.replaceAll);

      final restored = await finances.getIncomes(
        DateRange(start: DateTime.utc(2026), end: DateTime.utc(2027)),
      );
      expect(restored, hasLength(1));
      expect(restored.single.amount, 1500);
      expect(profiles.perfil.finca, 'Finca piloto');

      final secondCapture = await store.capture();
      expect(
        secondCapture.collections['incomeRecords']!.single['recordUuid'],
        stableId,
      );
    },
  );

  test(
    'merge updates by recordUuid instead of duplicating local IDs',
    () async {
      await finances.addIncome(
        IncomeRecord(
          date: DateTime.utc(2026, 7, 29),
          type: IncomeType.milkSale,
          amount: 1500,
        ),
      );
      final captured = await store.capture();
      final row = captured.collections['incomeRecords']!.single;
      row
        ..['id'] = 99999
        ..['amount'] = 2000.0;

      await store.restore(captured, mode: BackupImportMode.merge);

      final restored = await finances.getIncomes(
        DateRange(start: DateTime.utc(2026), end: DateTime.utc(2027)),
      );
      expect(restored, hasLength(1));
      expect(restored.single.amount, 2000);
    },
  );

  test('replaceAll rolls back every collection when an import fails', () async {
    await finances.addIncome(
      IncomeRecord(
        date: DateTime.utc(2026, 7, 29),
        type: IncomeType.milkSale,
        amount: 1500,
      ),
    );
    final captured = await store.capture();
    captured.collections['incomeRecords']!.single['amount'] = 'invalid';

    await expectLater(
      () => store.restore(captured, mode: BackupImportMode.replaceAll),
      throwsA(anything),
    );

    final preserved = await finances.getIncomes(
      DateRange(start: DateTime.utc(2026), end: DateTime.utc(2027)),
    );
    expect(preserved, hasLength(1));
    expect(preserved.single.amount, 1500);
  });
}
