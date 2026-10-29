import '../domain/rfid_models.dart';

/// Public offline builds never fabricate a hardware reading.
class UnavailableScaleAdapter implements ScaleAdapter {
  const UnavailableScaleAdapter();
  @override
  Stream<ScaleReading> get readings => const Stream.empty();
  @override
  Future<List<RfidDeviceDescriptor>> discover() async => const [];
  @override
  Future<void> connect(RfidDeviceDescriptor device) async => throw StateError('Báscula no disponible en esta edición.');
  @override
  Future<ScaleReading> readStable() async => throw StateError('Báscula no disponible en esta edición.');
  @override
  Future<void> disconnect() async {}
}
