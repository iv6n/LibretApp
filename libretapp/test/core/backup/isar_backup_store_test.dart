import 'package:shared_preferences/shared_preferences.dart';
import 'package:libretapp/core/services/shared_prefs_service.dart';
import 'package:libretapp/features/perfil/data/perfil_isar_repository.dart';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:libretapp/core/backup/backup_models.dart';
import 'package:libretapp/core/backup/isar_backup_store.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/isar/isar_lote.dart';
import 'package:libretapp/features/directorio/cultivos/domain/cultivation_entity.dart';
import 'package:libretapp/features/directorio/cultivos/infrastructure/isar_cultivation.dart';
import 'package:libretapp/features/finanzas/domain/entities/financial_period_summary.dart';
import 'package:libretapp/features/finanzas/domain/entities/income_record.dart';
import 'package:libretapp/features/finanzas/infrastructure/isar_finanzas_repository.dart';
import 'package:libretapp/features/perfil/data/perfil_model.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/crop_records.dart';
import 'package:libretapp/features/ubicaciones/domain/entities/location_entity.dart';
import 'package:libretapp/features/ubicaciones/domain/enums/location_type.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/isar/isar_location.dart';
import 'package:libretapp/features/lite/lite_pet_service.dart';
import 'package:libretapp/features/agenda/data/agenda_model.dart';
import 'package:libretapp/features/agenda/infrastructure/isar_agenda_repository.dart';
import 'package:libretapp/features/directorio/animales/domain/entities/health_record.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/life_stage.dart';
import 'package:libretapp/features/directorio/animales/domain/enums/species.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_remote_data_source.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/animal_repository_isar.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/health_record_repository_isar.dart';
import 'package:libretapp/features/directorio/cultivos/infrastructure/cultivation_repository_isar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDirectory;
  late IsarDatabase database;
  late IsarFinanzasRepository finances;
  late PerfilIsarRepository profiles;
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
    SharedPreferences.setMockInitialValues({});
    database = IsarDatabase();
    await database.initialize();
    await database.clearAllCollections();
    finances = IsarFinanzasRepository(database);
    profiles = PerfilIsarRepository(
      database,
      SharedPrefsService(await SharedPreferences.getInstance()),
    );
    await profiles.savePerfil(
      const Perfil(
        id: 'profile-1',
        nombre: 'Ana',
        apellido: 'Piloto',
        email: '',
        telefono: '',
        finca: 'Finca piloto',
        direccion: '',
      ),
    );
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
      await profiles.savePerfil(
        (await profiles.fetchPerfil()).copyWith(finca: 'Otra finca'),
      );
      await store.restore(envelope, mode: BackupImportMode.replaceAll);

      final restored = await finances.getIncomes(
        DateRange(start: DateTime.utc(2026), end: DateTime.utc(2027)),
      );
      expect(restored, hasLength(1));
      expect(restored.single.amount, 1500);
      expect((await profiles.fetchPerfil()).finca, 'Finca piloto');

      final secondCapture = await store.capture();
      expect(
        secondCapture.collections['incomeRecords']!.single['recordUuid'],
        stableId,
      );
    },
  );

  test('respaldo restaura todos los registros sin ocultarlos', () async {
    final raw = await SharedPreferences.getInstance();
    final prefs = SharedPrefsService(raw);
    final animals = AnimalRepositoryIsar(database, prefs, _BackupRemote());
    final health = HealthRecordRepositoryIsar(database);
    final crops = CultivationRepositoryIsar(database);
    final agenda = IsarAgendaRepository(database, prefs);
    final cat = await LitePetService(
      animals,
    ).create(const LitePetInput(name: 'Mora', species: Species.feline));
    final cow = await animals.save(
      cat.copyWith(
        id: Isar.autoIncrement,
        uuid: 'cow-backup',
        customName: 'Luna',
        species: Species.cattle,
        lifeStage: LifeStage.cow,
        earTagNumber: 'C-1',
      ),
    );
    await health.addHealthRecord(
      cat.uuid,
      HealthRecord(
        date: DateTime(2026, 10, 1),
        type: HealthRecordType.checkup,
        product: 'Consulta',
      ),
    );
    final plant = CultivationEntity(
      name: 'Albahaca',
      plantingDate: DateTime(2026, 10, 1),
    );
    final field = CultivationEntity(
      name: 'Parcela',
      plantingDate: DateTime(2026, 10, 1),
      scale: CultivationScale.area,
    );
    await crops.upsert(plant);
    await crops.upsert(field);
    await agenda.saveEntries([
      AgendaEntry(
        id: 'pet-date',
        titulo: 'Cita',
        descripcion: '',
        fecha: DateTime(2026, 11, 1),
        tipo: 'Cita',
        animalIds: [cat.uuid],
        loteIds: const [],
        ubicacion: '',
        estado: AgendaEstado.pendiente,
        completedAnimalIds: const [],
        notas: '',
        sourceType: 'lite',
      ),
      AgendaEntry(
        id: 'dose-date',
        titulo: 'Toma 1',
        descripcion: '',
        fecha: DateTime(2026, 11, 2),
        tipo: 'Medicamento',
        animalIds: [cat.uuid],
        loteIds: const [],
        ubicacion: '',
        estado: AgendaEstado.pendiente,
        completedAnimalIds: const [],
        notas: '',
        sourceType: 'lite',
        planId: 'plan-mora',
      ),
    ]);
    final captured = await store.capture();
    await database.clearAllCollections();
    await store.restore(captured, mode: BackupImportMode.replaceAll);
    final restored = await animals.getAllIncludingInactive();
    expect(
      restored.map((a) => a.uuid).toSet(),
      containsAll([cat.uuid, cow.uuid]),
    );
    expect(restored.firstWhere((a) => a.uuid == cat.uuid).hasKnownAge, isFalse);
    expect(await health.getHealthRecords(cat.uuid), hasLength(1));
    final restoredAgenda = await agenda.fetchEntries();
    expect(restoredAgenda, hasLength(2));
    expect(
      restoredAgenda.every((entry) => entry.sourceType == 'lite'),
      isTrue,
      reason: 'Los recordatorios antiguos conservan su origen compatible.',
    );
    final restoredCrops = await crops.getAll();
    expect(restoredCrops, hasLength(2));
    expect(
      restoredCrops.map((crop) => crop.uuid),
      containsAll([plant.uuid, field.uuid]),
    );
    expect(
      (await animals.getAllIncludingInactive()).map((a) => a.uuid).toSet(),
      contains(cow.uuid),
    );
  });

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

  test('schema 8 restore migrates embedded crops after locations', () async {
    final isar = await database.initialize();
    final location = LocationEntity(
      uuid: 'old-location',
      name: 'Lote Norte',
      type: LocationType.field,
      surfaceArea: 8,
      capacity: 0,
      waterSource: '',
      terrainType: '',
      crops: [
        CropRecord(
          uuid: 'old-crop',
          cropName: 'Maíz',
          plantingDate: DateTime.utc(2026, 2, 1),
          surface: 4.2,
        ),
      ],
    );
    await isar.writeTxn(() => isar.isarLocations.put(location.toIsar()));
    final current = await store.capture();
    final oldCollections = Map<String, List<Map<String, dynamic>>>.from(
      current.collections,
    )..remove('cultivations');
    final schema8 = BackupEnvelope(
      schemaVersion: 8,
      appVersion: current.appVersion,
      exportedAt: current.exportedAt,
      collections: oldCollections,
      profile: current.profile,
    );

    await database.clearAllCollections();
    await store.restore(schema8, mode: BackupImportMode.replaceAll);

    final restored = await isar.isarCultivations
        .where()
        .uuidEqualTo('old-crop')
        .findFirst();
    expect(restored, isNotNull);
    expect(restored!.locationUuid, 'old-location');
    expect(restored.areaSquareMeters, 42000);
    expect((await isar.isarLocations.where().findFirst())!.crops, isEmpty);
  });

  test(
    'schema 10 capture and restore keeps independent cultivations',
    () async {
      final isar = await database.initialize();
      await isar.writeTxn(
        () => isar.isarCultivations.put(
          IsarCultivation.fromEntity(
            CultivationEntity(
              uuid: 'cultivation-9',
              name: 'Rosa',
              plantingDate: DateTime.utc(2026, 9, 1),
            ),
          ),
        ),
      );
      final captured = await store.capture();
      expect(captured.schemaVersion, 11);
      expect(captured.collections['cultivations'], hasLength(1));

      await database.clearAllCollections();
      await store.restore(captured, mode: BackupImportMode.replaceAll);

      final restored = await isar.isarCultivations
          .where()
          .uuidEqualTo('cultivation-9')
          .findFirst();
      expect(restored?.name, 'Rosa');
    },
  );

  group('merge respects modification timestamps', () {
    Future<void> putLote({
      required String name,
      required DateTime lastUpdateDate,
    }) async {
      final isar = await database.initialize();
      await isar.writeTxn(() async {
        final existing = await isar.isarLotes
            .where()
            .uuidEqualTo('lote-merge')
            .findFirst();
        final lote = IsarLote()
          ..uuid = 'lote-merge'
          ..name = name
          ..animalUuids = const []
          ..createdAt = DateTime.utc(2026)
          ..active = true
          ..lastUpdateDate = lastUpdateDate
          ..synced = false;
        if (existing != null) lote.id = existing.id;
        await isar.isarLotes.put(lote);
      });
    }

    Future<String?> readLoteName() async {
      final isar = await database.initialize();
      final lote = await isar.isarLotes
          .where()
          .uuidEqualTo('lote-merge')
          .findFirst();
      return lote?.name;
    }

    test('keeps the local row when it is newer than the snapshot', () async {
      await putLote(
        name: 'Del respaldo',
        lastUpdateDate: DateTime.utc(2026, 5),
      );
      final captured = await store.capture();

      // Simulate a local edit made after the snapshot was taken.
      await putLote(name: 'Editado hoy', lastUpdateDate: DateTime.utc(2026, 9));

      final result = await store.restore(
        captured,
        mode: BackupImportMode.merge,
      );

      expect(await readLoteName(), 'Editado hoy');
      // The skipped row must not be counted as applied.
      expect(result.count('lotes'), 0);
    });

    test('overwrites the local row when the snapshot is newer', () async {
      await putLote(
        name: 'Del respaldo',
        lastUpdateDate: DateTime.utc(2026, 9),
      );
      final captured = await store.capture();

      // Local copy is older than the snapshot this time.
      await putLote(
        name: 'Versión vieja',
        lastUpdateDate: DateTime.utc(2026, 5),
      );

      final result = await store.restore(
        captured,
        mode: BackupImportMode.merge,
      );

      expect(await readLoteName(), 'Del respaldo');
      expect(result.count('lotes'), 1);
    });
  });

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

class _BackupRemote implements AnimalRemoteDataSource {
  @override
  Future<RemoteAnimalPayload> fetchAnimals() async => RemoteAnimalPayload(
    animals: const [],
    hash: '',
    lastUpdated: DateTime(2026),
  );
}
