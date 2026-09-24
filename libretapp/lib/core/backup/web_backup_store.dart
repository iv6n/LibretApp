/// Browser backup store. Domain rows are backed by the web FeatureRecordStore;
/// legacy collection migration is intentionally handled by the shared
/// restore contract before production rollout.
library;

import 'package:libretapp/core/backup/backup_models.dart';
import 'package:libretapp/core/backup/backup_store.dart';
import 'package:libretapp/core/persistence/feature_record_store.dart';

class WebBackupStore implements BackupStore {
  WebBackupStore(this._store);

  final FeatureRecordStore _store;

  @override
  Future<BackupEnvelope> capture() async {
    final featureRecords = (await _store.listAll(includeDeleted: true))
        .map((record) => record.toJson())
        .toList(growable: false);
    return BackupEnvelope(
      schemaVersion: BackupEnvelope.currentSchemaVersion,
      appVersion: BackupEnvelope.currentAppVersion,
      exportedAt: DateTime.now().toUtc(),
      collections: {
        for (final name in const [
        'animals', 'weightRecords', 'reproductionRecords', 'productionRecords',
        'healthRecords', 'costRecords', 'commercialRecords', 'movementRecords',
        'lotes', 'cultivations', 'locations', 'incomeRecords',
        'generalExpenseRecords', 'milkingSessions', 'milkingEntries',
        'agendaEntries', 'workerProfiles', 'workTeams', 'careRules',
        'careRecords', 'scheduledCares',
        ]) name: <Map<String, dynamic>>[],
        'featureRecords': featureRecords,
      },
      profile: const {},
    );
  }

  @override
  Future<BackupRestoreResult> restore(BackupEnvelope envelope, {required BackupImportMode mode}) async {
    final rows = envelope.collections['featureRecords'] ?? const <Map<String, dynamic>>[];
    if (mode == BackupImportMode.replaceAll) {
      for (final current in await _store.listAll()) {
        await _store.softDelete(farmId: current.farmId, uuid: current.uuid, kind: current.kind);
      }
    }
    for (final row in rows) {
      await _store.put(FeatureRecord.fromJson(row));
    }
    return BackupRestoreResult({
      for (final entry in envelope.collections.entries) entry.key: entry.value.length,
    });
  }
}
