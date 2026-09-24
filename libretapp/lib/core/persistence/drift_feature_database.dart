/// Web-capable Drift adapter for feature records.
///
/// The application chooses the executor at composition time. Mobile keeps
/// using Isar; the web composition can provide Drift's SQLite WASM executor
/// without leaking that choice into repositories or domain services.
library;

import 'package:drift/drift.dart';

part 'drift_feature_database.g.dart';

class DriftFeatureRecords extends Table {
  TextColumn get uuid => text()();
  TextColumn get farmId => text()();
  TextColumn get kind => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get revision => integer().withDefault(const Constant(0))();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {uuid};
}

@DriftDatabase(tables: [DriftFeatureRecords])
class DriftFeatureDatabase extends _$DriftFeatureDatabase {
  DriftFeatureDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
