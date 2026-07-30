/// Complete Isar-backed implementation of the backup store.
library;

import 'package:isar/isar.dart';
import 'package:libretapp/core/backup/backup_models.dart';
import 'package:libretapp/core/backup/backup_store.dart';
import 'package:libretapp/core/database/isar_database.dart';
import 'package:libretapp/core/models/stable_record_model.dart';
import 'package:libretapp/features/agenda/infrastructure/isar/isar_agenda_entry.dart';
import 'package:libretapp/features/agenda/infrastructure/isar/isar_workforce.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_animal.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_commercial_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_cost_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_health_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_movement_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_production_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_reproduction_record.dart';
import 'package:libretapp/features/directorio/animales/infrastructure/isar/isar_weight_record.dart';
import 'package:libretapp/features/directorio/lotes/infrastructure/isar/isar_lote.dart';
import 'package:libretapp/features/finanzas/infrastructure/isar/isar_general_expense_record.dart';
import 'package:libretapp/features/finanzas/infrastructure/isar/isar_income_record.dart';
import 'package:libretapp/features/milking/infrastructure/isar/isar_milking_entry.dart';
import 'package:libretapp/features/milking/infrastructure/isar/isar_milking_session.dart';
import 'package:libretapp/features/perfil/data/perfil_repository.dart';
import 'package:libretapp/features/ubicaciones/infrastructure/isar/isar_location.dart';
import 'package:uuid/uuid.dart';

class IsarBackupStore implements BackupStore {
  IsarBackupStore({
    required IsarDatabase database,
    required PerfilRepository perfilRepository,
  }) : _database = database,
       _perfilRepository = perfilRepository;

  static const collectionNames = <String>{
    'animals',
    'weightRecords',
    'reproductionRecords',
    'productionRecords',
    'healthRecords',
    'costRecords',
    'commercialRecords',
    'movementRecords',
    'lotes',
    'locations',
    'incomeRecords',
    'generalExpenseRecords',
    'milkingSessions',
    'milkingEntries',
    'agendaEntries',
    'workerProfiles',
    'workTeams',
  };

  final IsarDatabase _database;
  final PerfilRepository _perfilRepository;

  @override
  Future<BackupEnvelope> capture() async {
    final isar = await _database.initialize();
    await _backfillRecordUuids(isar);
    final profile = await _perfilRepository.fetchPerfil();
    final collections = await isar.txn(() async {
      return <String, List<Map<String, dynamic>>>{
        'animals': await isar.isarAnimals.where().exportJson(),
        'weightRecords': await isar.isarWeightRecords.where().exportJson(),
        'reproductionRecords': await isar.isarReproductionRecords
            .where()
            .exportJson(),
        'productionRecords': await isar.isarProductionRecords
            .where()
            .exportJson(),
        'healthRecords': await isar.isarHealthRecords.where().exportJson(),
        'costRecords': await isar.isarCostRecords.where().exportJson(),
        'commercialRecords': await isar.isarCommercialRecords
            .where()
            .exportJson(),
        'movementRecords': await isar.isarMovementRecords.where().exportJson(),
        'lotes': await isar.isarLotes.where().exportJson(),
        'locations': await isar.isarLocations.where().exportJson(),
        'incomeRecords': await isar.isarIncomeRecords.where().exportJson(),
        'generalExpenseRecords': await isar.isarGeneralExpenseRecords
            .where()
            .exportJson(),
        'milkingSessions': await isar.isarMilkingSessions.where().exportJson(),
        'milkingEntries': await isar.isarMilkingEntrys.where().exportJson(),
        'agendaEntries': await isar.isarAgendaEntrys.where().exportJson(),
        'workerProfiles': await isar.isarWorkerProfiles.where().exportJson(),
        'workTeams': await isar.isarWorkTeams.where().exportJson(),
      };
    });
    return BackupEnvelope(
      schemaVersion: BackupEnvelope.currentSchemaVersion,
      appVersion: '0.1.0+2',
      exportedAt: DateTime.now().toUtc(),
      collections: collections,
      profile: profile.toJson(),
    );
  }

