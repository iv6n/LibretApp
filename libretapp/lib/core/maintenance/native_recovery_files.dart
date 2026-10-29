import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

/// Completes an interrupted native restore before Isar opens the database.
/// Every path is a validated basename inside the workspace directory.
Future<void> recoverPendingDatabase(Directory directory, String name) async {
  final marker = File(
    '${directory.path}${Platform.pathSeparator}recovery-pending.json',
  );
  if (!await marker.exists()) return;
  final journal =
      jsonDecode(await marker.readAsString()) as Map<String, dynamic>;
  if (journal['name'] != name)
    throw const FormatException('La recuperación pertenece a otro espacio.');
  String safe(String key) {
    final value = journal[key];
    if (value is! String ||
        !RegExp(r'^[a-zA-Z0-9_-]+\.isar$').hasMatch(value)) {
      throw const FormatException('Ruta de recuperación inválida.');
    }
    return '${directory.path}${Platform.pathSeparator}$value';
  }

  final staged = File(safe('staged'));
  final rollback = File(safe('rollback'));
  final live = File('${directory.path}${Platform.pathSeparator}$name.isar');
  final digest = journal['sha256'];
  if (digest is! String || !RegExp(r'^[a-f0-9]{64}$').hasMatch(digest)) {
    throw const FormatException('Hash de recuperación inválido.');
  }
  if (await staged.exists()) {
    if (sha256.convert(await staged.readAsBytes()).toString() != digest) {
      throw const FormatException('La copia nativa está incompleta.');
    }
    if (await live.exists()) {
      if (await rollback.exists())
        throw StateError('Se requiere revisar la recuperación anterior.');
      await live.rename(rollback.path);
    }
    await staged.rename(live.path);
  }
  if (await live.exists() &&
      sha256.convert(await live.readAsBytes()).toString() == digest) {
    await marker.delete();
    return;
  }
  if (!await live.exists() && await rollback.exists())
    await rollback.rename(live.path);
  throw StateError(
    'La recuperación no se completó. Se conservó la copia anterior.',
  );
}
