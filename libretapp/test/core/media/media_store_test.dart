import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:libretapp/core/media/media_store.dart';

void main() {
  late Directory sandbox;
  late Directory documents;

  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp('libretapp_media_store_');
    documents = Directory('${sandbox.path}${Platform.pathSeparator}documents');
    await documents.create();
  });

  tearDown(() async {
    if (await sandbox.exists()) await sandbox.delete(recursive: true);
  });

  test('keeps a persistent copy after the picker file disappears', () async {
    final temporary = File(
      '${sandbox.path}${Platform.pathSeparator}picker-photo.JPG',
    );
    await temporary.writeAsBytes([1, 2, 3, 4]);
    final store = MediaStore(
      documentsDirectory: () async => documents,
      idGenerator: () => 'stable-id',
    );

    final savedPath = await store.persist(
      XFile(temporary.path),
      MediaBucket.animals,
    );
    await temporary.delete();

    final saved = File(savedPath);
    expect(await saved.exists(), isTrue);
    expect(await saved.readAsBytes(), [1, 2, 3, 4]);
    expect(savedPath, contains('${Platform.pathSeparator}animals'));
    expect(savedPath, endsWith('.jpg'));
  });

  test('avoids collisions even when the generated id repeats', () async {
    final first = File('${sandbox.path}${Platform.pathSeparator}first.png');
    final second = File('${sandbox.path}${Platform.pathSeparator}second.png');
    await first.writeAsBytes([1]);
    await second.writeAsBytes([2]);
    final store = MediaStore(
      documentsDirectory: () async => documents,
      idGenerator: () => 'repeated-id',
    );

    final firstPath = await store.persist(
      XFile(first.path),
      MediaBucket.agenda,
    );
    final secondPath = await store.persist(
      XFile(second.path),
      MediaBucket.agenda,
    );

    expect(secondPath, isNot(firstPath));
    expect(await File(firstPath).readAsBytes(), [1]);
    expect(await File(secondPath).readAsBytes(), [2]);
  });

  test('uses a safe fallback extension for malformed picker names', () async {
    final source = File(
      '${sandbox.path}${Platform.pathSeparator}photo.bad-ext!',
    );
    await source.writeAsBytes([9]);
    final store = MediaStore(
      documentsDirectory: () async => documents,
      idGenerator: () => 'safe-name',
    );

    final savedPath = await store.persist(
      XFile(source.path),
      MediaBucket.locations,
    );

    expect(savedPath, endsWith('.jpg'));
  });
}