  @override
  Future<BackupRestoreResult> restore(
    BackupEnvelope envelope, {
    required BackupImportMode mode,
  }) async {
    final isar = await _database.initialize();
    final prepared = mode == BackupImportMode.merge
        ? await _prepareMerge(isar, envelope.collections)
        : envelope.collections;

    await isar.writeTxn(() async {
      if (mode == BackupImportMode.replaceAll) {
        await _clearAll(isar);
      }
      await isar.isarAnimals.importJson(prepared['animals']!);
      await isar.isarWeightRecords.importJson(prepared['weightRecords']!);
      await isar.isarReproductionRecords.importJson(
        prepared['reproductionRecords']!,
      );
      await isar.isarProductionRecords.importJson(
        prepared['productionRecords']!,
      );
      await isar.isarHealthRecords.importJson(prepared['healthRecords']!);
      await isar.isarCostRecords.importJson(prepared['costRecords']!);
      await isar.isarCommercialRecords.importJson(
        prepared['commercialRecords']!,
      );
      await isar.isarMovementRecords.importJson(prepared['movementRecords']!);
      await isar.isarLotes.importJson(prepared['lotes']!);
      await isar.isarLocations.importJson(prepared['locations']!);
      await isar.isarIncomeRecords.importJson(prepared['incomeRecords']!);
      await isar.isarGeneralExpenseRecords.importJson(
        prepared['generalExpenseRecords']!,
      );
      await isar.isarMilkingSessions.importJson(prepared['milkingSessions']!);
      await isar.isarMilkingEntrys.importJson(prepared['milkingEntries']!);
      await isar.isarAgendaEntrys.importJson(prepared['agendaEntries']!);
      await isar.isarWorkerProfiles.importJson(prepared['workerProfiles']!);
      await isar.isarWorkTeams.importJson(prepared['workTeams']!);
    });
    if (envelope.profile.isNotEmpty) {
      final current = await _perfilRepository.fetchPerfil();
      await _perfilRepository.updatePerfil(
        current.copyWith(
          id: envelope.profile['id'] as String? ?? '',
          nombre: envelope.profile['nombre'] as String? ?? '',
          apellido: envelope.profile['apellido'] as String? ?? '',
          email: envelope.profile['email'] as String? ?? '',
          telefono: envelope.profile['telefono'] as String? ?? '',
          finca: envelope.profile['finca'] as String? ?? '',
          direccion: envelope.profile['direccion'] as String? ?? '',
          upp: envelope.profile['upp'] as String? ?? '',
        ),
      );
    }
    return BackupRestoreResult({
      for (final entry in envelope.collections.entries)
        entry.key: entry.value.length,
    });
  }

  Future<void> _backfillRecordUuids(Isar isar) async {
    await isar.writeTxn(() async {
      await _backfill(
        isar.isarWeightRecords,
        await isar.isarWeightRecords.where().findAll(),
      );
      await _backfill(
        isar.isarReproductionRecords,
        await isar.isarReproductionRecords.where().findAll(),
      );
      await _backfill(
        isar.isarProductionRecords,
        await isar.isarProductionRecords.where().findAll(),
      );
      await _backfill(
        isar.isarHealthRecords,
        await isar.isarHealthRecords.where().findAll(),
      );
      await _backfill(
        isar.isarCostRecords,
        await isar.isarCostRecords.where().findAll(),
      );
      await _backfill(
        isar.isarCommercialRecords,
        await isar.isarCommercialRecords.where().findAll(),
      );
      await _backfill(
        isar.isarMovementRecords,
        await isar.isarMovementRecords.where().findAll(),
      );
      await _backfill(
        isar.isarIncomeRecords,
        await isar.isarIncomeRecords.where().findAll(),
      );
      await _backfill(
        isar.isarGeneralExpenseRecords,
        await isar.isarGeneralExpenseRecords.where().findAll(),
      );
    });
  }

  Future<void> _backfill<T extends StableRecordModel>(
    IsarCollection<T> collection,
    List<T> records,
  ) async {
    final missing = records
        .where((record) => record.recordUuid.isEmpty)
        .toList();
    for (final record in missing) {
      record.recordUuid = const Uuid().v4();
    }
    if (missing.isNotEmpty) await collection.putAll(missing);
  }

