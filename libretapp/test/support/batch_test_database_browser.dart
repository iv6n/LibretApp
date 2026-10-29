import 'package:drift/wasm.dart';
import 'package:libretapp/core/persistence/drift_feature_database.dart';
import 'package:libretapp/core/persistence/drift_feature_record_store.dart';
import 'package:sqlite3/wasm.dart';
import 'package:uuid/uuid.dart';

Future<WasmSqlite3>? _module;

/// The browser suite uses the shipped WASM binary and durable IndexedDB.
/// WEB_BATCH_WASM_URL can point at a local CORS-enabled static test server.
class BatchTestDatabase {
  final _name = 'libretapp-batch-test-${const Uuid().v4()}';
  DriftFeatureRecordStore? _store;
  IndexedDbFileSystem? _fileSystem;
  WasmSqlite3? _sqlite;

  Future<DriftFeatureRecordStore> open() async {
    _sqlite = await (_module ??= WasmSqlite3.loadFromUrl(
      Uri.parse(
        const String.fromEnvironment(
          'WEB_BATCH_WASM_URL',
          defaultValue: '/sqlite3.wasm',
        ),
      ),
    ));
    final fs = _fileSystem = await IndexedDbFileSystem.open(dbName: _name);
    _sqlite!.registerVirtualFileSystem(fs, makeDefault: true);
    return _store = DriftFeatureRecordStore(
      DriftFeatureDatabase(
        WasmDatabase(
          sqlite3: _sqlite!,
          path: '/records.sqlite',
          fileSystem: fs,
        ),
      ),
    );
  }

  Future<void> close() async {
    await _store?.close();
    _store = null;
    final fs = _fileSystem;
    if (fs != null) {
      await fs.flush();
      _sqlite!.unregisterVirtualFileSystem(fs);
      await fs.close();
      _fileSystem = null;
    }
  }

  Future<void> dispose() async {
    await close();
    await IndexedDbFileSystem.deleteDatabase(_name);
  }
}
