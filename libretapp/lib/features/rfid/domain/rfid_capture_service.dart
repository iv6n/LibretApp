/// Resumable RFID/scale capture orchestration.
library;

import 'dart:async';

import 'rfid_models.dart';

class RfidCaptureService {
  RfidCaptureService(this.reader);
  final RfidReaderAdapter reader;
  StreamSubscription<RfidTagRead>? _subscription;
  final _controller = StreamController<RfidTagRead>.broadcast();
  final _seen = <String, RfidTagRead>{};
  RfidDeviceDescriptor? _device;

  Stream<RfidTagRead> get reads => _controller.stream;
  List<RfidTagRead> get uniqueReads => _seen.values.toList(growable: false);
  HardwareConnectionState get state => reader.state;

  Future<void> start({RfidDeviceDescriptor? device, int reconnectAttempts = 3}) async {
    _device = device ?? (await reader.discover()).firstOrNull;
    if (_device == null) throw StateError('No hay lector RFID disponible.');
    await _connectWithRetry(reconnectAttempts);
    await _subscription?.cancel();
    _subscription = reader.reads.listen((read) {
      final normalized = read.normalizedEpc;
      if (normalized.isEmpty || _seen.containsKey(normalized)) return;
      _seen[normalized] = read;
      _controller.add(read);
    });
    await reader.startScan();
  }

  Future<void> resume() => start(device: _device);
  Future<void> stop() async { await reader.stopScan(); await _subscription?.cancel(); _subscription = null; }
  Future<void> clear() async { _seen.clear(); }
  Future<void> close() async { await stop(); await reader.disconnect(); await _controller.close(); }

  Future<void> _connectWithRetry(int attempts) async {
    Object? error;
    for (var index = 0; index <= attempts; index++) {
      try { await reader.connect(_device!); return; } catch (exception) { error = exception; if (index < attempts) await Future<void>.delayed(Duration(milliseconds: 150 * (index + 1))); }
    }
    throw StateError('No se pudo conectar el lector RFID: $error');
  }
}

class ScaleCaptureService {
  ScaleCaptureService(this.scale);
  final ScaleAdapter scale;
  RfidDeviceDescriptor? _device;
  Future<void> connect() async { _device = (await scale.discover()).firstOrNull; if (_device == null) throw StateError('No hay báscula disponible.'); await scale.connect(_device!); }
  Stream<ScaleReading> get readings => scale.readings;
  Future<ScaleReading> readStable() => scale.readStable();
  Future<void> close() => scale.disconnect();
}