  Future<Map<String, List<Map<String, dynamic>>>> _prepareMerge(
    Isar isar,
    Map<String, List<Map<String, dynamic>>> incoming,
  ) async {
    final existing = await isar.txn(() async {
      return <String, List<Map<String, dynamic>>>{
        'animals': await isar.isarAnimals.where().exportJson(),
        'weightRecords': await isar.isarWeightRecords.where().exportJson(),
        'reproductionRecords': await isar.isarReproductionRecords
            .where()
            .exportJson(),
        'productionRecords': await isar.isarProductionRecords
            .where()
            .exportJson(),
        'healthRecords': await isar.isarHealthRecords.where().exportJson(),
        'costRecords': await isar.isarCostRecords.where().exportJson(),
        'commercialRecords': await isar.isarCommercialRecords
            .where()
            .exportJson(),
        'movementRecords': await isar.isarMovementRecords.where().exportJson(),
        'lotes': await isar.isarLotes.where().exportJson(),
        'locations': await isar.isarLocations.where().exportJson(),
        'incomeRecords': await isar.isarIncomeRecords.where().exportJson(),
        'generalExpenseRecords': await isar.isarGeneralExpenseRecords
            .where()
            .exportJson(),
        'milkingSessions': await isar.isarMilkingSessions.where().exportJson(),
        'milkingEntries': await isar.isarMilkingEntrys.where().exportJson(),
        'agendaEntries': await isar.isarAgendaEntrys.where().exportJson(),
        'workerProfiles': await isar.isarWorkerProfiles.where().exportJson(),
        'workTeams': await isar.isarWorkTeams.where().exportJson(),
      };
    });
    const stableFields = <String, String>{
      'animals': 'uuid',
      'weightRecords': 'recordUuid',
      'reproductionRecords': 'recordUuid',
      'productionRecords': 'recordUuid',
      'healthRecords': 'recordUuid',
      'costRecords': 'recordUuid',
      'commercialRecords': 'recordUuid',
      'movementRecords': 'recordUuid',
      'lotes': 'uuid',
      'locations': 'uuid',
      'incomeRecords': 'recordUuid',
      'generalExpenseRecords': 'recordUuid',
      'milkingSessions': 'uuid',
      'milkingEntries': 'uuid',
      'agendaEntries': 'uuid',
      'workerProfiles': 'uuid',
      'workTeams': 'uuid',
    };
    const idFields = <String, String>{
      'agendaEntries': 'isarId',
      'workerProfiles': 'isarId',
      'workTeams': 'isarId',
    };
    return {
      for (final name in collectionNames)
        name: _mergeRows(
          incoming[name]!,
          existing[name]!,
          stableField: stableFields[name]!,
          idField: idFields[name] ?? 'id',
        ),
    };
  }

  List<Map<String, dynamic>> _mergeRows(
    List<Map<String, dynamic>> incoming,
    List<Map<String, dynamic>> existing, {
    required String stableField,
    required String idField,
  }) {
    final existingIds = <String, int>{
      for (final row in existing)
        if (row[stableField] is String && row[idField] is int)
          row[stableField] as String: row[idField] as int,
    };
    var nextId = existing
        .map((row) => row[idField])
        .whereType<int>()
        .fold<int>(0, (max, id) => id > max ? id : max);
    return incoming
        .map((source) {
          final row = Map<String, dynamic>.from(source);
          final stableId = row[stableField] as String;
          row[idField] = existingIds[stableId] ?? ++nextId;
          return row;
        })
        .toList(growable: false);
  }

  Future<void> _clearAll(Isar isar) async {
    await isar.isarAnimals.clear();
    await isar.isarWeightRecords.clear();
    await isar.isarReproductionRecords.clear();
    await isar.isarProductionRecords.clear();
    await isar.isarHealthRecords.clear();
    await isar.isarCostRecords.clear();
    await isar.isarCommercialRecords.clear();
    await isar.isarMovementRecords.clear();
    await isar.isarLotes.clear();
    await isar.isarLocations.clear();
    await isar.isarIncomeRecords.clear();
    await isar.isarGeneralExpenseRecords.clear();
    await isar.isarMilkingSessions.clear();
    await isar.isarMilkingEntrys.clear();
    await isar.isarAgendaEntrys.clear();
    await isar.isarWorkerProfiles.clear();
    await isar.isarWorkTeams.clear();
  }
}
