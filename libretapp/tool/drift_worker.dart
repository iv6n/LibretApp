import 'package:drift/wasm.dart';

/// Rebuild after upgrading Drift or sqlite3 so the browser worker uses the same
/// protocol and durable commit behavior as the app's database client:
/// dart compile js -O4 --no-source-maps --packages=.dart_tool/package_config.json
///   tool/drift_worker.dart -o web/drift_worker.js
void main() => WasmDatabase.workerMainForOpen();
