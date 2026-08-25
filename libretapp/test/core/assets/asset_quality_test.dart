import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all generated WEBP assets keep the shared image contract', () async {
    final files =
        Directory('assets/images')
            .listSync()
            .whereType<File>()
            .where((file) => file.path.toLowerCase().endsWith('.webp'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    expect(files, isNotEmpty);

    for (final file in files) {
      final name = file.uri.pathSegments.last;
      final assetPath = 'assets/images/$name';
      final data = await rootBundle.load(assetPath);
      expect(data.lengthInBytes, greaterThan(0), reason: assetPath);

      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      final image = frame.image;

      expect(image.width, 256, reason: assetPath);
      expect(image.height, 256, reason: assetPath);

      final rgba = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      expect(rgba, isNotNull, reason: assetPath);

      final bytes = rgba!.buffer.asUint8List();
      final lastPixel = image.width * 4;
      final cornerAlphaOffsets = <int>[
        3,
        lastPixel - 1,
        (image.height - 1) * lastPixel + 3,
        image.height * lastPixel - 1,
      ];
      for (final offset in cornerAlphaOffsets) {
        expect(bytes[offset], 0, reason: '$assetPath corner alpha');
      }

      image.dispose();
      codec.dispose();
    }
  });
}
