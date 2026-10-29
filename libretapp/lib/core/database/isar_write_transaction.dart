import 'dart:async';
import 'package:isar_community/isar.dart';
import 'isar_database.dart';
import 'write_transaction.dart';

const _transactionKey = #libretIsarWriteTransaction;

class _Scope {
  _Scope(this.database);
  final Isar database;
  bool active = true;
}

/// Joins only an explicitly shared write scope for the same database. Each
/// asynchronous caller otherwise starts its own serialized Isar transaction.
Future<T> withIsarWriteTransaction<T>(
  Isar database,
  Future<T> Function() action,
) {
  final current = Zone.current[_transactionKey];
  if (current is _Scope &&
      current.active &&
      identical(current.database, database))
    return action();
  return database.writeTxn(() async {
    final scope = _Scope(database);
    try {
      return await runZoned(action, zoneValues: {_transactionKey: scope});
    } finally {
      scope.active = false;
    }
  });
}

class IsarWriteTransactionRunner implements WriteTransactionRunner {
  IsarWriteTransactionRunner(this.database);
  final IsarDatabase database;
  @override
  Future<T> run<T>(Future<T> Function() action) async =>
      withIsarWriteTransaction(await database.initialize(), action);
}
