import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the generated catalog contains the complete 2.5D scope', () {
    final files =
        Directory('assets/icons_25d_source')
            .listSync()
            .whereType<File>()
            .where((file) => file.path.toLowerCase().endsWith('.png'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    expect(files, hasLength(64));

    final familyCounts = <String, int>{};
    for (final file in files) {
      final name = file.uri.pathSegments.last;
      final family = name.split('_').first;
      familyCounts[family] = (familyCounts[family] ?? 0) + 1;

      final bytes = file.readAsBytesSync();
      expect(bytes.length, greaterThan(24), reason: file.path);
      expect(
        bytes.sublist(0, 8),
        equals(const <int>[137, 80, 78, 71, 13, 10, 26, 10]),
        reason: file.path,
      );
      final data = ByteData.sublistView(Uint8List.fromList(bytes));
      expect(data.getUint32(16), greaterThanOrEqualTo(1024), reason: file.path);
      expect(data.getUint32(20), greaterThanOrEqualTo(1024), reason: file.path);
      expect(bytes[25], 6, reason: '${file.path} must be RGBA PNG');

      final webp = File('assets/images/${name.replaceFirst('.png', '.webp')}');
      expect(webp.existsSync(), isTrue, reason: webp.path);
    }

    expect(
      familyCounts,
      equals({
        'crop': 8,
        'health': 8,
        'inventory': 8,
        'record': 17,
        'status': 13,
        'task': 10,
      }),
    );
  });

  test('the location source contains 53 RGBA masters and production WEBPs', () {
    final files =
        Directory('assets/icons_25d_source/locations')
            .listSync()
            .whereType<File>()
            .where((file) => file.path.toLowerCase().endsWith('.png'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    expect(files, hasLength(53));

    for (final file in files) {
      final name = file.uri.pathSegments.last;
      expect(name, startsWith('location_'));

      final bytes = file.readAsBytesSync();
      expect(bytes.length, greaterThan(24), reason: file.path);
      expect(
        bytes.sublist(0, 8),
        equals(const <int>[137, 80, 78, 71, 13, 10, 26, 10]),
        reason: file.path,
      );
      final data = ByteData.sublistView(Uint8List.fromList(bytes));
      expect(data.getUint32(16), greaterThanOrEqualTo(1024), reason: file.path);
      expect(data.getUint32(20), greaterThanOrEqualTo(1024), reason: file.path);
      expect(bytes[25], 6, reason: '${file.path} must be RGBA PNG');

      final webp = File('assets/images/${name.replaceFirst('.png', '.webp')}');
      expect(webp.existsSync(), isTrue, reason: webp.path);
    }
  });
}
