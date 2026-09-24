import 'package:drift/wasm.dart';
import 'package:libretapp/core/persistence/drift_feature_database.dart';

Future<DriftFeatureDatabase> openWebFeatureDatabase({
  required Uri sqlite3Uri,
  required Uri driftWorkerUri,
}) async {
  final result = await WasmDatabase.open(
    databaseName: 'libretapp_features',
    sqlite3Uri: sqlite3Uri,
    driftWorkerUri: driftWorkerUri,
  );
  return DriftFeatureDatabase(result.resolvedExecutor);
}
