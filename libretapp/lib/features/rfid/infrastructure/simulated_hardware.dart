/// Deterministic hardware adapters used by the field slice and widget tests.
library;

import 'dart:async';

import 'package:libretapp/features/rfid/domain/rfid_models.dart';

class SimulatedRfidReaderAdapter implements RfidReaderAdapter {
  SimulatedRfidReaderAdapter({List<String>? tags})
    : _tags = List<String>.from(
        tags ?? const ['E28011606000002000000001', 'E28011606000002000000002'],
      );

  final List<String> _tags;
  final StreamController<RfidTagRead> _controller =
      StreamController<RfidTagRead>.broadcast();
  HardwareConnectionState _state = HardwareConnectionState.disconnected;
  RfidDeviceDescriptor? _device;

  @override
  Stream<RfidTagRead> get reads => _controller.stream;

  @override
  HardwareConnectionState get state => _state;

  @override
  Future<List<RfidDeviceDescriptor>> discover() async {
    _state = HardwareConnectionState.discovering;
    await Future<void>.delayed(const Duration(milliseconds: 80));
    _state = HardwareConnectionState.disconnected;
    return const [
      RfidDeviceDescriptor(
        id: 'simulator-rfid',
        name: 'Simulador RFID',
        transport: 'simulator',
        model: 'LibretApp Demo',
      ),
    ];
  }

  @override
  Future<void> connect(RfidDeviceDescriptor device) async {
    _state = HardwareConnectionState.connecting;
    await Future<void>.delayed(const Duration(milliseconds: 80));
    _device = device;
    _state = HardwareConnectionState.connected;
  }

  @override
  Future<void> startScan() async {
    if (_device == null) await connect((await discover()).first);
    _state = HardwareConnectionState.scanning;
    final now = DateTime.now();
    for (var index = 0; index < _tags.length; index++) {
      _controller.add(
        RfidTagRead(
          epc: _tags[index],
          rssi: -42 - index,
          readAt: now.add(Duration(milliseconds: index * 20)),
          deviceId: _device?.id,
        ),
      );
    }
  }

  /// Allows tests and the UI simulator to inject an arbitrary EPC.
  void emit(String epc, {String? tid, int? rssi}) {
    if (_state != HardwareConnectionState.scanning) {
      _state = HardwareConnectionState.scanning;
    }
    _controller.add(
      RfidTagRead(
        epc: epc,
        tid: tid,
        rssi: rssi,
        readAt: DateTime.now(),
        deviceId: _device?.id,
      ),
    );
  }

  @override
  Future<void> stopScan() async {
    if (_state == HardwareConnectionState.scanning) {
      _state = HardwareConnectionState.connected;
    }
  }

  @override
  Future<void> disconnect() async {
    _device = null;
    _state = HardwareConnectionState.disconnected;
  }

  Future<void> dispose() => _controller.close();
}

class KeyboardWedgeRfidAdapter implements RfidReaderAdapter {
  KeyboardWedgeRfidAdapter();

  final StreamController<RfidTagRead> _controller =
      StreamController<RfidTagRead>.broadcast();
  HardwareConnectionState _state = HardwareConnectionState.disconnected;
  RfidDeviceDescriptor? _device;

  @override
  Stream<RfidTagRead> get reads => _controller.stream;

  @override
  HardwareConnectionState get state => _state;

  @override
  Future<List<RfidDeviceDescriptor>> discover() async => const [
    RfidDeviceDescriptor(
      id: 'keyboard-wedge',
      name: 'Lector como teclado',
      transport: 'keyboard',
    ),
  ];

  @override
  Future<void> connect(RfidDeviceDescriptor device) async {
    _device = device;
    _state = HardwareConnectionState.connected;
  }

  /// Feeds a line received from a paired reader that behaves like a keyboard.
  void feed(String raw) {
    final epc = RfidTagNormalizer.normalize(raw);
    if (epc.isEmpty) return;
    _state = HardwareConnectionState.scanning;
    _controller.add(
      RfidTagRead(epc: epc, readAt: DateTime.now(), deviceId: _device?.id),
    );
  }

  @override
  Future<void> startScan() async {
    _state = HardwareConnectionState.scanning;
  }

  @override
  Future<void> stopScan() async {
    if (_state == HardwareConnectionState.scanning) {
      _state = HardwareConnectionState.connected;
    }
  }

  @override
  Future<void> disconnect() async {
    _device = null;
    _state = HardwareConnectionState.disconnected;
  }

  Future<void> dispose() => _controller.close();
}

class SimulatedScaleAdapter implements ScaleAdapter {
  SimulatedScaleAdapter({this.valueKg = 450});

  double valueKg;
  final StreamController<ScaleReading> _controller =
      StreamController<ScaleReading>.broadcast();
  RfidDeviceDescriptor? _device;

  @override
  Stream<ScaleReading> get readings => _controller.stream;

  @override
  Future<List<RfidDeviceDescriptor>> discover() async => const [
    RfidDeviceDescriptor(
      id: 'simulator-scale',
      name: 'Simulador de báscula',
      transport: 'simulator',
      model: 'LibretApp Demo',
    ),
  ];

  @override
  Future<void> connect(RfidDeviceDescriptor device) async {
    _device = device;
  }

  @override
  Future<ScaleReading> readStable() async {
    final reading = ScaleReading(
      valueKg: valueKg,
      capturedAt: DateTime.now(),
      deviceId: _device?.id,
      stable: true,
    );
    _controller.add(reading);
    return reading;
  }

  @override
  Future<void> disconnect() async {
    _device = null;
  }

  Future<void> dispose() => _controller.close();
}
