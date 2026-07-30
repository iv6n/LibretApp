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
      appVersion: BackupEnvelope.currentAppVersion,
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
    // Counts come from [prepared], not from the envelope: a merge drops rows
    // whose local copy is newer, so the incoming totals would over-report what
    // was actually written.
    return BackupRestoreResult({
      for (final entry in prepared.entries) entry.key: entry.value.length,
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
          updatedAtField: updatedAtFields[name],
        ),
    };
  }

  /// Modification timestamp per collection, used by [BackupImportMode.merge] to
  /// decide whether an incoming row may overwrite the local one.
  ///
  /// The animal child records and both finanzas collections are absent on
  /// purpose: they are insert/delete-only (no repository exposes an update for
  /// them), so they carry no modification timestamp and fall back to the
  /// original merge behaviour of letting the snapshot win.
  static const updatedAtFields = <String, String>{
    'animals': 'lastUpdateDate',
    'lotes': 'lastUpdateDate',
    'locations': 'updatedAt',
    'agendaEntries': 'updatedAt',
    'workerProfiles': 'updatedAt',
    'workTeams': 'updatedAt',
    'milkingSessions': 'updatedAt',
    'milkingEntries': 'updatedAt',
  };

  /// Reconciles [incoming] against [existing] by stable id.
  ///
  /// Rows that are new locally get a fresh Isar id and are inserted. Rows that
  /// already exist are rewritten in place (reusing the local Isar id) *unless*
  /// the local copy is newer — those are dropped from the result so `importJson`
  /// never touches them and the local edit survives the restore.
  List<Map<String, dynamic>> _mergeRows(
    List<Map<String, dynamic>> incoming,
    List<Map<String, dynamic>> existing, {
    required String stableField,
    required String idField,
    String? updatedAtField,
  }) {
    final existingRows = <String, Map<String, dynamic>>{
      for (final row in existing)
        if (row[stableField] is String && row[idField] is int)
          row[stableField] as String: row,
    };
    var nextId = existing
        .map((row) => row[idField])
        .whereType<int>()
        .fold<int>(0, (max, id) => id > max ? id : max);

    final merged = <Map<String, dynamic>>[];
    for (final source in incoming) {
      final stableId = source[stableField];
      if (stableId is! String) continue;
      final local = existingRows[stableId];
      if (local != null && _localCopyWins(local, source, updatedAtField)) {
        continue;
      }
      final row = Map<String, dynamic>.from(source);
      row[idField] = local?[idField] as int? ?? ++nextId;
      merged.add(row);
    }
    return List<Map<String, dynamic>>.unmodifiable(merged);
  }

  /// Whether the local row must survive untouched instead of being overwritten
  /// by [incoming].
  bool _localCopyWins(
    Map<String, dynamic> local,
    Map<String, dynamic> incoming,
    String? updatedAtField,
  ) {
    // Collections without a modification timestamp keep the pre-existing merge
    // semantics (the snapshot wins). There is no basis to claim the local row is
    // newer, and skipping it would make a restore silently do nothing for the
    // insert-only collections.
    if (updatedAtField == null) return false;
    final localAt = _readTimestamp(local[updatedAtField]);
    final incomingAt = _readTimestamp(incoming[updatedAtField]);
    // An unknown local time can't be defended, so let the snapshot win; an
    // unknown incoming time must never clobber a known local edit.
    if (localAt == null) return false;
    if (incomingAt == null) return true;
    return localAt.isAfter(incomingAt);
  }

  /// Isar's `exportJson` writes `DateTime` as microseconds since epoch. Plain
  /// ISO-8601 strings are also accepted because the manifest inside an archive
  /// is human-readable JSON and may have been produced by other tooling.
  DateTime? _readTimestamp(Object? raw) {
    if (raw is int) {
      return DateTime.fromMicrosecondsSinceEpoch(raw, isUtc: true);
    }
    if (raw is String) return DateTime.tryParse(raw)?.toUtc();
    return null;
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
