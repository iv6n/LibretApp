import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/features/rfid/rfid.dart';

void main() {
  test('normalizes EPC values from common reader formats', () {
    expect(
      RfidTagNormalizer.normalize(' e280:1160-6000 0020 0000 0001 '),
      'E28011606000002000000001',
    );
    expect(RfidTagNormalizer.isValid('  '), isFalse);
  });

  test('simulated reader emits deterministic tags and a manual EPC', () async {
    final reader = SimulatedRfidReaderAdapter();
    final readsFuture = reader.reads.take(3).toList();

    final devices = await reader.discover();
    await reader.connect(devices.single);
    await reader.startScan();
    reader.emit(' aa-bb ');

    final reads = await readsFuture;
    expect(reads.map((read) => read.normalizedEpc), [
      'E28011606000002000000001',
      'E28011606000002000000002',
      'AABB',
    ]);
    expect(reader.state, HardwareConnectionState.scanning);
    await reader.dispose();
  });

  test('simulated scale returns a stable local reading', () async {
    final scale = SimulatedScaleAdapter(valueKg: 512.5);
    final device = (await scale.discover()).single;
    await scale.connect(device);

    final reading = await scale.readStable();

    expect(reading.valueKg, 512.5);
    expect(reading.stable, isTrue);
    await scale.dispose();
  });
}
