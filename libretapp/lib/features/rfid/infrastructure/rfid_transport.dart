/// Hardware transport port. A BLE vendor adapter can implement this without
/// changing capture, deduplication or persistence logic.
library;

import 'dart:async';

import 'package:libretapp/features/rfid/domain/rfid_models.dart';

abstract interface class RfidTransport {
  Future<List<RfidDeviceDescriptor>> discover();
  Future<void> connect(RfidDeviceDescriptor device);
  Stream<List<int>> get frames;
  Future<void> write(List<int> bytes);
  Future<void> disconnect();
}

class ConfigurableRfidFrameParser {
  const ConfigurableRfidFrameParser({this.start = 0, this.end = 0});
  final int start;
  final int end;
  String? parseEpc(List<int> frame) {
    final from = start.clamp(0, frame.length);
    final to = end <= 0 ? frame.length : end.clamp(from, frame.length);
    if (to <= from) return null;
    return frame.sublist(from, to).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join().toUpperCase();
  }
}

class BluetoothRfidReaderAdapter implements RfidReaderAdapter {
  BluetoothRfidReaderAdapter({required this.transport, this.parser = const ConfigurableRfidFrameParser()});
  final RfidTransport transport;
  final ConfigurableRfidFrameParser parser;
  final _reads = StreamController<RfidTagRead>.broadcast();
  StreamSubscription<List<int>>? _frames;
  HardwareConnectionState _state = HardwareConnectionState.disconnected;
  RfidDeviceDescriptor? _device;

  @override Stream<RfidTagRead> get reads => _reads.stream;
  @override HardwareConnectionState get state => _state;
  @override Future<List<RfidDeviceDescriptor>> discover() async { _state = HardwareConnectionState.discovering; final found = await transport.discover(); _state = HardwareConnectionState.disconnected; return found; }
  @override Future<void> connect(RfidDeviceDescriptor device) async { _state = HardwareConnectionState.connecting; await transport.connect(device); _device = device; _state = HardwareConnectionState.connected; }
  @override Future<void> startScan() async { if (_device == null) throw StateError('Conecta un lector antes de escanear.'); await _frames?.cancel(); _frames = transport.frames.listen((frame) { final epc = parser.parseEpc(frame); if (epc != null) _reads.add(RfidTagRead(epc: epc, readAt: DateTime.now().toUtc(), deviceId: _device?.id)); }); await transport.write(const [0x01]); _state = HardwareConnectionState.scanning; }
  @override Future<void> stopScan() async { await _frames?.cancel(); _frames = null; if (_state == HardwareConnectionState.scanning) _state = HardwareConnectionState.connected; }
  @override Future<void> disconnect() async { await stopScan(); await transport.disconnect(); _device = null; _state = HardwareConnectionState.disconnected; }
  Future<void> dispose() async { await disconnect(); await _reads.close(); }
}
