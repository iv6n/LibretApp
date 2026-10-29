import 'dart:async';
class BackupOperationLock {
  static Future<void> _tail = Future.value();
  static final Object _zoneKey = Object();
  Future<T> run<T>(Future<T> Function() operation) {
    if (Zone.current[_zoneKey] == true) return operation();
    final next = _tail.then((_) => runZoned(operation, zoneValues: {_zoneKey: true}));
    _tail = next.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return next;
  }
}
