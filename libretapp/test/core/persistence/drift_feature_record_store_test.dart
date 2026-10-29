import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/persistence/drift_feature_database.dart';
import 'package:libretapp/core/persistence/drift_feature_record_store.dart';
import 'package:libretapp/core/persistence/feature_record_store.dart';

/// Models an executor whose exclusive browser lock must outlive every write
/// in a batch. A nested savepoint must not own or release that lock.
class _OuterTransactionOnly extends QueryInterceptor {
  int transactions = 0;

  @override
  TransactionExecutor beginTransaction(QueryExecutor parent) {
    if (parent is TransactionExecutor) {
      throw StateError('The outer transaction already owns the browser lock.');
    }
    transactions++;
    return parent.beginTransaction();
  }
}

void main() {
  late _OuterTransactionOnly locking;
  late DriftFeatureRecordStore store;

  setUp(() {
    locking = _OuterTransactionOnly();
    store = DriftFeatureRecordStore(
      DriftFeatureDatabase(NativeDatabase.memory().interceptWith(locking)),
    );
  });
  tearDown(() => store.close());

  FeatureRecord animal(String uuid) {
    final now = DateTime.utc(2026, 10, 25);
    return FeatureRecord(
      uuid: uuid,
      farmId: 'test-farm',
      kind: 'animal',
      payload: {'name': uuid},
      createdAt: now,
      updatedAt: now,
    );
  }

  test(
    'root-store writes join the batch transaction without nested locks',
    () async {
      await store.runTransaction((_) async {
        await store.put(animal('first'));
        await store.runTransaction((_) => store.put(animal('second')));
      });

      expect(locking.transactions, 1);
      expect((await store.list('test-farm', 'animal')).map((r) => r.uuid), [
        'first',
        'second',
      ]);
    },
  );

  test('an error after joined writes rolls back the entire batch', () async {
    await expectLater(
      store.runTransaction<void>((_) async {
        await store.put(animal('first'));
        await store.runTransaction((_) => store.put(animal('second')));
        throw StateError('Receipt could not be saved.');
      }),
      throwsStateError,
    );

    expect(await store.list('test-farm', 'animal'), isEmpty);
    expect(locking.transactions, 1);
    await store.put(animal('retry'));
    expect((await store.list('test-farm', 'animal')).single.uuid, 'retry');
    expect(locking.transactions, 2);
  });
}
