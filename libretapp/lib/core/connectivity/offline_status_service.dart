/// Lightweight connectivity status for the local-first shell.
library;

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

enum OfflineStatus { unknown, online, offline }

class OfflineStatusService {
  OfflineStatusService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  final StreamController<OfflineStatus> _controller =
      StreamController<OfflineStatus>.broadcast();
  StreamSubscription<Object?>? _subscription;
  OfflineStatus _status = OfflineStatus.unknown;
  bool _started = false;

  OfflineStatus get status => _status;
  Stream<OfflineStatus> get stream => _controller.stream;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    try {
      final result = await _connectivity.checkConnectivity();
      _setFromPlatformResult(result);
      _subscription = _connectivity.onConnectivityChanged.listen(
        _setFromPlatformResult,
        onError: (_) => _set(OfflineStatus.unknown),
      );
    } catch (_) {
      _set(OfflineStatus.unknown);
    }
  }

  void _setFromPlatformResult(Object? result) {
    final connected = result is List
        ? result.any((item) => item != ConnectivityResult.none)
        : result != ConnectivityResult.none;
    _set(connected ? OfflineStatus.online : OfflineStatus.offline);
  }

  void _set(OfflineStatus next) {
    if (_status == next) return;
    _status = next;
    if (!_controller.isClosed) _controller.add(next);
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
  }
}
