import 'package:libretapp/core/persistence/drift_feature_database.dart';

Future<DriftFeatureDatabase> openWebFeatureDatabase({
  required Uri sqlite3Uri,
  required Uri driftWorkerUri,
  String databaseName = 'libretapp_features',
}) => throw UnsupportedError('El almacenamiento Drift WASM solo está disponible en web.');
