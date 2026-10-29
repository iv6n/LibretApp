import 'dart:io';

import 'package:drift/native.dart';
import 'package:libretapp/core/persistence/drift_feature_database.dart';
import 'package:libretapp/core/persistence/drift_feature_record_store.dart';

class BatchTestDatabase {
  Directory? _directory;
  DriftFeatureRecordStore? _store;

  Future<DriftFeatureRecordStore> open() async {
    _directory ??= await Directory.systemTemp.createTemp(
      'libretapp-web-batch-',
    );
    return _store = DriftFeatureRecordStore(
      DriftFeatureDatabase(
        NativeDatabase(File('${_directory!.path}/records.sqlite')),
      ),
    );
  }

  Future<void> close() async {
    await _store?.close();
    _store = null;
  }

  Future<void> dispose() async {
    await close();
    final directory = _directory;
    if (directory != null &&
        directory.absolute.path.startsWith(
          Directory.systemTemp.absolute.path,
        )) {
      await directory.delete(recursive: true);
    }
  }
}
