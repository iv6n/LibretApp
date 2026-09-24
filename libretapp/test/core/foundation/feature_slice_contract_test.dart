import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/backup/backup.dart';
import 'package:libretapp/core/persistence/persistence.dart';
import 'package:libretapp/core/sync/sync.dart';
import 'package:libretapp/core/tenancy/tenancy.dart';
import 'package:libretapp/features/directorio/animales/animals.dart';
import 'package:libretapp/features/directorio/animales/reproduccion/reproduccion.dart';
import 'package:libretapp/features/directorio/lotes/engorda/engorda.dart';
import 'package:libretapp/features/finanzas/contabilidad/contabilidad.dart';
import 'package:libretapp/features/ubicaciones/almacen/almacen.dart';

class _MemoryStore implements FeatureRecordStore {
  final rows = <String, FeatureRecord>{};
  @override
  Future<FeatureRecord?> get(String farmId, String uuid) async {
    final row = rows[uuid];
    return row != null && row.farmId == farmId ? row : null;
  }
  @override
  Future<List<FeatureRecord>> list(String farmId, String kind, {bool includeDeleted = false}) async => rows.values.where((r) => r.farmId == farmId && r.kind == kind && (includeDeleted || r.deletedAt == null)).toList();
  @override
  Future<List<FeatureRecord>> listAll({bool includeDeleted = false}) async => rows.values.where((r) => includeDeleted || r.deletedAt == null).toList();
  @override
  Future<void> put(FeatureRecord record, {List<FeatureRecord> alsoPut = const []}) async { for (final row in [record, ...alsoPut]) rows[row.uuid] = row; }
  @override
  Future<void> softDelete({required String farmId, required String uuid, required String kind}) async { final row = await get(farmId, uuid); if (row == null || row.kind != kind) return; rows[uuid] = row.copyWith(deletedAt: DateTime.now().toUtc(), synced: false); }
  @override
  Future<void> markSynced(String farmId, String uuid, int revision) async { final row = await get(farmId, uuid); if (row != null) rows[uuid] = row.copyWith(revision: revision, synced: true); }
}

