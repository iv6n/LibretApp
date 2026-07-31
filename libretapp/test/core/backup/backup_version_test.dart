/// Guards the hand-maintained copy of the app version stamped into backups.
///
/// [BackupEnvelope.currentAppVersion] has to be edited by hand alongside
/// `version:` in pubspec.yaml. Without this test the two silently drift and
/// every archive produced afterwards misreports the build that wrote it.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:libretapp/core/backup/backup_models.dart';

void main() {
  test('currentAppVersion stays in step with pubspec.yaml', () {
    final pubspec = File('pubspec.yaml');
    expect(
      pubspec.existsSync(),
      isTrue,
      reason: 'Run this test from the libretapp package root.',
    );

    final versionLine = pubspec
        .readAsLinesSync()
        .map((line) => line.trim())
        .firstWhere(
          (line) => line.startsWith('version:'),
          orElse: () => '',
        );

    expect(
      versionLine,
      isNotEmpty,
      reason: 'pubspec.yaml has no top-level `version:` entry.',
    );

    final pubspecVersion = versionLine.substring('version:'.length).trim();

    expect(
      BackupEnvelope.currentAppVersion,
      pubspecVersion,
      reason:
          'BackupEnvelope.currentAppVersion is '
          '${BackupEnvelope.currentAppVersion} but pubspec.yaml says '
          '$pubspecVersion. Update lib/core/backup/backup_models.dart when '
          'bumping the app version.',
    );
  });
}
