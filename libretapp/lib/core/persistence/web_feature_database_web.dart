import 'package:drift/wasm.dart';
import 'package:libretapp/core/persistence/drift_feature_database.dart';

Future<DriftFeatureDatabase> openWebFeatureDatabase({
  required Uri sqlite3Uri,
  required Uri driftWorkerUri,
  String databaseName = 'libretapp_features',
}) async {
  final result = await WasmDatabase.open(
    databaseName: databaseName,
    sqlite3Uri: sqlite3Uri,
    driftWorkerUri: driftWorkerUri,
  );
  if (result.chosenImplementation == WasmStorageImplementation.inMemory ||
      result.chosenImplementation ==
          WasmStorageImplementation.unsafeIndexedDb) {
    await result.resolvedExecutor.close();
    throw StateError(
      'El navegador no permite guardar datos de forma persistente y coordinada entre pestañas. '
      'Habilita el almacenamiento del sitio o utiliza un navegador actualizado para conservar tus borradores.',
    );
  }
  return DriftFeatureDatabase(result.resolvedExecutor);
}