void main() {
  test('identifier preview preserves leading zeros and detects duplicates', () {
    final service = AnimalIdentificationService();
    final result = service.previewImport(
      rows: const [
        AnimalImportRow(rowNumber: 2, values: {'siniiga': '001234567890'}),
        AnimalImportRow(rowNumber: 3, values: {'siniiga': '001234567890'}),
      ],
      existing: const [],
    );
    expect(result.validRows, hasLength(1));
    expect(result.duplicates.keys, contains(3));
    expect(AnimalIdentifier(type: AnimalIdentifierType.siniiga, value: '001234567890').normalized, '001234567890');
  });

  test('inventory kardex rejects negative availability and is idempotent by uuid', () async {
    final store = _MemoryStore();
    final repository = JsonFeatureRepository<InventoryTransaction>(store: store, kind: 'inventory.transaction', decode: InventoryTransaction.fromJson, encode: (v) => v.toJson());
    final service = InventoryService(repository);
    await service.record(farmId: 'farm', productId: 'hay', type: InventoryTransactionType.entry, quantity: 100, unit: 'kg', uuid: 'entry-1');
    final first = await service.record(farmId: 'farm', productId: 'hay', type: InventoryTransactionType.consumption, quantity: 20, unit: 'kg', uuid: 'consume-1');
    final retry = await service.record(farmId: 'farm', productId: 'hay', type: InventoryTransactionType.consumption, quantity: 20, unit: 'kg', uuid: 'consume-1');
    expect(retry.uuid, first.uuid);
    expect((await service.balance('farm', 'hay')).quantity, 80);
    final sourceFirst = await service.record(farmId: 'farm', productId: 'hay', type: InventoryTransactionType.consumption, quantity: 10, unit: 'kg', sourceUuid: 'treatment-1');
    final sourceRetry = await service.record(farmId: 'farm', productId: 'hay', type: InventoryTransactionType.consumption, quantity: 10, unit: 'kg', sourceUuid: 'treatment-1');
    expect(sourceRetry.uuid, sourceFirst.uuid);
    await expectLater(service.record(farmId: 'farm', productId: 'hay', type: InventoryTransactionType.consumption, quantity: 81, unit: 'kg'), throwsA(isA<InventoryValidationException>()));
  });

  test('engorda calculator distinguishes observed GDP and insufficient ICA', () {
    final metrics = FatteningCalculator().calculate(firstWeightKg: 400, lastWeightKg: 460, firstDate: DateTime.utc(2026, 1, 1), lastDate: DateTime.utc(2026, 1, 31), dryMatterConsumedKg: null, targetWeightKg: 500, currentWeightKg: 460, totalCostCents: 100000, asOf: DateTime.utc(2026, 2, 1));
    expect(metrics.gdpObserved, closeTo(2, 0.001));
    expect(metrics.ica, isNull);
    expect(metrics.targetDate, DateTime.utc(2026, 2, 21));
  });

  test('IATF schedule is stable across retries', () async {
    final store = _MemoryStore();
    final protocolRepo = JsonFeatureRepository<ReproductionProtocol>(store: store, kind: 'protocol', decode: ReproductionProtocol.fromJson, encode: (v) => v.toJson());
    final assignmentRepo = JsonFeatureRepository<ProtocolAssignment>(store: store, kind: 'assignment', decode: ProtocolAssignment.fromJson, encode: (v) => v.toJson());
    final executionRepo = JsonFeatureRepository<ProtocolExecution>(store: store, kind: 'execution', decode: ProtocolExecution.fromJson, encode: (v) => v.toJson());
    final service = ReproductionProtocolService(protocols: protocolRepo, assignments: assignmentRepo, executions: executionRepo);
    const protocol = ReproductionProtocol(uuid: 'p1', farmId: 'farm', name: 'IATF base', version: 1, steps: [ReproductionProtocolStep(uuid: 's1', dayOffset: 0, type: ReproductionProtocolStepType.application, name: 'Aplicación')]);
    final assignment = await service.assign(farmId: 'farm', protocol: protocol, animalUuid: 'a1', start: DateTime.utc(2026, 1, 1), uuid: 'a-p1');
    expect((await service.schedule(assignment, protocol)).single.uuid, (await service.schedule(assignment, protocol)).single.uuid);
  });

  test('ledger only posts balanced entries and reverses with opposite lines', () async {
    final store = _MemoryStore();
    final repo = JsonFeatureRepository<JournalEntry>(store: store, kind: 'ledger', decode: JournalEntry.fromJson, encode: (v) => v.toJson());
    final service = LedgerService(accounts: JsonFeatureRepository<LedgerAccount>(store: store, kind: 'accounts', decode: LedgerAccount.fromJson, encode: (v) => v.toJson()), entries: repo);
    final posted = await service.post(JournalEntry(uuid: 'j1', farmId: 'farm', date: DateTime(2026), description: 'Compra', lines: const [LedgerLine(accountCode: '5100', debitCents: 1000), LedgerLine(accountCode: '1100', creditCents: 1000)]));
    final reversed = await service.reverse(posted);
    expect(reversed.status, LedgerEntryStatus.reversed);
    expect((await service.entries('farm')), hasLength(2));
  });

  test('farm migration is idempotent', () async {
    final store = _MemoryStore();
    final contexts = IsarFarmContextRepository(store);
    final migration = FarmMigrationService(contexts, store);
    final first = await migration.ensureDefaultFarm(name: 'Rancho');
    final second = await migration.ensureDefaultFarm(name: 'Otro');
    expect(second.farm.uuid, first.farm.uuid);
    expect(await contexts.listFarms(), hasLength(1));
    expect(second.role, FarmRole.owner);
  });

  test('sync persists the operation, marks applied records, and keeps delete tombstones', () async {
    final store = _MemoryStore();
    final gateway = _ContractSyncGateway();
    final engine = SyncEngine(store: store, gateway: gateway);
    final now = DateTime.utc(2026, 1, 1);
    final record = FeatureRecord(uuid: 'animal-1', farmId: 'farm', kind: 'animal', payload: const {'name': 'A'}, createdAt: now, updatedAt: now, revision: 1);
    await engine.enqueue(record: record, type: SyncOperationType.upsert);
    expect((await store.list('farm', 'core.sync_operation')), hasLength(1));
    final report = await engine.sync('farm');
    expect(report.pushed, 1);
    expect((await store.get('farm', 'animal-1'))?.synced, isTrue);
    expect((await store.list('farm', 'core.sync_operation')), isEmpty);

    gateway.failPush = true;
    await engine.enqueue(record: record.copyWith(payload: const {'name': 'B'}), type: SyncOperationType.upsert);
    expect((await engine.sync('farm')).failed, 1);
    final pending = await store.list('farm', 'core.sync_operation');
    expect(SyncOperation.fromJson(pending.single.payload).attempts, 1);
    gateway.failPush = false;
    expect((await engine.sync('farm')).pushed, 1);

    gateway.nextPull = SyncOperation(uuid: 'remote-delete', farmId: 'farm', entityKind: 'animal', entityUuid: 'animal-2', type: SyncOperationType.delete, payload: const {}, createdAt: now);
    await engine.sync('farm');
    expect((await store.get('farm', 'animal-2'))?.deletedAt, isNotNull);
  });

  test('web backup round-trips shared feature records without permissions', () async {
    final store = _MemoryStore();
    await store.put(FeatureRecord(uuid: 'record-1', farmId: 'farm', kind: 'inventory.transaction', payload: const {'amount': 2}, createdAt: DateTime.utc(2026), updatedAt: DateTime.utc(2026)));
    final backup = WebBackupStore(store);
    final envelope = await backup.capture();
    expect(envelope.schemaVersion, BackupEnvelope.currentSchemaVersion);
    expect(envelope.collections['featureRecords'], hasLength(1));
    final restored = _MemoryStore();
    final result = await WebBackupStore(restored).restore(envelope, mode: BackupImportMode.replaceAll);
    expect(result.count('featureRecords'), 1);
    expect((await restored.get('farm', 'record-1'))?.payload['amount'], 2);
  });
}

class _ContractSyncGateway implements SyncGateway {
  SyncOperation? nextPull;
  bool failPush = false;

  @override
  Future<SyncPushResult> push(List<SyncOperation> operations) async {
    if (failPush) throw StateError('offline');
    return SyncPushResult(applied: operations.map((operation) => operation.uuid).toList(growable: false));
  }

  @override
  Future<SyncBatch> pull({required String farmId, SyncCursor? cursor}) async {
    final operation = nextPull;
    nextPull = null;
    return SyncBatch(operations: operation == null ? const [] : [operation], cursor: SyncCursor(farmId: farmId, value: '1'));
  }
}
