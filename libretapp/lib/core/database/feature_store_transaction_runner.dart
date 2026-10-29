import 'package:libretapp/core/database/write_transaction.dart';
import 'package:libretapp/core/persistence/feature_record_store.dart';

/// Drift repositories share the database transaction's asynchronous scope.
class FeatureStoreTransactionRunner implements WriteTransactionRunner {
  FeatureStoreTransactionRunner(this.store);
  final TransactionalFeatureRecordStore store;

  @override
  Future<T> run<T>(Future<T> Function() action) =>
      store.runTransaction((_) => action());
}
