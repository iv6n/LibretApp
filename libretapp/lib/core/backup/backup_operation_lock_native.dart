import 'dart:io';
import 'dart:async';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:path_provider/path_provider.dart';

/// flock locks open file descriptions, unlike Dart's process-scoped POSIX
/// record locks. This also serializes separate Flutter engines on Android.
class BackupOperationLock {
  static Future<void> _tail = Future.value();
  static final Object _zoneKey = Object();

  Future<T> run<T>(Future<T> Function() operation) {
    if (Zone.current[_zoneKey] == true) return operation();
    final next = _tail.then((_) async {
      final directory = await getApplicationSupportDirectory();
      await directory.create(recursive: true);
      if (Platform.isAndroid || Platform.isLinux) {
        final libc = DynamicLibrary.open(Platform.isAndroid ? 'libc.so' : 'libc.so.6');
        final open = libc.lookupFunction<Int32 Function(Pointer<Utf8>, Int32, Uint32),
            int Function(Pointer<Utf8>, int, int)>('open');
        final flock = libc.lookupFunction<Int32 Function(Int32, Int32),
            int Function(int, int)>('flock');
        final close = libc.lookupFunction<Int32 Function(Int32), int Function(int)>('close');
        final path = '${directory.path}/account-data.lock'.toNativeUtf8();
        final fd = open(path, 0x42, 384); // O_RDWR | O_CREAT, 0600
        calloc.free(path);
        if (fd < 0) throw FileSystemException('No se pudo abrir el bloqueo de datos.');
        try {
          while (flock(fd, 2 | 4) != 0) { // LOCK_EX | LOCK_NB
            await Future<void>.delayed(const Duration(milliseconds: 100));
          }
          return await runZoned(operation, zoneValues: {_zoneKey: true});
        } finally { close(fd); }
      }
      final file = await File('${directory.path}/account-data.lock')
          .open(mode: FileMode.append);
      try {
        await file.lock(FileLock.blockingExclusive);
        return await runZoned(operation, zoneValues: {_zoneKey: true});
      } finally {
        await file.close();
      }
    });
    _tail = next.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return next;
  }
}
